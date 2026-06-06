import 'package:cloud_firestore/cloud_firestore.dart';

class ConsultationRequestModel {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String note; // symptoms / reason
  final String status; // pending | accepted | rejected
  final DateTime createdAt;

  const ConsultationRequestModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.note,
    required this.status,
    required this.createdAt,
  });

  factory ConsultationRequestModel.fromMap(
      Map<String, dynamic> data, String id) {
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.now();
    }

    return ConsultationRequestModel(
      id: id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? 'Patient',
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? 'Doctor',
      note: data['note'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: parseDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'patientId': patientId,
        'patientName': patientName,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'note': note,
        'status': status,
        'createdAt': createdAt,
      };
}
