import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleModel {
  final String id;
  final String doctorId;
  final String patientId;
  final String patientName;
  final String roomId; // chat room to open on Join
  final DateTime scheduledTime;
  final DateTime createdAt;

  const ScheduleModel({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
    required this.roomId,
    required this.scheduledTime,
    required this.createdAt,
  });

  factory ScheduleModel.fromMap(Map<String, dynamic> data, String id) {
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.now();
    }

    return ScheduleModel(
      id: id,
      doctorId: data['doctorId'] ?? '',
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? 'Patient',
      roomId: data['roomId'] ?? '',
      scheduledTime: parseDate(data['scheduledTime']),
      createdAt: parseDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'doctorId': doctorId,
        'patientId': patientId,
        'patientName': patientName,
        'roomId': roomId,
        'scheduledTime': scheduledTime,
        'createdAt': createdAt,
      };
}
