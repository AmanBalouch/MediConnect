import 'package:flutter/material.dart';
import 'package:mediconnectcode/main.dart';
import 'package:mediconnectcode/Views/Widgets/index.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppTheme.primaryTealDark,
              AppTheme.primaryTeal,
              AppTheme.primaryTealMedium,
              const Color(0xFF9FE1CB),
            ],
            stops: const [0.0, 0.45, 0.80, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Background circles for visual appeal
            BackgroundCircle(
              size: 200,
              position: -60,
              alignment: AlignmentType.topRight,
            ),
            BackgroundCircle(
              size: 120,
              position: 40,
              alignment: AlignmentType.bottomLeft,
            ),
            BackgroundCircle(
              size: 80,
              position: 80,
              alignment: AlignmentType.bottomRight,
            ),

            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // App Logo
                      const AppLogoWidget(
                        size: 64,
                      ),
                      const SizedBox(height: 20),

                      // Main Title
                      Text(
                        'MediConnect\nYour Health, Reimagined',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: Colors.white,
                              height: 1.2,
                            ),
                      ),
                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        'Connect with top doctors, get AI-powered symptom analysis, and consult from anywhere in Pakistan.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.75),
                              height: 1.5,
                            ),
                      ),
                      const SizedBox(height: 40),

                      // Get Started Button
                      PrimaryButton(
                        label: 'Get Started',
                        onPressed: () => {Navigator.pushNamed(context,"/role-selection")},
                      ),
                      const SizedBox(height: 12),

                      // Already have account Button
                      SecondaryButton(
                        label: 'I already have an account',
                        onPressed: () => {},
                      ),
                      const SizedBox(height: 24),

                      // Terms & Privacy Policy
                      Text(
                        'By continuing you agree to our Terms & Privacy Policy',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}











