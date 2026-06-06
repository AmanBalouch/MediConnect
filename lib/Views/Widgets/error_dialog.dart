import 'package:flutter/material.dart';
import 'package:mediconnectcode/main.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onButtonPressed;
  final IconData icon;

  const ErrorDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.onButtonPressed,
    this.buttonLabel = 'OK',
    this.icon = Icons.error_outline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.accentRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: Icon(icon, color: AppTheme.accentRed, size: 48),
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: AppTheme.heading(AppTheme.textPrimary, 18),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: AppTheme.body(AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 28),

            // OK Button
            GestureDetector(
              onTap: onButtonPressed,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.accentRed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    buttonLabel,
                    style: AppTheme.label(Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
