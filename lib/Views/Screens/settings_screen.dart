import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mediconnectcode/main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Logout',
            style: AppTheme.heading(AppTheme.textPrimary, 18),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: AppTheme.body(AppTheme.textSecondary, 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: AppTheme.label(AppTheme.primaryBlue, 14),
              ),
            ),
            TextButton(
              onPressed: () async {
                await _auth.signOut();
                if (mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushReplacementNamed(context, '/welcome');
                }
              },
              child: Text(
                'Logout',
                style: AppTheme.label(AppTheme.accentRed, 14),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Settings',
          style: AppTheme.heading(AppTheme.textPrimary, 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppTheme.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Account Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header
                  Text(
                    'Account',
                    style: AppTheme.label(AppTheme.textSecondary, 14),
                  ),
                  const SizedBox(height: 12),

                  // Profile Settings
                  _buildSettingsItem(
                    icon: Icons.person_outline,
                    title: 'Profile',
                    subtitle: 'Manage your profile information',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile settings')),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  // Change Password
                  _buildSettingsItem(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    subtitle: 'Update your password',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Change password')),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  // Email Verification
                  _buildSettingsItem(
                    icon: Icons.email_outlined,
                    title: 'Email Verification',
                    subtitle: 'Verify your email address',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Email verification')),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Preferences Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header
                  Text(
                    'Preferences',
                    style: AppTheme.label(AppTheme.textSecondary, 14),
                  ),
                  const SizedBox(height: 12),

                  // Notifications
                  _buildSettingsItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Manage notification settings',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notification settings')),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  // Privacy
                  _buildSettingsItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy',
                    subtitle: 'Control your privacy settings',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Privacy settings')),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  // Language
                  _buildSettingsItem(
                    icon: Icons.language_outlined,
                    title: 'Language',
                    subtitle: 'Select your language',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Language settings')),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Support Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header
                  Text(
                    'Support',
                    style: AppTheme.label(AppTheme.textSecondary, 14),
                  ),
                  const SizedBox(height: 12),

                  // Help & Support
                  _buildSettingsItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get help and support',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Help & Support')),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  // About
                  _buildSettingsItem(
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'About MediConnect',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('About MediConnect')),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  // Terms & Conditions
                  _buildSettingsItem(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    subtitle: 'View terms and conditions',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Terms & Conditions')),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Logout Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildLogoutButton(),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlueLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.label(AppTheme.textPrimary, 14),
                  ),
                  Text(
                    subtitle,
                    style: AppTheme.body(AppTheme.textTertiary, 12),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _showLogoutDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.accentRed.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.accentRed.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.accentRed.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.logout, color: AppTheme.accentRed, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Logout',
                    style: AppTheme.label(AppTheme.accentRed, 14),
                  ),
                  Text(
                    'Sign out from your account',
                    style: AppTheme.body(AppTheme.textTertiary, 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.accentRed),
          ],
        ),
      ),
    );
  }
}
