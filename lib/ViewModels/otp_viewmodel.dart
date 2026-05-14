import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// OTP ViewModel
///
/// Manages phone number verification logic using Firebase Authentication
/// Follows MVVM pattern - separates business logic from UI
///
/// Responsibilities:
/// 1. Handle Firebase phone verification
/// 2. Manage OTP verification state
/// 3. Handle errors and success states
/// 4. Notify UI of state changes
///
class OTPViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // State variables
  String? _phoneNumber;
  String? _verificationId;
  bool _isOTPSent = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  String? get phoneNumber => _phoneNumber;
  String? get verificationId => _verificationId;
  bool get isOTPSent => _isOTPSent;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Send OTP via Firebase Authentication
  ///
  /// Business Logic:
  /// 1. Validate phone number format
  /// 2. Call FirebaseAuth.instance.verifyPhoneNumber()
  /// 3. Handle verification callbacks:
  ///    - codeSent: Store verification ID
  ///    - verificationCompleted: Auto sign-in (Android)
  ///    - verificationFailed: Show error
  ///    - codeAutoRetrievalTimeout: Store verification ID
  /// 4. Update state and notify listeners
  ///
  Future<bool> sendOTP(String phoneNumber) async {
    try {
      _phoneNumber = phoneNumber;
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      print('Sending OTP to: $phoneNumber');

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),

        // Called when OTP is sent successfully
        codeSent: (String verificationId, int? resendToken) {
          print('OTP sent successfully. Verification ID: $verificationId');
          _verificationId = verificationId;
          _isOTPSent = true;
          _successMessage = 'OTP sent to $phoneNumber';
          _isLoading = false;
          notifyListeners();
        },

        // Called if verification fails
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed: ${e.code} - ${e.message}');
          _errorMessage = _getErrorMessage(e);
          _isLoading = false;
          notifyListeners();
        },

        // Called when code is auto-retrieved (Android only)
        verificationCompleted: (PhoneAuthCredential credential) {
          print('Verification completed automatically');
          _isLoading = false;
          notifyListeners();
          // Let the screen handle auto sign-in
        },

        // Called when code auto-retrieval times out
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Code auto-retrieval timeout. Verification ID: $verificationId');
          _verificationId = verificationId;
          _isLoading = false;
          notifyListeners();
        },
      );

      return _isOTPSent;
    } catch (e) {
      print('Error sending OTP: $e');
      _errorMessage = 'Error sending OTP: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Verify OTP code with Firebase
  ///
  /// Business Logic:
  /// 1. Validate OTP length
  /// 2. Check if verification ID exists
  /// 3. Create PhoneAuthCredential using verification ID + OTP
  /// 4. Return credential for screen to sign in
  /// 5. Handle errors with user-friendly messages
  ///
  Future<PhoneAuthCredential?> verifyOTP(String otp) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Validate OTP format
      if (otp.length != 6) {
        _errorMessage = 'OTP must be 6 digits';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
        _errorMessage = 'OTP must contain only numbers';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      // Check if verification ID exists
      if (_verificationId == null) {
        _errorMessage = 'Verification ID not found. Please request OTP again.';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      print('Verifying OTP: $otp with Verification ID: $_verificationId');

      // Create credential with verification ID and OTP
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      _isLoading = false;
      _successMessage = 'OTP verified successfully';
      notifyListeners();
      return credential;
    } catch (e) {
      print('Error verifying OTP: $e');

      String errorMessage = 'Invalid OTP. Please try again.';
      if (e is FirebaseAuthException) {
        errorMessage = _getErrorMessage(e);
      }

      _errorMessage = errorMessage;
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Resend OTP
  Future<bool> resendOTP() async {
    try {
      if (_phoneNumber == null) {
        _errorMessage = 'Phone number not found. Please try again.';
        notifyListeners();
        return false;
      }

      print('Resending OTP to: $_phoneNumber');
      _errorMessage = null;
      return await sendOTP(_phoneNumber!);
    } catch (e) {
      print('Error resending OTP: $e');
      _errorMessage = 'Failed to resend OTP: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
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

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset state
  void resetState() {
    _phoneNumber = null;
    _verificationId = null;
    _isOTPSent = false;
    _isLoading = false;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}

