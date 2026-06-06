import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mediconnectcode/Models/consultation_request_model.dart';
import 'package:mediconnectcode/Models/chat_message_model.dart';
import 'package:mediconnectcode/Models/chat_room_model.dart';

/// ConsultationRequestViewModel
///
/// Handles:
/// 1. Patient sending a consultation request to a doctor
/// 2. Checking if patient already sent a request to this doctor
/// 3. Doctor fetching pending requests (real-time stream)
/// 4. Doctor accepting a request + entering payment details → creates chat room
class ConsultationRequestViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  // Pending requests state — used by doctor home screen
  List<ConsultationRequestModel> pendingRequests = [];
  StreamSubscription? _pendingRequestsSub;

  void startPendingRequestsListener() {
    final user = _auth.currentUser;
    if (user == null) return;

    _pendingRequestsSub?.cancel();
    _pendingRequestsSub = _firestore
        .collection('consultation_requests')
        .where('doctorId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snap) {
      pendingRequests = snap.docs
          .map((doc) => ConsultationRequestModel.fromMap(doc.data(), doc.id))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _pendingRequestsSub?.cancel();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────
  // PATIENT SIDE
  // ────────────────────────────────────────────────────────────

  /// Returns true if this patient already sent a request to this doctor
  Future<bool> hasAlreadySentRequest(String doctorId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Only block re-request if there's an active (pending/accepted) request.
      // 'completed' status means doctor marked Done → patient can request again.
      final snapshot = await _firestore
          .collection('consultation_requests')
          .where('patientId', isEqualTo: user.uid)
          .where('doctorId', isEqualTo: doctorId)
          .get();

      return snapshot.docs.any((doc) {
        final status = doc.data()['status']?.toString() ?? '';
        return status == 'pending' || status == 'accepted';
      });
    } catch (e) {
      return false;
    }
  }

  /// Patient sends a consultation request to a doctor
  Future<bool> sendRequest({
    required String doctorId,
    required String doctorName,
    required String note,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) throw Exception('Not logged in');

      // Get patient name from users collection
      final userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      final patientName =
          userDoc.data()?['username']?.toString().trim() ?? 'Patient';

      // Check if already sent
      final alreadySent = await hasAlreadySentRequest(doctorId);
      if (alreadySent) {
        errorMessage = 'You have already sent a request to this doctor.';
        isLoading = false;
        notifyListeners();
        return false;
      }

      // Create request document
      await _firestore.collection('consultation_requests').add({
        'patientId': user.uid,
        'patientName': patientName,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'note': note,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      successMessage = 'Request sent successfully!';
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ────────────────────────────────────────────────────────────
  // DOCTOR SIDE
  // ────────────────────────────────────────────────────────────

  /// Real-time stream of pending requests for this doctor
  Stream<List<ConsultationRequestModel>> getPendingRequestsStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('consultation_requests')
        .where('doctorId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((doc) =>
                  ConsultationRequestModel.fromMap(doc.data(), doc.id))
              .toList();
          // Sort client-side — avoids needing a Firestore composite index
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  /// Doctor accepts a request and provides payment details.
  /// This will:
  /// 1. Update request status → accepted
  /// 2. Create a chat_room document
  /// 3. Send first message as a payment_request type
  Future<bool> acceptRequest({
    required ConsultationRequestModel request,
    required String accountType,
    required String accountNumber,
    required String accountHolderName,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) throw Exception('Not logged in');

      // 1. Update request status
      await _firestore
          .collection('consultation_requests')
          .doc(request.id)
          .update({'status': 'accepted'});

      // 2. Check if chat room already exists
      final existingRoom = await _firestore
          .collection('chat_rooms')
          .where('patientId', isEqualTo: request.patientId)
          .where('doctorId', isEqualTo: user.uid)
          .limit(1)
          .get();

      String roomId;

      if (existingRoom.docs.isNotEmpty) {
        roomId = existingRoom.docs.first.id;
      } else {
        // 3. Create chat room
        final roomRef = await _firestore.collection('chat_rooms').add({
          'patientId': request.patientId,
          'patientName': request.patientName,
          'doctorId': user.uid,
          'doctorName': request.doctorName,
          'lastMessage': 'Please pay the consultation fee',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'isBlocked': false,
          'blockedBy': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
        roomId = roomRef.id;
      }

      // 4. Get consultation fee from doctors collection
      final doctorDoc =
          await _firestore.collection('doctors').doc(user.uid).get();
      final fee =
          (doctorDoc.data()?['consultationFee'] as num?)?.toInt() ?? 0;

      // 5. Send payment request message
      await _firestore
          .collection('chat_rooms')
          .doc(roomId)
          .collection('messages')
          .add({
        'senderId': user.uid,
        'type': MessageType.paymentRequest,
        'text': 'Please pay the consultation fee to proceed.',
        'createdAt': FieldValue.serverTimestamp(),
        'paymentDetails': {
          'accountType': accountType,
          'accountNumber': accountNumber,
          'accountHolderName': accountHolderName,
          'amount': fee,
        },
      });

      successMessage = 'Request accepted!';
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Doctor rejects a request
  Future<void> rejectRequest(String requestId) async {
    try {
      await _firestore
          .collection('consultation_requests')
          .doc(requestId)
          .update({'status': 'rejected'});
    } catch (_) {}
  }

  void clearMessages() {
    errorMessage = null;
    successMessage = null;
    notifyListeners();
  }
}
