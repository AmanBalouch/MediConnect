import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Login ViewModel
///
/// Manages login business logic
/// Responsibilities:
/// 1. Handle email/phone login
/// 2. Handle password login
/// 3. Handle Google/Facebook login (TODO)
/// 4. Manage error states
/// 5. Notify UI of state changes
///
class LoginViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // State variables
  String? _email;
  String? _password;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _isPasswordVisible = false;

  // Getters
  String? get email => _email;
  String? get password => _password;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isPasswordVisible => _isPasswordVisible;

  /// Toggle password visibility
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  /// Sign in with email and password
  ///
  /// Business Logic:
  /// 1. Validate email/phone format
  /// 2. Validate password
  /// 3. Call Firebase authentication
  /// 4. Fetch user data from Firestore
  /// 5. Return success/failure
  ///
  Future<bool> signInWithEmailPassword(String emailOrPhone, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      // Validate inputs
      if (emailOrPhone.isEmpty) {
        _errorMessage = 'Please enter email or phone number';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password.isEmpty) {
        _errorMessage = 'Please enter password';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _errorMessage = 'Password must be at least 6 characters';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Determine if email or phone
      String email = emailOrPhone;
      if (!emailOrPhone.contains('@')) {
        // If not email, assume it's phone - need to find email from Firestore
        print('Phone number provided, fetching associated email...');
        email = await _getEmailFromPhoneNumber(emailOrPhone);
        if (email.isEmpty) {
          _errorMessage = 'Phone number not found. Please check and try again.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      print('Attempting sign in with email: $email');

      // Sign in with Firebase
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        _email = email;
        _password = password;
        _successMessage = 'Sign in successful';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Sign in failed. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get email from phone number in Firestore
  Future<String> _getEmailFromPhoneNumber(String phoneNumber) async {
    try {
      // Format phone number if needed
      String formattedPhone = phoneNumber;
      if (!formattedPhone.startsWith('+92')) {
        formattedPhone = '+92$phoneNumber';
      }

      // Query Firestore for user with this phone
      final querySnapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: formattedPhone)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['email'] ?? '';
      }
      return '';
    } catch (e) {
      print('Error fetching email from phone: $e');
      return '';
    }
  }

  /// Get user-friendly error message from Firebase exception
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'User not found. Please check your email/phone or sign up.';
      case 'wrong-password':
        return 'Invalid password. Please try again.';
      case 'invalid-email':
        return 'Invalid email address. Please check and try again.';
      case 'user-disabled':
        return 'This user account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      default:
        return 'Sign in failed: ${e.message}';
    }
  }

  /// Sign in with Google (TODO: Implement)
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // TODO: Implement Google sign-in
      print('Google sign-in not yet implemented');

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Google sign-in failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with Facebook (TODO: Implement)
  Future<bool> signInWithFacebook() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // TODO: Implement Facebook sign-in
      print('Facebook sign-in not yet implemented');

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Facebook sign-in failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset state
  void resetState() {
    _email = null;
    _password = null;
    _isLoading = false;
    _errorMessage = null;
    _successMessage = null;
    _isPasswordVisible = false;
    notifyListeners();
  }
}

