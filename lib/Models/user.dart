import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String username;
  final String email;
  final String phoneNumber;
  final int role; // 0 for patient, 1 for doctor
  final DateTime createdAt;

  User({
    required this.uid,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.createdAt,
  });

  // Factory constructor to create User from Firestore document
  factory User.fromMap(String uid, Map<String, dynamic> data) {
    return User(
      uid: uid,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      role: data['role'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Method to convert User to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
