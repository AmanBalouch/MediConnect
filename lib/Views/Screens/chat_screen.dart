import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mediconnectcode/Models/chat_message_model.dart';
import 'package:mediconnectcode/Models/chat_room_model.dart';
import 'package:mediconnectcode/ViewModels/chat_viewmodel.dart';
import 'package:mediconnectcode/Views/Widgets/chat_bubble.dart';
import 'package:mediconnectcode/Views/Widgets/payment_request_card.dart';
import 'package:mediconnectcode/main.dart';

/// ChatScreen — the actual conversation screen.
/// Used by both patient and doctor.
/// isDoctor = true → shows block/unblock option in app bar menu
class ChatScreen extends StatefulWidget {
  final String roomId;
  final String otherPersonName;
  final bool isDoctor;

  const ChatScreen({
    super.key,
    required this.roomId,
    required this.otherPersonName,
    required this.isDoctor,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ChatViewModel>();
      vm.startChatListener(widget.roomId);
      vm.markMessagesAsSeen(widget.roomId);
    });
  }

  @override
  void dispose() {
    context.read<ChatViewModel>().stopChatListener();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage(ChatViewModel vm) {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    vm.sendTextMessage(roomId: widget.roomId, text: text);
  }

  Future<void> _showScheduleDialog(
      BuildContext context, ChatViewModel vm, ChatRoomModel? room) async {
    if (room == null) return;

    final now = DateTime.now();

    // Step 1 — pick date
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Select appointment date',
    );

    if (pickedDate == null || !context.mounted) return;

    // Step 2 — pick time
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Select appointment time',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );

    if (pickedTime == null || !context.mounted) return;

    final scheduledTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final success = await vm.addSchedule(
      patientId: room.patientId,
      patientName: room.patientName,
      roomId: widget.roomId,
      scheduledTime: scheduledTime,
    );

    if (!context.mounted) return;
    final dateLabel =
        '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}'
        ' at ${pickedTime.format(context)}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            success ? 'Schedule set for $dateLabel' : 'Failed to set schedule.'),
        backgroundColor:
            success ? AppTheme.primaryTeal : AppTheme.accentRed,
      ),
    );
  }

  Future<void> _showDoneConfirm(
      BuildContext context, ChatViewModel vm, ChatRoomModel? room) async {
    if (room == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mark as Done'),
        content: const Text(
          'This will end the consultation. The patient will be blocked and '
          'can send a new request if they need help again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal),
            child: const Text('Done'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success = await vm.markDone(
      roomId: widget.roomId,
      patientId: room.patientId,
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Consultation marked as done.'
            : 'Something went wrong.'),
        backgroundColor:
            success ? AppTheme.primaryTeal : AppTheme.accentRed,
      ),
    );
  }

  Future<void> _showBlockConfirm(
      BuildContext context, ChatViewModel vm, bool currentlyBlocked) async {
    final action = currentlyBlocked ? 'Unblock' : 'Block';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$action Patient'),
        content: Text(
          currentlyBlocked
              ? 'Are you sure you want to unblock this patient? They will be able to message again.'
              : 'Are you sure you want to block this patient? They will not be able to send messages.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  currentlyBlocked ? AppTheme.primaryTeal : AppTheme.accentRed,
            ),
            child: Text(action),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (currentlyBlocked) {
        await vm.unblockPatient(widget.roomId);
      } else {
        await vm.blockPatient(widget.roomId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: Consumer<ChatViewModel>(
        builder: (context, vm, _) {
          final room = vm.currentRoom;
          final isBlocked = room?.isBlocked ?? false;

          return Column(
            children: [
              // ── App Bar ──────────────────────────────────────────────
              Container(
                padding: EdgeInsets.fromLTRB(
                  8,
                  MediaQuery.of(context).padding.top + 8,
                  8,
                  12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryTealDark,
                      AppTheme.primaryTeal,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),

                    // Avatar
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          _initials(widget.otherPersonName),
                          style: AppTheme.label(Colors.white, 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isDoctor
                                ? widget.otherPersonName
                                : 'Dr. ${widget.otherPersonName}',
                            style: AppTheme.label(Colors.white, 15),
                          ),
                          if (isBlocked)
                            Text(
                              'Blocked',
                              style: AppTheme.small(
                                Colors.white.withValues(alpha: 0.7),
                                11,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Doctor-only: block/unblock + schedule menu
                    if (widget.isDoctor)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert,
                            color: Colors.white),
                        onSelected: (val) {
                          if (val == 'block') {
                            _showBlockConfirm(context, vm, isBlocked);
                          } else if (val == 'schedule') {
                            _showScheduleDialog(context, vm, room);
                          } else if (val == 'done') {
                            _showDoneConfirm(context, vm, room);
                          }
                        },
                        itemBuilder: (_) => [
                          // Done
                          PopupMenuItem(
                            value: 'done',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppTheme.primaryTeal,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Done',
                                  style: AppTheme.body(AppTheme.primaryTeal),
                                ),
                              ],
                            ),
                          ),
                          // Set Schedule
                          PopupMenuItem(
                            value: 'schedule',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.schedule_rounded,
                                  color: AppTheme.primaryBlue,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Set Schedule',
                                  style: AppTheme.body(AppTheme.primaryBlue),
                                ),
                              ],
                            ),
                          ),
                          // Block / Unblock
                          PopupMenuItem(
                            value: 'block',
                            child: Row(
                              children: [
                                Icon(
                                  isBlocked
                                      ? Icons.lock_open_rounded
                                      : Icons.block_rounded,
                                  color: isBlocked
                                      ? AppTheme.primaryTeal
                                      : AppTheme.accentRed,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  isBlocked
                                      ? 'Unblock Patient'
                                      : 'Block Patient',
                                  style: AppTheme.body(
                                    isBlocked
                                        ? AppTheme.primaryTeal
                                        : AppTheme.accentRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // ── Messages ─────────────────────────────────────────────
              Expanded(
                child: vm.isLoadingMessages
                    ? const Center(child: CircularProgressIndicator())
                    : vm.messages.isEmpty
                        ? Center(
                            child: Text(
                              'No messages yet.\nSay hello!',
                              style: AppTheme.body(AppTheme.textTertiary),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollCtrl,
                            reverse: true,
                            cacheExtent: 300,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            itemCount: vm.messages.length,
                            itemBuilder: (context, index) {
                              final msg = vm.messages[index];
                              final isMine = msg.senderId == vm.currentUid;

                              if (msg.type == MessageType.paymentRequest &&
                                  msg.paymentDetails != null) {
                                return PaymentRequestCard(
                                  key: ValueKey(msg.id),
                                  details: msg.paymentDetails!,
                                  time: msg.createdAt,
                                );
                              }

                              return ChatBubble(
                                key: ValueKey('${msg.id}_${msg.status}'),
                                text: msg.text,
                                isMine: isMine,
                                time: msg.createdAt,
                                status: msg.status,
                                tempId: msg.id,
                                roomId: widget.roomId,
                                onRetry: msg.status == MessageStatus.failed
                                    ? () => vm.retryMessage(
                                          roomId: widget.roomId,
                                          tempId: msg.id,
                                          text: msg.text,
                                        )
                                    : null,
                              );
                            },
                          ),
              ),

              // ── Blocked banner ───────────────────────────────────────
              if (isBlocked && !widget.isDoctor)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  color: AppTheme.accentRed.withValues(alpha: 0.1),
                  child: Row(
                    children: [
                      const Icon(Icons.block_rounded,
                          color: AppTheme.accentRed, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You have been blocked by the doctor. Messaging is disabled.',
                          style: AppTheme.small(AppTheme.accentRed, 12),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Input bar ────────────────────────────────────────────
              if (!isBlocked || widget.isDoctor)
                Container(
                  padding: EdgeInsets.fromLTRB(
                    12,
                    10,
                    12,
                    MediaQuery.of(context).padding.bottom + 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    border: Border(
                      top: BorderSide(color: AppTheme.borderColor),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _msgCtrl,
                          style: AppTheme.body(AppTheme.textPrimary),
                          maxLines: 4,
                          minLines: 1,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle:
                                AppTheme.small(AppTheme.textTertiary),
                            filled: true,
                            fillColor: AppTheme.bgColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                          onSubmitted: (_) => _sendMessage(vm),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _sendMessage(vm),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.send_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _initials(String name) {
    if (name.trim().isEmpty) return '?';
    return name
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
  }
}
