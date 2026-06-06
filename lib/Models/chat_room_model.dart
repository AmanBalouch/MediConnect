import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isBlocked;
  final String? blockedBy; // uid of whoever blocked
  final DateTime createdAt;

  const ChatRoomModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.isBlocked,
    this.blockedBy,
    required this.createdAt,
  });

  factory ChatRoomModel.fromMap(Map<String, dynamic> data, String id) {
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.now();
    }

    return ChatRoomModel(
      id: id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? 'Patient',
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? 'Doctor',
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: parseDate(data['lastMessageTime']),
      isBlocked: data['isBlocked'] ?? false,
      blockedBy: data['blockedBy'],
      createdAt: parseDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'patientId': patientId,
        'patientName': patientName,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'lastMessage': lastMessage,
        'lastMessageTime': lastMessageTime,
        'isBlocked': isBlocked,
        'blockedBy': blockedBy,
        'createdAt': createdAt,
      };
}
