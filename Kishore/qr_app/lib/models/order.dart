import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final double amount;
  final DateTime createdAt;
  final List<OrderItem> items;
  final String status;
  final String? phone;
  final String paymentStatus;
  final String shopId;
  final String userId;

  Order({
    required this.id,
    required this.amount,
    required this.createdAt,
    required this.items,
    required this.status,
    this.phone,
    this.paymentStatus = 'Paid',
    required this.shopId,
    required this.userId,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Order(
      id: doc.id,
      amount: double.tryParse(data['amount']?.toString() ?? '0') ?? 0.0,
      createdAt: (data['date'] as Timestamp?)?.toDate() ??
          (data['orderDate'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      items: (data['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      status: data['status']?.toString() ?? 'Pending',
      phone: data['userPhone']?.toString(),
      paymentStatus: 'Paid',
      shopId: data['shopId']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
    );
  }
}

class OrderItem {
  final String id;
  final String name;
  final double price;
  final int quantity;

  OrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  double get totalPrice => price * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      price: double.tryParse(map['price']?.toString() ?? '0') ?? 0.0,
      quantity: int.tryParse(map['qty']?.toString() ?? '0') ?? 0,
    );
  }
}
