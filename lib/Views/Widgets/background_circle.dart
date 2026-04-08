import 'package:flutter/material.dart';

/// Background Decorative Circle Widget
///
/// Creates circular decorative elements for backgrounds.
/// Used to add visual appeal to screens.
///
/// Example:
/// ```dart
/// BackgroundCircle(
///   size: 200,
///   top: -60,
///   right: -60,
/// )
/// ```
class BackgroundCircle extends StatelessWidget {
  final double size;
  final double position;
  final AlignmentType alignment;
  final double opacity;

  const BackgroundCircle({
    Key? key,
    required this.size,
    required this.position,
    required this.alignment,
    this.opacity = 0.12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: alignment == AlignmentType.topRight || alignment == AlignmentType.topLeft
          ? position
          : null,
      bottom: alignment == AlignmentType.bottomRight ||
              alignment == AlignmentType.bottomLeft
          ? position
          : null,
      right: alignment == AlignmentType.topRight ||
              alignment == AlignmentType.bottomRight
          ? position
          : null,
      left:
          alignment == AlignmentType.topLeft || alignment == AlignmentType.bottomLeft
              ? position
              : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: opacity),
            width: 1,
          ),
        ),
      ),
    );
  }
}

/// Enum for positioning the background circle
enum AlignmentType {
  topRight,
  topLeft,
  bottomRight,
  bottomLeft,
}

