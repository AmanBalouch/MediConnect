import 'package:flutter/material.dart';
import 'package:mediconnectcode/main.dart';

/// Step Indicator Widget
///
/// Shows progress steps with dots and connecting lines.
/// Used in signup flow to show current step.
///
class StepIndicator extends StatelessWidget {
  final int currentStep; // 1, 2, or 3
  final List<String> stepLabels;

  const StepIndicator({
    Key? key,
    required this.currentStep,
    this.stepLabels = const ['Role', 'Personal info', 'Verify'],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Step dots and lines
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStepDot(1),
            _buildStepLine(1),
            _buildStepDot(2),
            _buildStepLine(2),
            _buildStepDot(3),
          ],
        ),

        const SizedBox(height: 4),

        // Step labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: stepLabels.map((label) {
            final isActive = stepLabels.indexOf(label) + 1 == currentStep;
            return Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.5),
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                  ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStepDot(int step) {
    final isDone = step < currentStep;
    final isActive = step == currentStep;

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone
            ? AppTheme.primaryTeal
            : isActive
                ? AppTheme.primaryBlue
                : AppTheme.borderColor,
      ),
      child: Center(
        child: Text(
          isDone ? '✓' : step.toString(),
          style: TextStyle(
            color: isDone || isActive ? Colors.white : AppTheme.textTertiary,
            fontSize: 8,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStepLine(int step) {
    final isDone = step < currentStep;

    return Expanded(
      child: Container(
        height: 1.5,
        color: isDone ? AppTheme.primaryTeal : AppTheme.borderColor,
      ),
    );
  }
}
