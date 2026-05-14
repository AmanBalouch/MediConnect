import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mediconnectcode/main.dart';
import 'package:mediconnectcode/Views/Widgets/index.dart';
import 'package:provider/provider.dart';
import 'package:mediconnectcode/ViewModels/signup_viewmodel.dart';
import 'package:mediconnectcode/ViewModels/otp_viewmodel.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPVerificationScreen({Key? key, required this.phoneNumber})
    : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 6 OTP input fields
  late List<TextEditingController> otpControllers;
  late List<FocusNode> focusNodes;

  // Timer variables
  int timeLeft = 300; // 5 minutes
  bool canResend = false;

  @override
  void initState() {
    super.initState();
    // Initialize OTP controllers
    otpControllers = List.generate(6, (_) => TextEditingController());
    focusNodes = List.generate(6, (_) => FocusNode());

    // Send OTP via ViewModel when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final otpViewModel = Provider.of<OTPViewModel>(context, listen: false);
      otpViewModel.sendOTP(widget.phoneNumber);
    });

    // Start timer
    _startTimer();
  }

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (timeLeft > 0) {
            timeLeft--;
            _startTimer();
          } else {
            canResend = true;
          }
        });
      }
    });
  }

  String _getFormattedTime() {
    int minutes = timeLeft ~/ 60;
    int seconds = timeLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _onOTPBoxChange(String value, int index) {
    if (value.isNotEmpty) {
      // Move to next box if current one is filled
      if (index < 5) {
        focusNodes[index + 1].requestFocus();
      } else {
        // Last box is filled, unfocus
        focusNodes[index].unfocus();
      }
    }
  }

  void _handleVerify() async {
    // Get all OTP values
    String otp = otpControllers.map((controller) => controller.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 6 digits')),
      );
      return;
    }

    // Get OTP ViewModel
    final otpViewModel = Provider.of<OTPViewModel>(context, listen: false);

    // Verify OTP using ViewModel
    final credential = await otpViewModel.verifyOTP(otp);

    if (credential == null) {
      // Show error from ViewModel
      if (otpViewModel.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(otpViewModel.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // OTP verified, now sign in with credential
    await _signInAndCreateAccount(credential);
  }

  /// Sign in with phone credential and create account
  Future<void> _signInAndCreateAccount(PhoneAuthCredential credential) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Sign in with phone credential
      await _auth.signInWithCredential(credential);

      print('Phone sign-in successful');

      // Now create account in Firestore
      final signupViewModel = Provider.of<SignupViewModel>(
        context,
        listen: false,
      );
      bool success = await signupViewModel.createAccountAfterOTPVerification();

      // Hide loading dialog
      if (mounted) Navigator.pop(context);

      if (success) {
        // Account created successfully - Show success dialog
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => SuccessDialog(
              title: 'Account Created!',
              message:
                  'Your account has been created successfully. Let\'s get you logged in!',
              buttonLabel: 'OK',
              icon: Icons.check_circle,
              onButtonPressed: () {
                // Close success dialog
                Navigator.pop(context);
                // Navigate to login screen
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          );
        }

        print('Account created successfully - navigating to login');
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              signupViewModel.errorMessage ?? 'Failed to create account',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);

      String errorMessage = 'Sign-in failed. Please try again.';
      if (e is FirebaseAuthException) {
        errorMessage = _getErrorMessage(e);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  void _handleResend() async {
    // Get OTP ViewModel
    final otpViewModel = Provider.of<OTPViewModel>(context, listen: false);

    // Resend OTP using ViewModel
    bool success = await otpViewModel.resendOTP();

    if (success) {
      // Reset OTP fields
      for (var controller in otpControllers) {
        controller.clear();
      }
      setState(() {
        timeLeft = 300; // Reset timer to 5 minutes
        canResend = false;
      });
      _startTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP resent to your number'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Show error from ViewModel
      if (otpViewModel.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(otpViewModel.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Get user-friendly error message from Firebase exception
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Invalid phone number format.';
      case 'missing-phone-number':
        return 'Phone number is required.';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please check and try again.';
      case 'session-expired':
        return 'Verification code has expired. Please request a new one.';
      case 'too-many-requests':
        return 'Too many verification attempts. Please try again later.';
      case 'credential-already-in-use':
        return 'This phone number is already linked to another account.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'operation-not-allowed':
        return 'Phone authentication is not enabled.';
      default:
        return 'Error: ${e.message}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with back button (optional)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.borderColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(Icons.arrow_back, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    // Icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTealLight,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Center(
                        child: Text('📱', style: TextStyle(fontSize: 28)),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Title
                    Text(
                      'Verify your number',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),

                    const SizedBox(height: 6),

                    // Subtitle
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 9,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'We sent a 6-digit code to\n'),
                          TextSpan(
                            text: widget.phoneNumber,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 9,
                                ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // OTP Input Boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        6,
                        (index) => Padding(
                          padding: EdgeInsets.only(right: index < 5 ? 8 : 0),
                          child: SizedBox(
                            width: 45,
                            child: TextField(
                              controller: otpControllers[index],
                              focusNode: focusNodes[index],
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(0),
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppTheme.borderColor,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: otpControllers[index].text.isEmpty
                                        ? AppTheme.borderColor
                                        : AppTheme.primaryTeal,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppTheme.primaryTeal,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: otpControllers[index].text.isEmpty
                                    ? const Color(0xFFF8FAFC)
                                    : Colors.white,
                              ),
                              onChanged: (value) {
                                setState(() {}); // Update UI
                                _onOTPBoxChange(value, index);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Timer Box
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTealLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text('⏱️', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Code expires in ${_getFormattedTime()}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppTheme.primaryTealDark,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 9,
                                      ),
                                ),
                                const SizedBox(height: 3),
                                GestureDetector(
                                  onTap: canResend ? _handleResend : null,
                                  child: Text(
                                    "Didn't receive it? ${canResend ? 'Resend code' : 'Resend'}",
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppTheme.textSecondary,
                                          fontSize: 8,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Verify Button
                    PrimaryButton(
                      label: 'Verify & Continue',
                      onPressed: _handleVerify,
                    ),

                    const SizedBox(height: 20),

                    // Progress Indicator
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Step 3 of 3 — Almost done!',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.textPrimary,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(
                            3,
                            (index) => Expanded(
                              child: Container(
                                height: 4,
                                margin: EdgeInsets.only(
                                  right: index < 2 ? 5 : 0,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: index < 3
                                      ? AppTheme.primaryTeal
                                      : AppTheme.primaryTeal.withValues(
                                          alpha: 0.3,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Change Number Link
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Wrong number? Change it',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.textSecondary,
                                fontSize: 9,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
