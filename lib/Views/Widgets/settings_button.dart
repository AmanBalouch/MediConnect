import 'package:flutter/material.dart';
import 'package:mediconnectcode/main.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16 + MediaQuery.of(context).padding.top,
      right: 16,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/settings');
        },
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.settings_outlined,
            color: AppTheme.textPrimary,
            size: 24,
          ),
        ),
      ),
    );
  }
}
