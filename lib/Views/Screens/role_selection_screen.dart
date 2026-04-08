import 'package:flutter/material.dart';
import 'package:mediconnectcode/main.dart';
import 'package:mediconnectcode/Views/Widgets/index.dart';
import 'package:mediconnectcode/Views/Screens/signup_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String selectedRole = 'patient'; // Default to patient

  void _selectRole(String role) {
    setState(() {
      selectedRole = role;
    });
  }

  void _navigateToNextScreen(BuildContext context) {
    // Pass role as parameter: 0 for patient, 1 for doctor
    final roleValue = selectedRole == 'patient' ? 0 : 1;

    // Navigate to SignUpScreen with role parameter
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SignUpScreen(userRole: roleValue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            // Header Section with Gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryTealDark,
                    AppTheme.primaryTeal,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Hospital Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: const Center(
                      child: Text(
                        '🏥',
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Header Title
                  Text(
                    'Who are you?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 3),

                  // Header Subtitle
                  Text(
                    'Select your role to personalize your experience',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                child: Column(
                  children: [
                    // Patient Role Card using RoleCard Widget
                    RoleCard(
                      icon: Icons.medical_services,
                      title: 'I\'m a Patient',
                      description: 'Find doctors, book consultations, use AI chatbot',
                      isSelected: selectedRole == 'patient',
                      onTap: () => _selectRole('patient'),
                      iconColor: AppTheme.primaryTealLight,
                      selectedColor: AppTheme.primaryTeal,
                    ),

                    const SizedBox(height: 8),

                    // Doctor Role Card using RoleCard Widget
                    RoleCard(
                      icon: Icons.person,
                      title: 'I\'m a Doctor',
                      description: 'Manage appointments, set fees, view patients',
                      isSelected: selectedRole == 'doctor',
                      onTap: () => _selectRole('doctor'),
                      iconColor: AppTheme.primaryBlueLight,
                      selectedColor: AppTheme.primaryBlue,
                    ),

                    const SizedBox(height: 10),

                    // Selection Confirmation (Only show for patient)
                    if (selectedRole == 'patient') ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTealLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              '✅',
                              style: TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Patient selected',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppTheme.primaryTealDark,
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'You\'ll get access to doctor search, AI chatbot & secure payments.',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppTheme.textSecondary,
                                          fontSize: 7.5,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],

                    // Continue Button
                    PrimaryButton(
                      label: selectedRole == 'patient'
                          ? 'Continue as Patient →'
                          : 'Continue as Doctor →',
                      onPressed: () => _navigateToNextScreen(context),
                    ),

                    const SizedBox(height: 8),

                    // Login Link
                    TextButton(
                      onPressed: () => {},
                      child: Text(
                        'Already registered? Log in',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
