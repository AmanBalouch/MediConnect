import 'package:flutter/material.dart';
import 'package:mediconnectcode/main.dart';

/// RoleCard Widget
///
/// A reusable card widget for displaying role options (Patient/Doctor).
/// Features an icon, title, description, and selection state with radio button style.
///
/// Example usage:
/// ```dart
/// RoleCard(
///   icon: Icons.medical_services,
///   title: 'I\'m a Patient',
///   description: 'Find doctors, book consultations',
///   isSelected: selectedRole == 'patient',
///   onTap: () => selectRole('patient'),
///   iconColor: AppTheme.primaryTealLight,
///   selectedColor: AppTheme.primaryTeal,
/// )
/// ```
class RoleCard extends StatelessWidget {
  /// The icon to display in the card
  final IconData icon;

  /// The main title text
  final String title;

  /// The description text below the title
  final String description;

  /// Whether this card is currently selected
  final bool isSelected;

  /// Callback function when the card is tapped
  final VoidCallback onTap;

  /// Background color for the icon container
  final Color iconColor;

  /// Color used for selection state (border, radio button, icon)
  final Color selectedColor;

  const RoleCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
    required this.iconColor,
    required this.selectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Padding inside the card
        padding: const EdgeInsets.all(50 ),
        decoration: BoxDecoration(
          // Background color changes when selected
          color: isSelected ? iconColor : Colors.white.withValues(alpha: 0.1),
          // Border styling
          border: Border.all(
            color: isSelected ? selectedColor : Colors.grey,
            width: isSelected ? 2 : 1, // Thicker border when selected
          ),
          // Rounded corners
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Icon container on the left
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? selectedColor : AppTheme.textSecondary,
                size: 50,
              ),
            ),

            // Spacing between icon and text
            const SizedBox(width: 16),

            // Text content in the middle (takes remaining space)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title text
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge
                  ),

                  // Small spacing between title and description
                  const SizedBox(height: 4),

                  // Description text
                  Container(
                    width: 150,
                    child: Text(
                      description,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.blueGrey,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            // Radio button style indicator on the right
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Border color changes when selected
                border: Border.all(
                  color: isSelected ? selectedColor : Colors.white.withValues(alpha: 0.4),
                  width: 2,
                ),
                // Fill color when selected
                color: isSelected ? selectedColor : Colors.transparent,
              ),
              // Show check icon when selected
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

