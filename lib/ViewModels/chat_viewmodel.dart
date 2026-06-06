import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mediconnectcode/Models/chat_room_model.dart';
import 'package:mediconnectcode/Models/chat_message_model.dart';
import 'package:mediconnectcode/Models/schedule_model.dart';

/// ChatViewModel — Pure Provider, no StreamBuilder in UI.
///
/// UI calls:
///   startRoomsListener(isDoctor) → when home / chat list opens
///   startChatListener(roomId)    → when a specific chat opens
///   stopChatListener()           → when chat screen closes
///   dispose()                    → automatic cleanup
class ChatViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get currentUid => _auth.currentUser?.uid ?? '';

  // ── Rooms + Unread ───────────────────────────────────────────
  List<ChatRoomModel> chatRooms = [];
  final Map<String, int> _unreadPerRoom = {};
  int get totalUnread =>
      _unreadPerRoom.values.fold(0, (sum, v) => sum + v);
  int unreadForRoom(String roomId) => _unreadPerRoom[roomId] ?? 0;

  // ── Current Chat ─────────────────────────────────────────────
  List<ChatMessageModel> messages = [];
  ChatRoomModel? currentRoom;
  bool isLoadingMessages = true;
  String? errorMessage;

  // ── Local pending (failed messages only) ────────────────────
  final Map<String, List<ChatMessageModel>> _pendingMessages = {};
  List<ChatMessageModel> getPendingMessages(String roomId) =>
      _pendingMessages[roomId] ?? [];

  // ── Subscriptions ────────────────────────────────────────────
  StreamSubscription? _roomsSub;
  StreamSubscription? _messagesSub;
  StreamSubscription? _currentRoomSub;
  final Map<String, StreamSubscription> _unreadSubs = {};

  // ════════════════════════════════════════════════════════════
  // ROOMS + UNREAD LISTENER
  // Call this from home screen & chat list screen initState
  // ════════════════════════════════════════════════════════════

  void startRoomsListener({required bool isDoctor}) {
    final uid = currentUid;
    if (uid.isEmpty) return;

    _roomsSub?.cancel();
    final field = isDoctor ? 'doctorId' : 'patientId';

    _roomsSub = _firestore
        .collection('chat_rooms')
        .where(field, isEqualTo: uid)
        .snapshots()
        .listen((snap) {
      chatRooms = snap.docs
          .map((d) => ChatRoomModel.fromMap(d.data(), d.id))
          .toList()
        ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

      // Start an unread listener for each room
      for (final room in chatRooms) {
        _startUnreadListener(room.id);
      }

      notifyListeners();
    });
  }

  void _startUnreadListener(String roomId) {
    if (_unreadSubs.containsKey(roomId)) return; // already listening

    _unreadSubs[roomId] = _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .snapshots()
        .listen((snap) {
      final uid = currentUid;
      _unreadPerRoom[roomId] = snap.docs.where((d) {
        final data = d.data();
        return data['senderId'] != uid &&
            data['status'] == MessageStatus.sent;
      }).length;
      notifyListeners();
    });
  }

  // ════════════════════════════════════════════════════════════
  // CURRENT CHAT LISTENER
  // Call startChatListener when ChatScreen opens
  // Call stopChatListener when ChatScreen closes
  // ════════════════════════════════════════════════════════════

  void startChatListener(String roomId) {
    isLoadingMessages = true;
    messages = [];
    currentRoom = null;
    notifyListeners();

    // Room state (block status etc.)
    _currentRoomSub?.cancel();
    _currentRoomSub = _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        currentRoom = ChatRoomModel.fromMap(doc.data()!, doc.id);
        notifyListeners();
      }
    });

    // Messages — includeMetadataChanges for hasPendingWrites spinner
    _messagesSub?.cancel();
    _messagesSub = _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .snapshots(includeMetadataChanges: true)
        .listen((snap) {
      final uid = currentUid;
      final pending = getPendingMessages(roomId);

      final firestoreMsgs = snap.docs.map((doc) {
        final msg = ChatMessageModel.fromMap(doc.data(), doc.id);
        // hasPendingWrites → spinner (not yet on server)
        if (doc.metadata.hasPendingWrites) {
          return msg.copyWith(status: MessageStatus.sending);
        }
        return msg;
      }).toList();

      // Keep only failed pending that haven't appeared in Firestore yet
      final dedupedPending = pending.where((p) => !firestoreMsgs.any(
          (f) =>
              f.senderId == p.senderId &&
              f.text == p.text &&
              f.createdAt.difference(p.createdAt).abs().inSeconds < 15))
          .toList();

      final all = [...dedupedPending, ...firestoreMsgs];
      all.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      messages = all;
      isLoadingMessages = false;

      // Update unread for this room too
      _unreadPerRoom[roomId] = firestoreMsgs.where((m) =>
          m.senderId != uid && m.status == MessageStatus.sent).length;

      notifyListeners();
    });
  }

  void stopChatListener() {
    _messagesSub?.cancel();
    _currentRoomSub?.cancel();
    _messagesSub = null;
    _currentRoomSub = null;
    messages = [];
    currentRoom = null;
    isLoadingMessages = true;
  }

  // ════════════════════════════════════════════════════════════
  // SEND MESSAGE
  // ════════════════════════════════════════════════════════════

  Future<void> sendTextMessage({
    required String roomId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    final uid = currentUid;

    try {
      await _firestore
          .collection('chat_rooms')
          .doc(roomId)
          .collection('messages')
          .add({
        'senderId': uid,
        'type': MessageType.text,
        'text': text.trim(),
        'status': MessageStatus.sent,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('chat_rooms').doc(roomId).update({
        'lastMessage': text.trim(),
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Rare: local cache failure → show failed message
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final failed = ChatMessageModel(
        id: tempId,
        senderId: uid,
        type: MessageType.text,
        text: text.trim(),
        status: MessageStatus.failed,
        createdAt: DateTime.now(),
      );
      _pendingMessages[roomId] = [
        ...(_pendingMessages[roomId] ?? []),
        failed,
      ];
      errorMessage = 'Failed to send message.';
      notifyListeners();
    }
  }

  Future<void> retryMessage({
    required String roomId,
    required String tempId,
    required String text,
  }) async {
    _updatePendingStatus(roomId, tempId, MessageStatus.sending);
    final uid = currentUid;
    try {
      await _firestore
          .collection('chat_rooms')
          .doc(roomId)
          .collection('messages')
          .add({
        'senderId': uid,
        'type': MessageType.text,
        'text': text.trim(),
        'status': MessageStatus.sent,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _firestore.collection('chat_rooms').doc(roomId).update({
        'lastMessage': text.trim(),
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
      _removePending(roomId, tempId);
    } catch (_) {
      _updatePendingStatus(roomId, tempId, MessageStatus.failed);
    }
  }

  // ════════════════════════════════════════════════════════════
  // MARK SEEN
  // ════════════════════════════════════════════════════════════

  Future<void> markMessagesAsSeen(String roomId) async {
    try {
      final uid = currentUid;
      final snap = await _firestore
          .collection('chat_rooms')
          .doc(roomId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['senderId'] != uid &&
            data['status'] == MessageStatus.sent) {
          batch.update(doc.reference, {'status': MessageStatus.seen});
        }
      }
      await batch.commit();
    } catch (_) {}
  }

  // ════════════════════════════════════════════════════════════
  // BLOCK / UNBLOCK / DONE
  // ════════════════════════════════════════════════════════════

  Future<void> blockPatient(String roomId) async {
    try {
      await _firestore.collection('chat_rooms').doc(roomId).update({
        'isBlocked': true,
        'blockedBy': currentUid,
      });
    } catch (_) {}
  }

  Future<void> unblockPatient(String roomId) async {
    try {
      await _firestore.collection('chat_rooms').doc(roomId).update({
        'isBlocked': false,
        'blockedBy': null,
      });
    } catch (_) {}
  }

  Future<bool> markDone({
    required String roomId,
    required String patientId,
  }) async {
    try {
      final uid = currentUid;

      await _firestore.collection('chat_rooms').doc(roomId).update({
        'isBlocked': true,
        'blockedBy': uid,
      });

      final reqSnap = await _firestore
          .collection('consultation_requests')
          .where('patientId', isEqualTo: patientId)
          .where('doctorId', isEqualTo: uid)
          .get();
      for (final doc in reqSnap.docs) {
        await doc.reference.update({'status': 'completed'});
      }

      final schedSnap = await _firestore
          .collection('schedules')
          .where('doctorId', isEqualTo: uid)
          .where('patientId', isEqualTo: patientId)
          .get();
      for (final doc in schedSnap.docs) {
        await doc.reference.delete();
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════
  // SCHEDULE
  // ════════════════════════════════════════════════════════════

  List<ScheduleModel> todaySchedules = [];
  StreamSubscription? _schedulesSub;

  void startSchedulesListener() {
    final uid = currentUid;
    if (uid.isEmpty) return;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    _schedulesSub?.cancel();
    _schedulesSub = _firestore
        .collection('schedules')
        .where('doctorId', isEqualTo: uid)
        .snapshots()
        .listen((snap) {
      todaySchedules = snap.docs
          .map((d) => ScheduleModel.fromMap(d.data(), d.id))
          .where((s) =>
              s.scheduledTime.isAfter(startOfDay) &&
              s.scheduledTime.isBefore(endOfDay))
          .toList()
        ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
      notifyListeners();
    });
  }

  Future<bool> addSchedule({
    required String patientId,
    required String patientName,
    required String roomId,
    required DateTime scheduledTime,
  }) async {
    try {
      final uid = currentUid;
      final existing = await _firestore
          .collection('schedules')
          .where('doctorId', isEqualTo: uid)
          .where('patientId', isEqualTo: patientId)
          .get();

      if (existing.docs.isNotEmpty) {
        await existing.docs.first.reference.update({
          'scheduledTime': scheduledTime,
          'patientName': patientName,
          'roomId': roomId,
        });
        for (int i = 1; i < existing.docs.length; i++) {
          await existing.docs[i].reference.delete();
        }
      } else {
        await _firestore.collection('schedules').add({
          'doctorId': uid,
          'patientId': patientId,
          'patientName': patientName,
          'roomId': roomId,
          'scheduledTime': scheduledTime,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ════════════════════════════════════════════════════════════

  void _removePending(String roomId, String tempId) {
    _pendingMessages[roomId] = (_pendingMessages[roomId] ?? [])
        .where((m) => m.id != tempId)
        .toList();
    notifyListeners();
  }

  void _updatePendingStatus(String roomId, String tempId, String status) {
    _pendingMessages[roomId] = (_pendingMessages[roomId] ?? []).map((m) {
      return m.id == tempId ? m.copyWith(status: status) : m;
    }).toList();
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _roomsSub?.cancel();
    _messagesSub?.cancel();
    _currentRoomSub?.cancel();
    _schedulesSub?.cancel();
    for (final sub in _unreadSubs.values) {
      sub.cancel();
    }
    super.dispose();
  }
}
