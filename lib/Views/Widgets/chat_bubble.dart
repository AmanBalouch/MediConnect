import 'package:flutter/material.dart';
import 'package:mediconnectcode/Models/chat_message_model.dart';
import 'package:mediconnectcode/main.dart';

/// A single chat message bubble.
/// isMine = true  → right side (teal), shows status icon
/// isMine = false → left side (white card)
class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMine;
  final DateTime time;
  final String status; // sending | sent | seen | failed
  final String? tempId;           // set only for pending messages
  final String? roomId;           // needed for retry
  final VoidCallback? onRetry;    // called when user taps failed message

  const ChatBubble({
    super.key,
    required this.text,
    required this.isMine,
    required this.time,
    this.status = MessageStatus.sent,
    this.tempId,
    this.roomId,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    final isFailed = status == MessageStatus.failed;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        // Tap failed message to retry
        onTap: isFailed && onRetry != null ? onRetry : null,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72,
          ),
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isFailed
                ? AppTheme.accentRed.withValues(alpha: 0.08)
                : isMine
                    ? AppTheme.primaryTeal
                    : AppTheme.cardColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMine ? 16 : 4),
              bottomRight: Radius.circular(isMine ? 4 : 16),
            ),
            border: isFailed
                ? Border.all(color: AppTheme.accentRed.withValues(alpha: 0.4))
                : isMine
                    ? null
                    : Border.all(color: AppTheme.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Message text
              Text(
                text,
                style: AppTheme.body(
                  isFailed
                      ? AppTheme.accentRed
                      : isMine
                          ? Colors.white
                          : AppTheme.textPrimary,
                  14,
                ),
              ),

              const SizedBox(height: 4),

              // Time + status row (only for own messages)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeStr,
                    style: AppTheme.small(
                      isFailed
                          ? AppTheme.accentRed.withValues(alpha: 0.7)
                          : isMine
                              ? Colors.white.withValues(alpha: 0.7)
                              : AppTheme.textTertiary,
                      10,
                    ),
                  ),
                  if (isMine) ...[
                    const SizedBox(width: 4),
                    _buildStatusIcon(),
                  ],
                ],
              ),

              // Failed hint
              if (isFailed)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'Tap to retry',
                    style: AppTheme.small(
                        AppTheme.accentRed.withValues(alpha: 0.8), 10),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (status) {
      case MessageStatus.sending:
        // Clock — in progress / no internet
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        );

      case MessageStatus.failed:
        return Icon(
          Icons.error_outline_rounded,
          size: 13,
          color: AppTheme.accentRed,
        );

      case MessageStatus.seen:
        // Double tick — teal
        return _doubleTick(AppTheme.primaryTealLight);

      case MessageStatus.sent:
      default:
        // Single tick — white/faded
        return Icon(
          Icons.done_rounded,
          size: 14,
          color: Colors.white.withValues(alpha: 0.7),
        );
    }
  }

  Widget _doubleTick(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.done_rounded, size: 14, color: color),
        Transform.translate(
          offset: const Offset(-6, 0),
          child: Icon(Icons.done_rounded, size: 14, color: color),
        ),
      ],
    );
  }
}
