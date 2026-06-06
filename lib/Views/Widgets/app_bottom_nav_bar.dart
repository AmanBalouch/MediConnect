import 'package:flutter/material.dart';
import 'package:mediconnectcode/main.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Total unread messages — red dot on Chat icon when > 0
  final int unreadCount;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        border: Border(top: BorderSide(color: AppTheme.borderColor, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home_outlined,
                label: 'Home',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _buildNavItem(
                context,
                icon: Icons.message_outlined,
                label: 'Chat',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
                badgeCount: unreadCount,
              ),
              _buildNavItem(
                context,
                icon: Icons.smart_toy_outlined,
                label: 'ChatBot',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _buildNavItem(
                context,
                icon: Icons.settings_outlined,
                label: 'Settings',
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isActive ? AppTheme.primaryTeal : AppTheme.borderColor,
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isActive ? Colors.white : AppTheme.textTertiary,
                ),
              ),
              if (badgeCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.accentRed,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(minWidth: 18),
                    child: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.small(
              isActive ? AppTheme.primaryTeal : AppTheme.textTertiary,
              12,
            ),
          ),
        ],
      ),
    );
  }
}
