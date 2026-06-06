import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mediconnectcode/Models/chat_room_model.dart';
import 'package:mediconnectcode/ViewModels/chat_viewmodel.dart';
import 'package:mediconnectcode/Views/Screens/chat_screen.dart';
import 'package:mediconnectcode/Views/Widgets/app_bottom_nav_bar.dart';
import 'package:mediconnectcode/main.dart';

/// Single chat list screen used by both patient and doctor.
/// isDoctor = true  → shows patient names, blue theme, doctor nav
/// isDoctor = false → shows doctor names, teal theme, patient nav
class ChatListScreen extends StatefulWidget {
  final bool isDoctor;

  const ChatListScreen({super.key, required this.isDoctor});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool get isDoctor => widget.isDoctor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatViewModel>().startRoomsListener(isDoctor: isDoctor);
    });
  }

  void _onNavTap(BuildContext context, int index) {
    if (isDoctor) {
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/doctor-home');
          break;
        case 1:
          break;
        case 2:
          Navigator.pushNamed(context, '/symptom-checker');
          break;
        case 3:
          Navigator.pushNamed(context, '/settings');
          break;
      }
    } else {
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/patient-home');
          break;
        case 1:
          break;
        case 2:
          Navigator.pushNamed(context, '/symptom-checker');
          break;
        case 3:
          Navigator.pushNamed(context, '/settings');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // context.watch → rebuilds when ViewModel calls notifyListeners()
    final vm = context.watch<ChatViewModel>();
    final headerColor1 = isDoctor ? AppTheme.primaryBlueDark : AppTheme.primaryTealDark;
    final headerColor2 = isDoctor ? AppTheme.primaryBlue : AppTheme.primaryTeal;
    final avatarBg = isDoctor ? AppTheme.primaryBlueLight : AppTheme.primaryTealLight;
    final avatarText = isDoctor ? AppTheme.primaryBlueDark : AppTheme.primaryTealDark;

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top + 16,
              16,
              20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [headerColor1, headerColor2],
              ),
            ),
            child: Text(
              isDoctor ? 'Patient Chats' : 'My Chats',
              style: AppTheme.heading(Colors.white, 24),
            ),
          ),

          // ── Chat Room List ───────────────────────────────────────────
          Expanded(
            child: vm.chatRooms.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded,
                            size: 52, color: AppTheme.textTertiary),
                        const SizedBox(height: 12),
                        Text(
                          isDoctor ? 'No patient chats yet' : 'No chats yet',
                          style: AppTheme.body(AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isDoctor
                              ? 'Accept a consultation request to start chatting.'
                              : 'Send a request to a doctor to start a chat.',
                          style: AppTheme.small(AppTheme.textTertiary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  itemCount: vm.chatRooms.length,
                  itemBuilder: (context, index) {
                    final room = vm.chatRooms[index];
                    // Doctor sees patient name; patient sees doctor name
                    final otherName =
                        isDoctor ? room.patientName : room.doctorName;
                    final displayName =
                        isDoctor ? otherName : 'Dr. $otherName';

                    final initials = otherName
                        .split(' ')
                        .where((w) => w.isNotEmpty)
                        .take(2)
                        .map((w) => w[0].toUpperCase())
                        .join();

                    final timeStr = _formatTime(room.lastMessageTime);

                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            roomId: room.id,
                            otherPersonName: otherName,
                            isDoctor: isDoctor,
                          ),
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: avatarBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  initials.isNotEmpty ? initials : 'P',
                                  style: AppTheme.label(avatarText, 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          displayName,
                                          style: AppTheme.body(
                                              AppTheme.textPrimary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Time + unread badge — from ViewModel
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(timeStr,
                                              style: AppTheme.small(
                                                  AppTheme.textTertiary, 11)),
                                          if (vm.unreadForRoom(room.id) > 0) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryTeal,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              constraints: const BoxConstraints(minWidth: 20),
                                              child: Text(
                                                vm.unreadForRoom(room.id) > 99
                                                    ? '99+'
                                                    : '+${vm.unreadForRoom(room.id)}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (room.isBlocked)
                                        Container(
                                          margin: const EdgeInsets.only(
                                              right: 6),
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.accentRed
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text('Blocked',
                                              style: AppTheme.small(
                                                  AppTheme.accentRed,
                                                  10)),
                                        ),
                                      Expanded(
                                        child: Text(
                                          room.lastMessage.isEmpty
                                              ? 'No messages yet'
                                              : room.lastMessage,
                                          style: AppTheme.small(
                                              AppTheme.textSecondary, 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onTap: (i) => _onNavTap(context, i),
        unreadCount: vm.totalUnread,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}
