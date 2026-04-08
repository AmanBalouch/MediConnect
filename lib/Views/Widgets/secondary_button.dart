import 'package:flutter/material.dart';

/// Secondary Action Button Widget
///
/// Used for secondary actions like "Sign In", "Learn More", etc.
/// Features transparent background with white border and text.
///
/// Example:
/// ```dart
/// SecondaryButton(
///   label: 'Sign In',
///   onPressed: () => Navigator.pushNamed(context, '/login'),
/// )
/// ```
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double? width;
  final EdgeInsets? padding;
  final Color? borderColor;
  final Color? textColor;

  const SecondaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.width,
    this.padding,
    this.borderColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? Colors.white,
          side: BorderSide(
            color: borderColor ?? Colors.white.withValues(alpha: 0.4),
            width: 1.5,
          ),
          padding: padding ?? const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: textColor ?? Colors.white,
              ) ??
              const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
        ),
      ),
    );
  }
}

