import 'package:flutter/material.dart';
import 'package:mediconnectcode/main.dart';

/// Custom Form Field Widget
///
/// A reusable text form field with consistent styling.
/// Supports icons, prefixes, and different input types.
///
class CustomFormField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final String? prefixText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final String? Function(String?)? validator;

  const CustomFormField({
    Key? key,
    required this.label,
    this.controller,
    this.prefixIcon,
    this.prefixText,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field label
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
        ),

        const SizedBox(height: 4),

        // Text form field
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
              ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 9,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppTheme.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppTheme.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppTheme.primaryTeal, width: 1),
            ),
            // Prefix icon
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    size: 11,
                    color: AppTheme.textTertiary,
                  )
                : null,
            // Prefix text (like +92)
            prefix: prefixText != null
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                    margin: const EdgeInsets.only(right: 3),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: AppTheme.borderColor, width: 1),
                      ),
                    ),
                    child: Text(
                      prefixText!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  )
                : null,
            // Suffix widget (like password strength bars)
            suffix: suffix,
          ),
        ),
      ],
    );
  }
}
