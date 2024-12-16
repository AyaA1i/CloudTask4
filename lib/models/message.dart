import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String username;
  String message;
  DateTime timestamp;

  Message({
    required this.username,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      username: map['username'] ?? '',
      message: map['message'] ?? '',
      timestamp: _parseDate(map['timestamp']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    }
    throw Exception("Invalid date format");
  }
}
