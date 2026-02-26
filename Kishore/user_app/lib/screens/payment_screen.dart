import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/cart_item.dart';
import 'order_history_screen.dart';

class PaymentScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalAmount;
  final String shopId;

  const PaymentScreen({
    super.key,
    required this.cartItems,
    required this.totalAmount,
    required this.shopId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;

  Future<void> _confirmPayment() async {
    setState(() => _isProcessing = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final orderRef = FirebaseFirestore.instance
          .collection('profiles')
          .doc(user.uid)
          .collection('orders')
          .doc();

      final orderData = {
        'id': orderRef.id,
        'shopId': widget.shopId,
        'amount': widget.totalAmount,
        'status': 'Pending',
        'date': FieldValue.serverTimestamp(),
        'items': widget.cartItems.map((item) => {
          'id': item.id,
          'name': item.name,
          'price': item.price,
          'qty': item.quantity,
        }).toList(),
      };

      await orderRef.set(orderData);

      await FirebaseFirestore.instance.collection('main_orders').doc(orderRef.id).set({
        ...orderData,
        'shopId': widget.shopId,
        'userId': user.uid,
        'userPhone': user.email!.split('@')[0],
        'status': 'Pending',
        'orderDate': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('shopkeepers')
          .doc(widget.shopId)
          .collection('sales')
          .doc(orderRef.id)
          .set({
            ...orderData,
            'userId': user.uid,
            'description': widget.cartItems.map((e) => "${e.quantity} x ${e.name ?? 'Item'}").join(", "),
          });

      final phone = user.email!.split('@')[0];
      
      final cartSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(phone)
          .collection('order_details')
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in cartSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34C759).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.checkmark_alt_circle_fill,
                    color: Color(0xFF34C759),
                    size: 50,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Payment Successful!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "₹${widget.totalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF007AFF),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      QrImageView(
                        data: orderRef.id,
                        version: QrVersions.auto,
                        size: 120.0,
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF1C1C1E),
                        ),
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Show this QR at counter",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Order ID: ${orderRef.id.substring(0, 8)}...",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                            (route) => route.isFirst,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007AFF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "View Orders",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Payment failed: ${e.toString().split(':').last}"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: const Color(0xFFFF3B30),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text("Payment"),
        centerTitle: true,
        backgroundColor: const Color(0xFFF2F2F7),
        foregroundColor: const Color(0xFF007AFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Order Summary",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.cartItems.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = widget.cartItems[index];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name ?? 'Item',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1C1C1E),
                                ),
                              ),
                              Text(
                                "${item.quantity} × ₹${item.price ?? 0}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "₹${((item.price ?? 0) * item.quantity).toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF007AFF),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      Text(
                        "₹${widget.totalAmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF007AFF),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isProcessing ? null : _confirmPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isProcessing 
                ? const CupertinoActivityIndicator(color: Colors.white)
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.lock_fill),
                      SizedBox(width: 8),
                      Text(
                        "Confirm Payment",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                "Secure payment powered by DeepFood",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}