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
  /// 4. Check if PMDC license already exists in pending or approved doctors
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

      // Check if PMDC license already exists in doctors collection
      final existingDoctor = await _firestore
          .collection('doctors')
          .where('pmdcLicenseNumber', isEqualTo: pmdcLicense)
          .get();

      if (existingDoctor.docs.isNotEmpty) {
        throw Exception('This PMDC License Number is already registered');
      }

      // Check if PMDC license already exists in pending requests
      final pendingDoctor = await _firestore
          .collection('pending_doctor_requests')
          .where('pmdcLicenseNumber', isEqualTo: pmdcLicense)
          .get();

      if (pendingDoctor.docs.isNotEmpty) {
        throw Exception('This PMDC License Number is already pending review');
      }

      // Create DoctorModel instance
      final doctorModel = DoctorModel(
        uid: currentUser.uid,
        pmdcLicenseNumber: pmdcLicense,
        cnicNumber: cnicNumber,
        specialization: specialization,
        degree: degree,
        yearsOfExperience: experience,
        clinicName: clinicName.isNotEmpty ? clinicName : null,
        clinicAddress: clinicAddress.isNotEmpty ? clinicAddress : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isVerified: false,
      );

      // Save to pending_doctor_requests collection (NOT to doctors collection)
      // Admin will review and approve, then move to doctors collection
      await _firestore
          .collection('pending_doctor_requests')
          .doc(currentUser.uid)
          .set({
            'uid': doctorModel.uid,
            'pmdcLicenseNumber': doctorModel.pmdcLicenseNumber,
            'cnicNumber': doctorModel.cnicNumber,
            'specialization': doctorModel.specialization,
            'degree': doctorModel.degree,
            'yearsOfExperience': doctorModel.yearsOfExperience,
            'clinicName': doctorModel.clinicName,
            'clinicAddress': doctorModel.clinicAddress,
            'createdAt': doctorModel.createdAt,
            'updatedAt': doctorModel.updatedAt,
            'isVerified': false,
            'status': 'pending', // pending → approved → rejected
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
  /// Priority: doctors collection (approved) > pending_doctor_requests (pending)
  ///
  Future<bool> fetchDoctorDetails() async {
    try {
      _isLoading = true;
      notifyListeners();

      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // First check if doctor is already approved in doctors collection
      final approvedSnapshot = await _firestore
          .collection('doctors')
          .doc(currentUser.uid)
          .get();

      if (approvedSnapshot.exists) {
        final data = approvedSnapshot.data() as Map<String, dynamic>;
        _doctorDetails = DoctorModel(
          uid: currentUser.uid,
          pmdcLicenseNumber: data['pmdcLicenseNumber'] ?? '',
          cnicNumber: data['cnicNumber'] ?? '',
          specialization: data['specialization'] ?? '',
          degree: data['degree'] ?? '',
          yearsOfExperience: data['yearsOfExperience'] ?? '',
          clinicName: data['clinicName'],
          clinicAddress: data['clinicAddress'],
          createdAt: data['createdAt'] != null
              ? (data['createdAt'] is DateTime
                    ? data['createdAt']
                    : DateTime.parse(data['createdAt']))
              : DateTime.now(),
          updatedAt: data['updatedAt'] != null
              ? (data['updatedAt'] is DateTime
                    ? data['updatedAt']
                    : DateTime.parse(data['updatedAt']))
              : DateTime.now(),
          isVerified: data['isVerified'] ?? false,
        );
        _isLoading = false;
        notifyListeners();
        return true;
      }

      // If not approved, check pending_doctor_requests collection
      final pendingSnapshot = await _firestore
          .collection('pending_doctor_requests')
          .doc(currentUser.uid)
          .get();

      if (pendingSnapshot.exists) {
        final data = pendingSnapshot.data() as Map<String, dynamic>;
        _doctorDetails = DoctorModel(
          uid: currentUser.uid,
          pmdcLicenseNumber: data['pmdcLicenseNumber'] ?? '',
          cnicNumber: data['cnicNumber'] ?? '',
          specialization: data['specialization'] ?? '',
          degree: data['degree'] ?? '',
          yearsOfExperience: data['yearsOfExperience'] ?? '',
          clinicName: data['clinicName'],
          clinicAddress: data['clinicAddress'],
          createdAt: data['createdAt'] != null
              ? (data['createdAt'] is DateTime
                    ? data['createdAt']
                    : DateTime.parse(data['createdAt']))
              : DateTime.now(),
          updatedAt: data['updatedAt'] != null
              ? (data['updatedAt'] is DateTime
                    ? data['updatedAt']
                    : DateTime.parse(data['updatedAt']))
              : DateTime.now(),
          isVerified: false, // Always false for pending requests
        );
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
