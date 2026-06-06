import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mediconnectcode/Models/doctor_model.dart';
import 'package:mediconnectcode/Utils/input_validator.dart';

/// Doctor Details ViewModel
///
/// Manages doctor details business logic
/// Responsibilities:
/// 1. Save doctor professional details
/// 2. Validate PMDC license number
/// 3. Verify doctor credentials
/// 4. Manage loading and error states
/// 5. Notify UI of state changes
///
class DoctorDetailsViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  DoctorModel? _doctorDetails;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  DoctorModel? get doctorDetails => _doctorDetails;

  /// Save doctor details to Firestore
  ///
  /// Business Logic:
  /// 1. Validate all required fields
  /// 2. Validate PMDC license format
  /// 3. Validate CNIC format
  /// 4. Check if PMDC license already exists for another user
  /// 5. Create DoctorModel instance
  /// 6. Save to Firestore under 'pending_doctor_requests' collection (NOT directly to doctors)
  /// 7. Admin reviews and approves → moved to 'doctors' collection
  /// 8. Return success/failure
  ///
  Future<bool> saveDoctorDetails({
    required String pmdcLicense,
    required String cnicNumber,
    required String specialization,
    required String degree,
    required String experience,
    required String clinicName,
    required String clinicAddress,
    required String consultationFee,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      // Validate required fields
      if (pmdcLicense.isEmpty) {
        throw Exception('PMDC License Number is required');
      }
      if (cnicNumber.isEmpty) {
        throw Exception('CNIC Number is required');
      }
      if (specialization.isEmpty) {
        throw Exception('Specialization is required');
      }
      if (degree.isEmpty) {
        throw Exception('At least one degree must be selected');
      }
      if (experience.isEmpty) {
        throw Exception('Years of experience is required');
      }
      if (consultationFee.isEmpty) {
        throw Exception('Consultation fee is required');
      }
      // Fee must be a valid number
      final feeValue = int.tryParse(consultationFee);
      if (feeValue == null || feeValue <= 0) {
        throw Exception('Please enter a valid consultation fee');
      }

      // Validate PMDC license format (e.g., 12345-P)
      if (!InputValidator.validatePMDC(pmdcLicense)) {
        throw Exception(InputValidator.getPMDCErrorMessage(pmdcLicense));
      }

      // Validate CNIC format (e.g., 12345-1234567-1)
      if (!InputValidator.validateCNIC(cnicNumber)) {
        throw Exception(InputValidator.getCNICErrorMessage(cnicNumber));
      }

      // Get current user
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Check if PMDC license already exists in doctors collection for another doctor
      final existingDoctor = await _firestore
          .collection('doctors')
          .where('pmdcLicenseNumber', isEqualTo: pmdcLicense)
          .get();

      if (existingDoctor.docs.any((doc) => doc.id != currentUser.uid)) {
        throw Exception('This PMDC License Number is already registered');
      }

      // Check if PMDC license already exists in pending requests for another doctor
      final pendingDoctor = await _firestore
          .collection('pending_doctor_requests')
          .where('pmdcLicenseNumber', isEqualTo: pmdcLicense)
          .get();

      if (pendingDoctor.docs.any((doc) => doc.id != currentUser.uid)) {
        throw Exception('This PMDC License Number is already pending review');
      }

      final existingApprovedDoc = await _firestore
          .collection('doctors')
          .doc(currentUser.uid)
          .get();

      // Fetch doctor's name from users collection
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final doctorName = userDoc.data()?['username']?.toString().trim();

      // Convert specialization to list
      List<String> specializationsList = specialization
          .split(',')
          .map((s) => s.trim())
          .toList();

      // Create DoctorModel instance
      final doctorModel = DoctorModel(
        uid: currentUser.uid,
        pmdcLicenseNumber: pmdcLicense,
        cnicNumber: cnicNumber,
        specializations: specializationsList,
        degree: degree,
        yearsOfExperience: experience,
        clinicName: clinicName.isNotEmpty ? clinicName : null,
        clinicAddress: clinicAddress.isNotEmpty ? clinicAddress : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isVerified: false,
        consultationFee: int.tryParse(consultationFee),
        name: (doctorName != null && doctorName.isNotEmpty) ? doctorName : null,
      );

      // Save to pending_doctor_requests collection (NOT to doctors collection)
      // Admin will review and approve, then move to doctors collection
      await _firestore
          .collection('pending_doctor_requests')
          .doc(currentUser.uid)
          .set({
            'uid': doctorModel.uid,
            'name': doctorModel.name,
            'pmdcLicenseNumber': doctorModel.pmdcLicenseNumber,
            'cnicNumber': doctorModel.cnicNumber,
            'specializations': doctorModel.specializations,
            'degree': doctorModel.degree,
            'yearsOfExperience': doctorModel.yearsOfExperience,
            'clinicName': doctorModel.clinicName,
            'clinicAddress': doctorModel.clinicAddress,
            'createdAt': doctorModel.createdAt,
            'updatedAt': doctorModel.updatedAt,
            'isVerified': false,
            'consultationFee': doctorModel.consultationFee,
            'status': existingApprovedDoc.exists
                ? 'changes_requested'
                : 'pending',
            'requestSubmittedAt': DateTime.now(),
          });

      _doctorDetails = doctorModel;
      _successMessage = 'Doctor details submitted for review!';
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Fetch existing doctor details
  ///
  /// Checks both 'pending_doctor_requests' and 'doctors' collections
  /// Priority: pending_doctor_requests (latest request / changes requested) > doctors (approved)
  ///
  Future<bool> fetchDoctorDetails() async {
    try {
      _isLoading = true;
      notifyListeners();

      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // First check if there is a pending request for this doctor
      final pendingSnapshot = await _firestore
          .collection('pending_doctor_requests')
          .doc(currentUser.uid)
          .get();

      if (pendingSnapshot.exists) {
        final data = pendingSnapshot.data() as Map<String, dynamic>;
        _doctorDetails = DoctorModel.fromMap(data, currentUser.uid);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      // If not pending, check if doctor is already approved in doctors collection
      final approvedSnapshot = await _firestore
          .collection('doctors')
          .doc(currentUser.uid)
          .get();

      if (approvedSnapshot.exists) {
        final data = approvedSnapshot.data() as Map<String, dynamic>;
        _doctorDetails = DoctorModel.fromMap(data, currentUser.uid);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear messages
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
