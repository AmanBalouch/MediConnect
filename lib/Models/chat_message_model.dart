import 'package:cloud_firestore/cloud_firestore.dart';

// Message types
class MessageType {
  static const String text = 'text';
  static const String paymentRequest = 'payment_request';
}

// Message status
class MessageStatus {
  static const String sending = 'sending'; // local only — not yet in Firestore
  static const String sent    = 'sent';    // saved in Firestore
  static const String seen    = 'seen';    // other party opened the chat
  static const String failed  = 'failed';  // send failed (no internet etc.)
}

class ChatMessageModel {
  final String id;
  final String senderId;
  final String type;   // text | payment_request
  final String text;
  final String status; // sending | sent | seen | failed
  final DateTime createdAt;

  // Only filled when type == payment_request
  final PaymentDetails? paymentDetails;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.type,
    required this.text,
    required this.createdAt,
    this.status = MessageStatus.sent,
    this.paymentDetails,
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> data, String id) {
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.now();
    }

    PaymentDetails? details;
    if (data['paymentDetails'] != null) {
      details = PaymentDetails.fromMap(
          data['paymentDetails'] as Map<String, dynamic>);
    }

    return ChatMessageModel(
      id: id,
      senderId: data['senderId'] ?? '',
      type: data['type'] ?? MessageType.text,
      text: data['text'] ?? '',
      status: data['status'] ?? MessageStatus.sent,
      createdAt: parseDate(data['createdAt']),
      paymentDetails: details,
    );
  }

  // copyWith — used to update status locally
  ChatMessageModel copyWith({String? status}) => ChatMessageModel(
        id: id,
        senderId: senderId,
        type: type,
        text: text,
        status: status ?? this.status,
        createdAt: createdAt,
        paymentDetails: paymentDetails,
      );

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'type': type,
        'text': text,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
        if (paymentDetails != null)
          'paymentDetails': paymentDetails!.toMap(),
      };
}

class PaymentDetails {
  final String accountType;
  final String accountNumber;
  final String accountHolderName;
  final int amount;

  const PaymentDetails({
    required this.accountType,
    required this.accountNumber,
    required this.accountHolderName,
    required this.amount,
  });

  factory PaymentDetails.fromMap(Map<String, dynamic> data) {
    return PaymentDetails(
      accountType: data['accountType'] ?? '',
      accountNumber: data['accountNumber'] ?? '',
      accountHolderName: data['accountHolderName'] ?? '',
      amount: (data['amount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'accountType': accountType,
        'accountNumber': accountNumber,
        'accountHolderName': accountHolderName,
        'amount': amount,
      };
}
