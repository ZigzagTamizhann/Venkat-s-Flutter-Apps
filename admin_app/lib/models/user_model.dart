import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String email;
  final String name;
  final String phone;
  final String role; // 'admin', 'staff', 'user'
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}