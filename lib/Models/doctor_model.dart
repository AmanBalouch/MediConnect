import 'package:cloud_firestore/cloud_firestore.dart';

/// Doctor Model
///
/// Represents a doctor's professional details
/// Used for storing and retrieving doctor information from Firestore
///
class DoctorModel {
  final String uid;
  final String pmdcLicenseNumber;
  final String cnicNumber; // added CNIC
  final List<String> specializations; // changed to list
  final String degree;
  final String yearsOfExperience;
  final String? clinicName;
  final String? clinicAddress;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;
  final String? profileImageUrl;
  final String? name;
  final String? email;
  final double? rating;
  final int? consultationFee;

  DoctorModel({
    required this.uid,
    required this.pmdcLicenseNumber,
    required this.cnicNumber,
    required this.specializations,
    required this.degree,
    required this.yearsOfExperience,
    this.clinicName,
    this.clinicAddress,
    required this.createdAt,
    required this.updatedAt,
    required this.isVerified,
    this.profileImageUrl,
    this.name,
    this.email,
    this.rating,
    this.consultationFee,
  });

  factory DoctorModel.fromMap(Map<String, dynamic> data, String id) {
    // handle specializations being string or list
    List<String> specs = [];
    final rawSpecs =
        data['specializations'] ?? data['specialization'] ?? data['speciality'];
    if (rawSpecs is String) {
      specs = rawSpecs
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } else if (rawSpecs is List) {
      specs = rawSpecs
          .map((s) => s?.toString() ?? '')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      if (v is Timestamp) return v.toDate();
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return DoctorModel(
      uid: id,
      pmdcLicenseNumber: data['pmdcLicenseNumber'] ?? data['pmdc'] ?? '',
      cnicNumber: data['cnicNumber'] ?? data['cnic'] ?? '',
      specializations: specs,
      degree: data['degree'] ?? '',
      yearsOfExperience: data['yearsOfExperience'] ?? data['experience'] ?? '',
      clinicName: data['clinicName'],
      clinicAddress: data['clinicAddress'],
      createdAt: parseDate(data['createdAt']),
      updatedAt: parseDate(data['updatedAt']),
      isVerified: data['isVerified'] ?? false,
      profileImageUrl: data['profileImageUrl'] ?? data['photoURL'],
      name: data['name'],
      email: data['email'],
      rating: (data['rating'] as num?)?.toDouble(),
      consultationFee: data['consultationFee'] is int
          ? data['consultationFee'] as int
          : (data['consultationFee'] is num
                ? (data['consultationFee'] as num).toInt()
                : null),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pmdcLicenseNumber': pmdcLicenseNumber,
      'cnicNumber': cnicNumber,
      'specializations': specializations,
      'degree': degree,
      'yearsOfExperience': yearsOfExperience,
      'clinicName': clinicName,
      'clinicAddress': clinicAddress,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isVerified': isVerified,
      'profileImageUrl': profileImageUrl,
      'name': name,
      'email': email,
      'rating': rating,
      'consultationFee': consultationFee,
    };
  }
}
