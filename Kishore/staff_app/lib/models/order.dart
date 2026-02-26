import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String userId;
  final double totalAmount;
  final String status;
  final String paymentStatus;
  final String phone;
  final String qrCode;
  final DateTime createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.phone,
    required this.qrCode,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      totalAmount: (json['amount'] ?? json['total_amount'] ?? json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      paymentStatus: json['payment_status'] ?? json['paymentStatus'] ?? 'unpaid',
      phone: json['phone'] ?? '',
      qrCode: json['qr_code'] ?? '',
      createdAt: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : (json['created_at'] is Timestamp
              ? (json['created_at'] as Timestamp).toDate()
              : DateTime.now()),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class OrderItem {
  final String foodItemId;
  final String name;
  final double price;
  final int quantity;

  OrderItem({
    required this.foodItemId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      foodItemId: json['id'] ?? json['food_item_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['qty'] ?? json['quantity'] ?? 0,
    );
  }
}