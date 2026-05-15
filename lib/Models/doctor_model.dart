/// Doctor Model
///
/// Represents a doctor's professional details
/// Used for storing and retrieving doctor information from Firestore
///
class DoctorModel {
  final String uid;
  final String pmdcLicenseNumber;
  final String cnicNumber;
  final String specialization;
  final String degree;
  final String yearsOfExperience;
  final String? clinicName;
  final String? clinicAddress;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;

  DoctorModel({
    required this.uid,
    required this.pmdcLicenseNumber,
    required this.cnicNumber,
    required this.specialization,
    required this.degree,
    required this.yearsOfExperience,
    this.clinicName,
    this.clinicAddress,
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
  });

  /// Create a copy of DoctorModel with updated fields
  DoctorModel copyWith({
    String? uid,
    String? pmdcLicenseNumber,
    String? cnicNumber,
    String? specialization,
    String? degree,
    String? yearsOfExperience,
    String? clinicName,
    String? clinicAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
  }) {
    return DoctorModel(
      uid: uid ?? this.uid,
      pmdcLicenseNumber: pmdcLicenseNumber ?? this.pmdcLicenseNumber,
      cnicNumber: cnicNumber ?? this.cnicNumber,
      specialization: specialization ?? this.specialization,
      degree: degree ?? this.degree,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      clinicName: clinicName ?? this.clinicName,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
