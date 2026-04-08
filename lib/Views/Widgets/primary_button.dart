import 'package:flutter/material.dart';
import 'package:mediconnectcode/main.dart';

/// Primary Action Button Widget
///
/// Used for main call-to-action buttons throughout the app.
/// Features white background with teal text color.
///
/// Example:
/// ```dart
/// PrimaryButton(
///   label: 'Continue',
///   onPressed: () => Navigator.pushNamed(context, '/next-screen'),
/// )
/// ```
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double? width;
  final EdgeInsets? padding;

  const PrimaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.width,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primaryTealDark,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.primaryTealDark,
              ) ??
              const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
        ),
      ),
    );
  }
}

