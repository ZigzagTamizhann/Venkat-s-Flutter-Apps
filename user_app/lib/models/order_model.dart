import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/models/order_item.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final String status; // 'pending', 'preparing', 'ready', 'completed'
  final String qrCode;
  final DateTime createdAt;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.qrCode,
    required this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['orderId'] ?? '',
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? '',
      qrCode: map['qrCode'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'items': items.map((e) => e.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'qrCode': qrCode,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
