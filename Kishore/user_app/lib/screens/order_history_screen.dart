import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:qr_flutter/qr_flutter.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return const Color(0xFF007AFF);
      case 'pending':
        return const Color(0xFFFF9500);
      case 'prepare':
        return const Color(0xFF5856D6);
      case 'delivery':
      case 'completed':
        return const Color(0xFF34C759);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F2F7),
        body: Center(child: Text('Please login first')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Order History'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF2F2F7),
        foregroundColor: const Color(0xFF007AFF),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('profiles')
            .doc(uid)
            .collection('orders')
            .orderBy('date', descending: true)
            .limit(7)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_triangle_fill,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}'.split(':').last,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator(radius: 18));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.clock,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recent orders',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your orders will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final profileData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final orderId = snapshot.data!.docs[index].id;

              return TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * 50)),
                curve: Curves.easeOutQuad,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('orders')
                      .doc(orderId)
                      .snapshots(),
                  builder: (context, orderSnapshot) {
                    final orderData = orderSnapshot.data?.data() as Map<String, dynamic>?;
                    final status = orderData?['status'] ?? profileData['status'] ?? 'Pending';
                    final isDelivered = status.toLowerCase() == 'delivered' || status.toLowerCase() == 'completed' || status.toLowerCase() == 'delivery';

                    final date = (profileData['date'] as Timestamp?)?.toDate() ?? DateTime.now();
                    final amount = profileData['amount'] ?? 0;
                    final items = profileData['items'] as List<dynamic>? ?? [];

                    return Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF007AFF),
                              const Color(0xFF5856D6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isDelivered ? CupertinoIcons.doc_text_fill : CupertinoIcons.tickets,
                          color: Colors.white,
                        ),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹$amount',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Color(0xFF1C1C1E),
                              letterSpacing: -0.3,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: _getStatusColor(status),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Order #${orderId.substring(0, 8)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              ...items.map<Widget>((item) {
                                final price = item['price'] ?? 0;
                                final qty = item['qty'] ?? 1;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name'] ?? 'Item',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF1C1C1E),
                                            ),
                                          ),
                                          Text(
                                            '$qty × ₹$price',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '₹${price * qty}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF007AFF),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const Divider(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: isDelivered ? null : () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(24),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(24),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF2F2F7),
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: QrImageView(
                                                  data: orderId,
                                                  version: QrVersions.auto,
                                                  size: 150.0,
                                                  dataModuleStyle: const QrDataModuleStyle(
                                                    dataModuleShape: QrDataModuleShape.square,
                                                    color: Color(0xFF1C1C1E),
                                                  ),
                                                  eyeStyle: const QrEyeStyle(
                                                    eyeShape: QrEyeShape.square,
                                                    color: Color(0xFF1C1C1E),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              const Text(
                                                "Show this QR at counter",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF1C1C1E),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "Order ID: $orderId",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                              const SizedBox(height: 24),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: const Color(0xFF007AFF),
                                                ),
                                                child: const Text("Close"),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    isDelivered ? CupertinoIcons.checkmark_alt_circle_fill : CupertinoIcons.qrcode,
                                    color: isDelivered ? const Color(0xFF34C759) : Colors.white,
                                  ),
                                  label: Text(
                                    isDelivered ? "Order Delivered" : "Show QR Code",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDelivered ? Colors.white : const Color(0xFF007AFF),
                                    foregroundColor: isDelivered ? const Color(0xFF34C759) : Colors.white,
                                    disabledBackgroundColor: Colors.grey.shade100,
                                    disabledForegroundColor: Colors.grey.shade400,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: isDelivered ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
