import 'package:flutter/material.dart';
import 'package:mediconnectcode/main.dart';
import 'package:mediconnectcode/Views/Widgets/index.dart';
import 'package:provider/provider.dart';
import 'package:mediconnectcode/ViewModels/signup_viewmodel.dart';
import 'package:mediconnectcode/Views/Screens/otp_verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  final int userRole; // 0 = patient, 1 = doctor

  const SignUpScreen({
    Key? key,
    required this.userRole,
  }) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController(text: 'Dur Muhammad');
  final _lastNameController = TextEditingController(text: 'Khan');
  final _phoneController = TextEditingController(text: '3XX-XXXXXXX');
  final _emailController = TextEditingController(text: 'abc@email.com');
  final _passwordController = TextEditingController(text: '••••••••');

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SignupViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: Stack(
              children: [
                Column(
                  children: [
                    // Header Section with Gradient
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryBlueDark,
                            AppTheme.primaryBlue,
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Header Title
                          Text(
                            'Create account',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: Colors.white,
                                ),
                          ),

                          const SizedBox(height: 3),

                          // Header Subtitle
                          Text(
                            widget.userRole == 0
                                ? 'Join MediConnect as a patient'
                                : 'Join MediConnect as a doctor',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                          ),

                          const SizedBox(height: 12),

                          // Step Indicator
                          const StepIndicator(currentStep: 2),
                        ],
                      ),
                    ),

                    // Form Area
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // First Name and Last Name Row
                              Row(
                                children: [
                                  // First Name
                                  Expanded(
                                    child: CustomFormField(
                                      label: 'First name',
                                      controller: _firstNameController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your first name';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),

                                  const SizedBox(width: 6),

                                  // Last Name
                                  Expanded(
                                    child: CustomFormField(
                                      label: 'Last name',
                                      controller: _lastNameController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your last name';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Phone Number
                              CustomFormField(
                                label: 'Phone number',
                                controller: _phoneController,
                                prefixText: '+92',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 10),

                              // Email Address
                              CustomFormField(
                                label: 'Email address',
                                controller: _emailController,
                                prefixIcon: Icons.email_outlined,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 10),

                              // Additional fields for doctors
                              if (widget.userRole == 1) ...[
                                CustomFormField(
                                  label: 'Medical specialization',
                                  controller: TextEditingController(text: 'Cardiology'),
                                ),

                                const SizedBox(height: 10),

                                CustomFormField(
                                  label: 'Medical license number',
                                  controller: TextEditingController(text: 'PMC-12345'),
                                ),

                                const SizedBox(height: 10),
                              ],

                              // Create Password
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Create password',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppTheme.textPrimary,
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),

                                  const SizedBox(height: 4),

                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppTheme.textPrimary,
                                          fontSize: 9,
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
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                        size: 11,
                                        color: AppTheme.textTertiary,
                                      ),
                                      // Removed PasswordStrengthIndicator suffix
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a password';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 4),

                                  // Password instruction
                                  Text(
                                    'Password must be strong',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppTheme.textSecondary,
                                          fontSize: 7.5,
                                        ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Continue Button
                              PrimaryButton(
                                label: viewModel.isLoading ? 'Creating Account...' : 'Continue →',
                                onPressed: viewModel.isLoading ? () {} : _handleSignup,
                              ),

                              const SizedBox(height: 8),

                              // Login Link
                              Center(
                                child: TextButton(
                                  onPressed: () => {},
                                  child: Text(
                                    'Already registered? Log in',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppTheme.textSecondary,
                                          fontSize: 10,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (viewModel.isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      final viewModel = Provider.of<SignupViewModel>(context, listen: false);
      String username = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
      String email = _emailController.text.trim();
      String password = _passwordController.text;
      String phoneNumber = _phoneController.text.trim();
      int role = widget.userRole;

      // Save the signup data in ViewModel (don't create account yet)
      viewModel.savePendingSignupData(
        email: email,
        password: password,
        username: username,
        phoneNumber: phoneNumber,
        role: role,
      );

      // Navigate to OTP verification screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationScreen(
            phoneNumber: '+92 $phoneNumber',
          ),
        ),
      );
    }
  }
}
