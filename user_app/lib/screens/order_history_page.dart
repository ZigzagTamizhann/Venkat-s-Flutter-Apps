import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view history')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found'));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderData = orders[index].data() as Map<String, dynamic>;
              final totalAmount = orderData['totalAmount'] ?? 0.0;
              final status = orderData['status'] ?? 'Unknown';
              final timestamp = orderData['createdAt'] as Timestamp?;
              final date = timestamp?.toDate() ?? DateTime.now();
              final items = orderData['items'] as List<dynamic>? ?? [];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ExpansionTile(
                  title: Text(
                    'Order on ${DateFormat('MMM dd, yyyy - hh:mm a').format(date)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Total: ₹$totalAmount  •  Status: $status',
                    style: TextStyle(
                      color: status == 'completed' ? Colors.green : Colors.orange,
                    ),
                  ),
                  children: items.map<Widget>((item) {
                    // Handling item map structure
                    final itemMap = item as Map<String, dynamic>;
                    return ListTile(
                      title: Text(itemMap['itemName'] ?? 'Item'),
                      trailing: Text('x${itemMap['quantity'] ?? 1}'),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
