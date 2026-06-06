import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mediconnectcode/Models/chat_message_model.dart';
import 'package:mediconnectcode/main.dart';

/// Shows a payment request card inside the chat.
/// Displayed when message type == payment_request.
class PaymentRequestCard extends StatelessWidget {
  final PaymentDetails details;
  final DateTime time;

  const PaymentRequestCard({
    super.key,
    required this.details,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    final isEasypaisa =
        details.accountType.toLowerCase() == 'easypaisa';
    final brandColor =
        isEasypaisa ? const Color(0xFF40C265) : const Color(0xFFDB1F26);
    final brandLabel = isEasypaisa ? 'EasyPaisa' : 'JazzCash';
    final brandIcon = isEasypaisa ? Icons.phone_android : Icons.sim_card;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: brandColor.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header bar
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: brandColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  Icon(brandIcon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Fee Payment — $brandLabel',
                    style: AppTheme.label(Colors.white, 13),
                  ),
                ],
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Please send the consultation fee',
                    style: AppTheme.body(AppTheme.textPrimary, 13),
                  ),
                  const SizedBox(height: 12),

                  _detailRow('Amount', 'Rs. ${details.amount}',
                      highlight: true, highlightColor: brandColor),
                  const SizedBox(height: 8),
                  _detailRow(
                      'Account Holder', details.accountHolderName),
                  const SizedBox(height: 8),

                  // Account number with copy button
                  Row(
                    children: [
                      Expanded(
                        child: _detailRow(
                            'Account Number', details.accountNumber),
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                              ClipboardData(text: details.accountNumber));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Account number copied!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: brandColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(Icons.copy_rounded,
                              size: 14, color: brandColor),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Text(
                    'Send payment and inform your doctor to unlock chat.',
                    style: AppTheme.small(AppTheme.textSecondary, 11),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    timeStr,
                    style: AppTheme.small(AppTheme.textTertiary, 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value,
      {bool highlight = false, Color? highlightColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.small(AppTheme.textTertiary, 10)),
        const SizedBox(height: 2),
        Text(
          value,
          style: highlight
              ? AppTheme.heading(highlightColor ?? AppTheme.primaryTeal, 18)
              : AppTheme.body(AppTheme.textPrimary, 13),
        ),
      ],
    );
  }
}
