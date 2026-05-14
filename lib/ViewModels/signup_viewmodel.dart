import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // Method to store signup data temporarily (before OTP verification)
  Map<String, dynamic>? _pendingSignupData;

  // Method to save signup data before OTP verification
  void savePendingSignupData({
    required String email,
    required String password,
    required String username,
    required String phoneNumber,
    required int role,
  }) {
    _pendingSignupData = {
      'email': email,
      'password': password,
      'username': username,
      'phoneNumber': phoneNumber,
      'role': role,
    };
  }

  // Method to create account after OTP verification
  ///
  /// Business Logic:
  /// 1. Get current user from phone authentication
  /// 2. Link email/password credential to phone-authenticated user
  /// 3. Store user data in Firestore
  /// 4. Clear pending data
  ///
  Future<bool> createAccountAfterOTPVerification() async {
    if (_pendingSignupData == null) {
      _errorMessage = 'Signup data not found. Please try again.';
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get current user (created by phone authentication)
      final currentUser = _auth.currentUser;

      if (currentUser == null) {
        _errorMessage = 'User not authenticated. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Get the user ID from phone authentication
      String uid = currentUser.uid;

      // Link email/password credential to the phone-authenticated user
      try {
        final emailCredential = EmailAuthProvider.credential(
          email: _pendingSignupData!['email'],
          password: _pendingSignupData!['password'],
        );

        await currentUser.linkWithCredential(emailCredential);
        print('Email/password credential linked successfully');
      } catch (e) {
        print('Error linking email/password: $e');
        // If linking fails, we can still continue and store data
        // User can use phone or email/password later
      }

      // Store user data in Firestore
      await _firestore.collection('users').doc(uid).set({
        'username': _pendingSignupData!['username'],
        'email': _pendingSignupData!['email'],
        'phoneNumber': _pendingSignupData!['phoneNumber'],
        'role': _pendingSignupData!['role'],
        'createdAt': Timestamp.now(),
        'phoneVerified': true,
        'emailVerified': false,
      });

      // Clear pending data after successful signup
      _pendingSignupData = null;

      _isLoading = false;
      notifyListeners();
      return true; // Success
    } catch (e) {
      _errorMessage = 'Failed to create account: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
