import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentAdminId = FirebaseAuth.instance.currentUser?.uid;

    return DefaultTabController(
      length: 2,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('orders')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Orders Management'),
                backgroundColor: Colors.white,
                elevation: 0,
              ),
              body: _buildErrorState(snapshot.error.toString()),
            );
          }

          if (!snapshot.hasData) {
            return _buildLoadingScaffold();
          }

          // Filter orders client-side
          final allOrders = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['user_created_by'] == currentAdminId;
          }).toList();
          
          // Calculate stats
          int notDeliveredCount = 0;
          int deliveredCount = 0;
          double totalRevenue = 0;
          DateTime? newestOrder;

          for (var doc in allOrders) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['Food_Delivered'] ?? 'not delivered';
            final amount = (data['total_amount'] as num?)?.toDouble() ?? 0;
            final timestamp = data['order_time'] as Timestamp?;
            
            if (status == 'delivered') {
              deliveredCount++;
              totalRevenue += amount;
            } else {
              notDeliveredCount++;
            }
            
            // Track newest order
            if (timestamp != null) {
              final orderTime = timestamp.toDate();
              if (newestOrder == null || orderTime.isAfter(newestOrder!)) {
                newestOrder = orderTime;
              }
            }
          }

          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              title: const Text('Orders Management'),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue[800],
              bottom: TabBar(
                indicatorColor: Colors.blue[700],
                labelColor: Colors.blue[700],
                unselectedLabelColor: Colors.grey[600],
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.pending_actions, size: 20),
                        const SizedBox(width: 6),
                        Text('Pending ($notDeliveredCount)'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 20),
                        const SizedBox(width: 6),
                        Text('Delivered ($deliveredCount)'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            body: Column(
              children: [
                // Statistics Cards
                _buildStatsCards(
                  pending: notDeliveredCount,
                  delivered: deliveredCount,
                  revenue: totalRevenue,
                  newestOrder: newestOrder,
                ),
                
                // Tab Content
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: TabBarView(
                      children: [
                        OrdersList(orders: allOrders, isDelivered: false),
                        OrdersList(orders: allOrders, isDelivered: true),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.blue[700],
              child: const Icon(Icons.add_chart_outlined, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders Management'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(Colors.blue[700]!),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading Orders...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red[400],
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Connection Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.length > 100 ? '${error.substring(0, 100)}...' : error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards({
    required int pending,
    required int delivered,
    required double revenue,
    required DateTime? newestOrder,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.pending_actions,
            value: pending.toString(),
            label: 'Pending Orders',
            color: Colors.orange[600]!,
            bgColor: Colors.orange[50]!,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.check_circle,
            value: delivered.toString(),
            label: 'Delivered',
            color: Colors.green[600]!,
            bgColor: Colors.green[50]!,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.currency_rupee,
            value: '₹${revenue.toStringAsFixed(0)}',
            label: 'Revenue',
            color: Colors.blue[600]!,
            bgColor: Colors.blue[50]!,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrdersList extends StatelessWidget {
  final bool isDelivered;
  final List<QueryDocumentSnapshot> orders;
  
  const OrdersList({
    super.key, 
    required this.isDelivered,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    final filteredDocs = orders.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['Food_Delivered'] ?? 'not delivered';
      return isDelivered ? status == 'delivered' : status != 'delivered';
    }).toList();

    if (filteredDocs.isEmpty) {
      return _buildEmptyState(isDelivered);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.separated(
        itemCount: filteredDocs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final doc = filteredDocs[index];
          final order = doc.data() as Map<String, dynamic>;

          // Extract data
          final tableName = order['table_name'] ?? 'Unknown Table';
          final totalAmount = order['total_amount']?.toString() ?? '0';
          final paymentStatus = order['payment_status'] ?? 'Pending';
          final orderTime = order['order_time'] as Timestamp?;
          final phoneNumber = doc.reference.parent.parent?.id ?? 'Unknown';
          final cartDetails = order['cart_details'] as List<dynamic>? ?? [];
          final email = order['email'] ?? '';

          
          // Format order time
          String timeText = 'Time not set';
          if (orderTime != null) {
            final date = orderTime.toDate();
            timeText = DateFormat('hh:mm a').format(date);
          }

          return _buildOrderCard( 
            context: context,
            doc: doc,
            tableName: tableName,
            email: email, // ✅ add
            totalAmount: totalAmount,
            paymentStatus: paymentStatus,
            phoneNumber: phoneNumber,
            cartDetails: cartDetails,
            timeText: timeText,
            isDelivered: isDelivered,
          );

        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDelivered) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isDelivered ? Icons.inventory_2_outlined : Icons.shopping_bag_outlined,
            color: Colors.grey[300],
            size: 80,
          ),
          const SizedBox(height: 16),
          Text(
            isDelivered ? 'No Delivered Orders' : 'No Pending Orders',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isDelivered 
                ? 'All orders have been delivered'
                : 'No orders waiting for delivery',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard({
    required BuildContext context,
    required QueryDocumentSnapshot doc,
    required String tableName,
    required String email, // ✅ add
    required String totalAmount,
    required String paymentStatus,
    required String phoneNumber,
    required List<dynamic> cartDetails,
    required String timeText,
    required bool isDelivered,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with table info and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isDelivered ? Colors.green[50] : Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isDelivered ? Icons.check_circle : Icons.restaurant,
                            color: isDelivered ? Colors.green[600] : Colors.blue[600],
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Table $tableName',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              timeText,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹$totalAmount',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.green[700],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: paymentStatus == 'paid' 
                            ? Colors.green[50] 
                            : Colors.orange[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        paymentStatus.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: paymentStatus == 'paid' 
                              ? Colors.green[700] 
                              : Colors.orange[700],
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Phone and Items Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Phone Number
                      Row(
                        children: [
                          Icon(
                            Icons.phone_android,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              phoneNumber,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Food Items
                      Text(
                        'Order Items:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 6),
                      ..._buildFoodItems(cartDetails),
                    ],
                  ),
                ),
                
                // Action Button
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!isDelivered)
                        ElevatedButton(
                          onPressed: () {
                            _showDeliveryConfirmation(context, doc, tableName, email);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delivery_dining, size: 16),
                              SizedBox(width: 6),
                              Text('Deliver'),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(20), // Fix: Ensure color is not null
                            border: Border.all(color: Colors.green[100]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green[600],
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Delivered',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFoodItems(List<dynamic> cartDetails) {
    if (cartDetails.isEmpty) {
      return [
        Text(
          'No items',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ];
    }

    return cartDetails.map<Widget>((item) {
      final name = item is Map ? item['name'] ?? 'Item' : 'Item';
      final qty = item is Map ? item['qty']?.toString() ?? '1' : '1';
      final price = item is Map ? item['price']?.toString() ?? '0' : '0';

      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.blue[500],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$name (x$qty)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ),
            Text(
              '₹$price',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }


  void _showDeliveryConfirmation(
  BuildContext context,
  QueryDocumentSnapshot doc,
  String tableName,
  String email,
) {
    String? selectedBotId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.smart_toy, color: Colors.blue),
                SizedBox(width: 12),
                Text('Select Delivery Bot'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: StreamBuilder<DatabaseEvent>(
                stream: FirebaseDatabase.instance.ref('Device_IP').onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                    return const Text('No bots found');
                  }

                  final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  final botList = <Map<String, dynamic>>[];

                  data.forEach((key, value) {
                    final botData = value as Map<dynamic, dynamic>;
                    botList.add({
                      'id': key,
                      'name': botData['Device_Name'] ?? 'Unknown Bot',
                      'isOnline': botData['Answer'] == 'Am There',
                    });
                  });

                  // Sort: Online first
                  botList.sort((a, b) {
                    if (a['isOnline'] == b['isOnline']) return 0;
                    return a['isOnline'] ? -1 : 1;
                  });

                  if (botList.isEmpty) {
                    return const Text('No bots configured');
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: botList.length,
                    itemBuilder: (context, index) {
                      final bot = botList[index];
                      final isOnline = bot['isOnline'] as bool;

                      return RadioListTile<String>(
                        title: Text(bot['name']),
                        subtitle: Text(
                          isOnline ? 'Available' : 'Offline',
                          style: TextStyle(
                            color: isOnline ? Colors.green : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isOnline ? Colors.green[50] : Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.smart_toy,
                            color: isOnline ? Colors.green : Colors.grey,
                            size: 20,
                          ),
                        ),
                        value: bot['id'],
                        groupValue: selectedBotId,
                        onChanged: isOnline
                            ? (val) {
                                setState(() {
                                  selectedBotId = val;
                                });
                              }
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: selectedBotId == null
                  ? null
                  : () async {
                      try {
                        // ✅ tableName = email (ex: table001@res.com)
                        final userEmail = tableName;

                        // ✅ get table number from users collection using email
                        final userQuery = await FirebaseFirestore.instance
                            .collection("users")
                            .where("email", isEqualTo: userEmail)
                            .limit(1)
                            .get();

                        String tableNo = "Unknown";
                        if (userQuery.docs.isNotEmpty) {
                          tableNo = userQuery.docs.first.data()['name'] ?? "Unknown"; // 001
                        }

                        await doc.reference.update({'Food_Delivered': 'delivered'});

                        final ref = FirebaseDatabase.instance.ref('Device_IP/$selectedBotId');
                        await ref.update({         // ✅ table001@res.com
                          'Delivery': tableNo,       // ✅ 001
                        });

                        if (context.mounted) {
                          Navigator.pop(context);
                          _showSuccessSnackbar(context);
                        }
                      } catch (e) {
                        debugPrint('Error updating delivery: $e');
                      }
                    },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[500],
                ),
                child: const Text('Confirm & Deliver'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Order marked as delivered successfully'),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}