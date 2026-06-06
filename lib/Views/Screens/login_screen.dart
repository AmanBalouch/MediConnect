import 'package:flutter/material.dart';
import 'package:mediconnectcode/main.dart';
import 'package:mediconnectcode/Views/Widgets/index.dart';
import 'package:provider/provider.dart';
import 'package:mediconnectcode/ViewModels/login_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle sign in with email/password
  void _handleSignIn() async {
    final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);

    bool success = await loginViewModel.signInWithEmailPassword(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign in successful!'),
            backgroundColor: Colors.green,
          ),
        );

        // Small delay to ensure Firestore data is loaded
        await Future.delayed(const Duration(milliseconds: 500));

        // Check user role
        int userRole = await loginViewModel.getUserRole();
        print('DEBUG: User role = $userRole');

        String nextRoute = "/symptom-checker"; // Default for patients

        if (userRole == 1) {
          // Doctor - check if they've filled professional details
          nextRoute = await loginViewModel.getDoctorNextRoute();
          print('DEBUG: Doctor next route = $nextRoute');
        }

        if (mounted) {
          Navigator.pushReplacementNamed(context, nextRoute);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<LoginViewModel>(
        builder: (context, loginViewModel, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Header with gradient - FULL WIDTH
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16,
                    bottom: 64,
                    left: 10,
                    right: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primaryTealDark, AppTheme.primaryTeal],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Back button
                      Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Lock Icon Container
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        child: const Center(
                          child: Text('🔐', style: TextStyle(fontSize: 30)),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Welcome text (centered)
                      Text(
                        'Welcome back!',
                        textAlign: TextAlign.center,
                        style: AppTheme.heading(Colors.white),
                      ),
                      const SizedBox(height: 3),

                      // Subtitle (centered)
                      Text(
                        'Sign in to continue to MediConnect',
                        textAlign: TextAlign.center,
                        style: AppTheme.heading(Colors.white70, 18),
                      ),
                    ],
                  ),
                ),

                // Form area
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error message
                      if (loginViewModel.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.accentRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.accentRed),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: AppTheme.accentRed,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  loginViewModel.errorMessage!,
                                  style: AppTheme.small(AppTheme.accentRed),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Email field label
                      Text(
                        'Email or phone number',
                        style: AppTheme.label(),
                      ),
                      const SizedBox(height: 6),

                      // Email input field
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: AppTheme.body(AppTheme.textPrimary),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          hintText: 'ahmed@email.com',
                          hintStyle: AppTheme.small(AppTheme.textTertiary),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            size: 14,
                            color: AppTheme.textTertiary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppTheme.borderColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppTheme.borderColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryTeal,
                              width: 1.5,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Password field label
                      Text(
                        'Password',
                        style: AppTheme.label(),
                      ),
                      const SizedBox(height: 6),

                      // Password input field
                      TextField(
                        controller: _passwordController,
                        obscureText: !loginViewModel.isPasswordVisible,
                        style: AppTheme.body(AppTheme.textPrimary),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          hintText: '••••••••',
                          hintStyle: AppTheme.small(AppTheme.textTertiary),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: AppTheme.textTertiary,
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              loginViewModel.togglePasswordVisibility();
                            },
                            child: Icon(
                              loginViewModel.isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 14,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppTheme.borderColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppTheme.borderColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryTeal,
                              width: 1.5,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Forgot password link
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/forgot-password');
                          },
                          child: Text(
                            'Forgot password?',
                            style: AppTheme.small(AppTheme.primaryTeal),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Sign in button
                      PrimaryButton(
                        label: loginViewModel.isLoading
                            ? 'Signing in...'
                            : 'Sign In',
                        onPressed: loginViewModel.isLoading
                            ? () {}
                            : _handleSignIn,
                      ),

                      const SizedBox(height: 14),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppTheme.borderColor,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'or continue with',
                              style: AppTheme.small(AppTheme.textTertiary),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppTheme.borderColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Social login buttons
                      Row(
                        children: [
                          // Google button
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                loginViewModel.signInWithGoogle();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppTheme.borderColor,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFea4335),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'G',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text('Google', style: AppTheme.body(AppTheme.textSecondary)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Facebook button
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                loginViewModel.signInWithFacebook();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppTheme.borderColor,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1877f2),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'f',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text('Facebook', style: AppTheme.body(AppTheme.textSecondary)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Sign up link
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Text("Don't have an account? ", style: AppTheme.body(AppTheme.textSecondary)),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/role-selection');
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text('Sign up', style: AppTheme.label(AppTheme.primaryTeal)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
