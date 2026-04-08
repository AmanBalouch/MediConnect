import 'package:flutter/material.dart';

/// App Logo Container Widget
///
/// Displays the app logo with a semi-transparent background container.
///
/// Example:
/// ```dart
/// AppLogoWidget(
///   size: 64,
///   icon: Icons.medical_services,
/// )
/// ```
class AppLogoWidget extends StatelessWidget {
  final double size;
  final IconData? icon;
  final String? assetImage;
  final double iconSize;

  const AppLogoWidget({
    Key? key,
    this.size = 64,
    this.icon,
    this.assetImage,
    this.iconSize = 32,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.2),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 2,
        ),
      ),
      child: Center(
        child: _buildLogoContent(),
      ),
    );
  }

  Widget _buildLogoContent() {
    // If asset image is provided, use it
    if (assetImage != null) {
      return Image.asset(
        assetImage!,
        width: iconSize,
        height: iconSize,
      );
    }

    // If icon is provided, use it
    if (icon != null) {
      return Icon(
        icon,
        size: iconSize,
        color: Colors.white,
      );
    }

    // TODO: Replace with actual app logo asset
    // Example: Image.asset('assets/icons/mediconnect_logo.png')
    return Icon(
      Icons.healing,
      size: iconSize,
      color: Colors.white,
    );
  }
}

