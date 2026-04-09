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
  Future<bool> createAccountAfterOTPVerification() async {
    if (_pendingSignupData == null) {
      _errorMessage = 'Signup data not found. Please try again.';
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _pendingSignupData!['email'],
        password: _pendingSignupData!['password'],
      );

      // Get the user ID
      String uid = userCredential.user!.uid;

      // Store user data in Firestore
      await _firestore.collection('users').doc(uid).set({
        'username': _pendingSignupData!['username'],
        'email': _pendingSignupData!['email'],
        'phoneNumber': _pendingSignupData!['phoneNumber'],
        'role': _pendingSignupData!['role'],
        'createdAt': Timestamp.now(),
      });

      // Clear pending data after successful signup
      _pendingSignupData = null;

      _isLoading = false;
      notifyListeners();
      return true; // Success
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'An error occurred';
      _isLoading = false;
      notifyListeners();
      return false; // Failure
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
