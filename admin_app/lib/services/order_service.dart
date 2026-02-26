import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_app/models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createOrder(OrderModel order) async {
    DocumentReference ref = await _firestore.collection('orders').add(order.toMap());
    return ref.id;
  }

  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap({...doc.data(), 'orderId': doc.id}))
            .toList());
  }

  Stream<List<OrderModel>> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap({...doc.data(), 'orderId': doc.id}))
            .toList());
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
    });
  }

  Future<OrderModel?> getOrderByQR(String qrCode) async {
    QuerySnapshot snapshot = await _firestore
        .collection('orders')
        .where('qrCode', isEqualTo: qrCode)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return OrderModel.fromMap({
      ...snapshot.docs.first.data() as Map<String, dynamic>,
      'orderId': snapshot.docs.first.id,
    });
  }
}