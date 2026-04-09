import 'package:flutter/material.dart';
import 'package:mediconnectcode/main.dart';
import 'package:mediconnectcode/Views/Widgets/index.dart';
import 'package:provider/provider.dart';
import 'package:mediconnectcode/ViewModels/signup_viewmodel.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPVerificationScreen({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  // 6 OTP input fields
  late List<TextEditingController> otpControllers;
  late List<FocusNode> focusNodes;

  // Timer variables
  int timeLeft = 60;
  bool canResend = false;

  @override
  void initState() {
    super.initState();
    // Initialize OTP controllers
    otpControllers = List.generate(6, (_) => TextEditingController());
    focusNodes = List.generate(6, (_) => FocusNode());

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

    if (otp.length == 6) {
      // Call ViewModel to create account
      final viewModel = Provider.of<SignupViewModel>(context, listen: false);

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Try to create account after OTP verification
      bool success = await viewModel.createAccountAfterOTPVerification();

      // Hide loading dialog
      Navigator.pop(context);

      if (success) {
        // Account created successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );

        // Navigate to home or next screen
        // TODO: Navigate to home screen or dashboard
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.errorMessage ?? 'Verification failed')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 6 digits')),
      );
    }
  }

  void _handleResend() {
    // Reset OTP fields
    for (var controller in otpControllers) {
      controller.clear();
    }
    setState(() {
      timeLeft = 154; // Reset timer to 2:34
      canResend = false;
    });
    _startTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP resent to your number')),
    );
    // TODO: Call resend OTP API
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                                margin: EdgeInsets.only(right: index < 2 ? 5 : 0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: index < 3
                                      ? AppTheme.primaryTeal
                                      : AppTheme.primaryTeal.withValues(alpha: 0.3),
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

