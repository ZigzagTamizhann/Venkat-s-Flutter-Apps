import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../services/firebase_service.dart';
import '../models/order.dart';
import '../theme/app_theme.dart';
import 'order_detail_screen.dart';
import 'login_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Order> _pendingOrders = [];
  List<Order> _preparingOrders = [];
  List<Order> _completedOrders = [];
  bool _isLoading = true;
  String? _errorMessage;

  StreamSubscription<QuerySnapshot>? _ordersSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _restoreSessionAndSetup();
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await FirebaseService.auth.signOut();
    FirebaseService.currentShopId = null;
    FirebaseService.currentShopName = null;

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
      (route) => false,
    );
  }

  Future<void> _restoreSessionAndSetup() async {
    // If shopId is lost (e.g. after hot reload), try to restore it from current user
    if (FirebaseService.currentShopId == null) {
      final user = FirebaseService.auth.currentUser;
      if (user != null && user.email != null) {
        try {
          final staffQuery = await FirebaseService.db
              .collection('staff')
              .where('email', isEqualTo: user.email)
              .get();

          if (staffQuery.docs.isNotEmpty) {
            final staffData = staffQuery.docs.first.data();
            FirebaseService.currentShopId = staffData['shopId'];
            
            if (FirebaseService.currentShopId != null) {
              final shopDoc = await FirebaseService.db.collection('shopkeepers').doc(FirebaseService.currentShopId).get();
              FirebaseService.currentShopName = shopDoc.data()?['shopName'];
            }
          }
        } catch (e) {
          debugPrint('Error restoring session: $e');
        }
      }
    }
    _setupOrdersListener();
  }

  void _setupOrdersListener() {
    final shopId = FirebaseService.currentShopId;
    if (shopId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Shop ID not found';
      });
      return;
    }

    Query query = FirebaseService.db
        .collection('shopkeepers')
        .doc(shopId)
        .collection('sales')
        .orderBy('date', descending: true);

    _ordersSubscription = query.snapshots().listen((snapshot) {
      if (!mounted) return;

      final orders = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Order.fromJson(data);
      }).toList();

      setState(() {
        _pendingOrders = orders.where((o) => o.status.toLowerCase() == 'pending').toList();
        _preparingOrders = orders.where((o) => o.status.toLowerCase() == 'prepare').toList();
        _completedOrders = orders.where((o) => o.status.toLowerCase() == 'completed').toList();
        _isLoading = false;
        _errorMessage = null;
      });
    }, onError: (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load orders: $e';
      });
    });
  }

  Future<void> _updateOrderStatus(Order order, String status) async {
    try {
      final shopId = FirebaseService.currentShopId;
      if (shopId == null) return;

      await FirebaseService.db
          .collection('shopkeepers')
          .doc(shopId)
          .collection('sales')
          .doc(order.id)
          .update({
            'status': status,
            if (status == 'completed') 'completed_at': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order marked as $status'),
          backgroundColor: AppTheme.success,
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      debugPrint('Error updating order: $e');
    }
  }

  Widget _buildOrdersList(List<Order> orders, String emptyMessage) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading orders...',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppTheme.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: AppTheme.error,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _setupOrdersListener,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'New orders will appear here',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final statusColor = AppTheme.statusColors[order.status.toLowerCase()] ?? AppTheme.textSecondary;
        final itemCount = order.items.fold<int>(0, (sum, i) => sum + i.quantity);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailScreen(order: order),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Order icon with status
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            '#${order.id.substring(0, 4)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Order details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    order.status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '• $itemCount items',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${order.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              order.items.map((i) => i.name).take(2).join(', ') +
                                  (order.items.length > 2 ? '...' : ''),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (order.status.toLowerCase() == 'preparing' || 
                                order.status.toLowerCase() == 'prepare') ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 36,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _updateOrderStatus(order, 'completed'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.success,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Mark Completed'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      // Arrow
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                FirebaseService.currentShopName ?? 'Orders',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_outlined),
              onPressed: _logout,
              tooltip: 'Sign Out',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Preparing'),
                    if (_preparingOrders.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.preparingColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${_preparingOrders.length}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Pending'),
                    if (_pendingOrders.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.pendingColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${_pendingOrders.length}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Completed'),
                    if (_completedOrders.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.completedColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${_completedOrders.length}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            indicatorColor: AppTheme.primary,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.background,
                AppTheme.background,
              ],
            ),
          ),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOrdersList(_preparingOrders, 'No preparing orders'),
              _buildOrdersList(_pendingOrders, 'No pending orders'),
              _buildOrdersList(_completedOrders, 'No completed orders'),
            ],
          ),
        ),
      ),
    );
  }
}