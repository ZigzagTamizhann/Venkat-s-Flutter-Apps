import 'package:cloud_firestore/cloud_firestore.dart';

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
      items: (map['items'] as List).map((e) => OrderItem.fromMap(e)).toList(),
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

class OrderItem {
  final String itemId;
  final String itemName;
  final int quantity;
  final double price;

  OrderItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      itemId: map['itemId'] ?? '',
      itemName: map['itemName'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'price': price,
    };
  }
}