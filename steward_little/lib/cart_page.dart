import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Import QR Package
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dishes_data.dart';

class CartPage extends StatefulWidget {
  final Map<String, int> cart;
  final String mobileNumber;
  final VoidCallback onOrderPlaced;

  const CartPage({
    super.key,
    required this.cart,
    required this.mobileNumber,
    required this.onOrderPlaced,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    double total = 0;
    double subtotal = 0;
    const double tax = 0.05; // 5% tax
    final List<Map<String, dynamic>> cartItems = [];

    widget.cart.forEach((name, qty) {
      final dish = dishes.firstWhere(
        (d) => d['name'] == name,
        orElse: () => {'name': name, 'price': 0, 'category': 'Unknown'},
      );
      cartItems.add({...dish, 'qty': qty});
      subtotal += (dish['price'] as int) * qty;
    });

    final double taxAmount = subtotal * tax;
    total = subtotal + taxAmount;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Custom App Bar
          Container(
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade600,
                  Colors.orange.shade800,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.orange,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Cart',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '${cartItems.length} items',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 24),
                    onPressed: () => setState(() {}),
                    tooltip: 'Check Order Status',
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 1. Current Cart Section
                  if (cartItems.isNotEmpty)
                    _buildLocalCartSection(cartItems, subtotal, taxAmount, total),

                  // 2. Firestore Orders Section (Delivered & Not Delivered)
                  _buildFirestoreOrdersSection(),
                ],
              ),
            ),
          ),

          // Order Summary
          if (cartItems.isNotEmpty) // Only show bottom summary if there are new items to order
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Order Summary Header
                  Row(
                    children: [
                      const Icon(
                        Icons.receipt_long_rounded,
                        color: Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${cartItems.length} items',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Breakdown
                  Column(
                    children: [
                      _buildSummaryRow(
                          'Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
                      _buildSummaryRow(
                          'Tax (5%)', '₹${taxAmount.toStringAsFixed(2)}'),
                      const SizedBox(height: 10),
                      Container(
                        height: 1,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '₹${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade100,
                            foregroundColor: Colors.grey.shade800,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Add More',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showOrderConfirmation(
                              context, total, widget.onOrderPlaced, cartItems),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            shadowColor: Colors.orange.withOpacity(0.4),
                          ),
                          child: const Text(
                            'Checkout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocalCartSection(List<Map<String, dynamic>> cartItems, double subtotal, double taxAmount, double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'New Order (Cart Items)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: cartItems.length,
          itemBuilder: (context, index) {
            final item = cartItems[index];
            final itemTotal = (item['price'] as int) * (item['qty'] as int);
            final Color categoryColor = _getCategoryColor(item['category'] as String);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: categoryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Qty: ${item['qty']}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹$itemTotal',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const Divider(thickness: 1, height: 40),
      ],
    );
  }

  Widget _buildFirestoreOrdersSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Food Eaters')
          .doc(widget.mobileNumber)
          .collection('orders')
          .where('payment_status', isEqualTo: 'not paid')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text('Error loading orders: ${snapshot.error}'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ));
        }

        // Sort orders client-side to avoid Firestore composite index requirement
        final docs = List<QueryDocumentSnapshot>.from(snapshot.data?.docs ?? []);
        docs.sort((a, b) {
          final dataA = a.data() as Map<String, dynamic>;
          final dataB = b.data() as Map<String, dynamic>;
          final t1 = dataA['timestamp'] as Timestamp?;
          final t2 = dataB['timestamp'] as Timestamp?;
          if (t1 == null || t2 == null) return 0;
          return t2.compareTo(t1);
        });

        if (docs.isEmpty) {
          if (widget.cart.isEmpty) {
             return Center(
               child: Padding(
                 padding: const EdgeInsets.only(top: 50.0),
                 child: Column(
                   children: [
                     Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey.shade300),
                     const SizedBox(height: 10),
                     Text("No active orders", style: TextStyle(color: Colors.grey.shade500)),
                   ],
                 ),
               ),
             );
          }
          return const SizedBox.shrink();
        }

        final deliveredOrders = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final String status = (data['Food_Delivered'] ?? 'not delivered').toString();
          return status.trim().toLowerCase() == 'delivered';
        }).toList();

        final notDeliveredOrders = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final String status = (data['Food_Delivered'] ?? 'not delivered').toString();
          return status.trim().toLowerCase() != 'delivered';
        }).toList();

        return Column(
          children: [
            if (deliveredOrders.isNotEmpty)
              _buildOrderList(deliveredOrders, 'Ready for Payment (Delivered)', Colors.green, true),
            if (notDeliveredOrders.isNotEmpty)
              _buildOrderList(notDeliveredOrders, 'Preparing / Not Delivered', Colors.orange, false),
          ],
        );
      },
    );
  }

  Widget _buildOrderList(List<QueryDocumentSnapshot> docs, String title, Color color, bool isPayable) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final double total = (data['total_amount'] as num).toDouble();
            final List items = data['cart_details'] as List;
            final List<Map<String, dynamic>> cartItems = List<Map<String, dynamic>>.from(
                items.map((item) => Map<String, dynamic>.from(item)));

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Order #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('₹${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const Divider(),
                    ...cartItems.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item['name']} x${item['qty']}'),
                          Text('₹${((item['price'] as int) * (item['qty'] as int))}'),
                        ],
                      ),
                    )),
                    const SizedBox(height: 10),
                    if (isPayable)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showPaymentDialog(context, total, widget.onOrderPlaced, cartItems, doc.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Pay Now'),
                        ),
                      )
                    else
                      const Center(child: Text('Status: Preparing...', style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic))),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderConfirmation(
      BuildContext parentContext, double total, VoidCallback onOrderPlaced, List<Map<String, dynamic>> cartItems) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_rounded,
                color: Colors.orange,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Confirm Order',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Total amount: ₹${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Proceed to payment?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close confirm dialog
              _saveOrderToFirestore(parentContext, total, onOrderPlaced, cartItems);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _saveOrderToFirestore(
      BuildContext context, // Note: We will use 'this.context' inside instead
      double total,
      VoidCallback onOrderPlaced,
      List<Map<String, dynamic>> cartItems) async {
    
    try {
      // Fetch the user document to get the 'user_created_by' (Admin UID)
      String adminId = '';
      String userName = 'Unknown';
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        userName = currentUser.displayName ?? 'Unknown';
        // 1. Try fetching by UID
        var userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: currentUser.uid)
            .limit(1)
            .get();

        // 2. Fallback: Try fetching by Email if UID lookup failed
        if (userQuery.docs.isEmpty && currentUser.email != null) {
          userQuery = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: currentUser.email)
              .limit(1)
              .get();
        }

        if (userQuery.docs.isNotEmpty) {
          final userData = userQuery.docs.first.data();
          adminId = userData['user_created_by'] ?? '';
          if (userData['name'] != null) userName = userData['name'];
        }
      }

      FirebaseFirestore.instance
          .collection('Food Eaters')
          .doc(widget.mobileNumber)
          .collection('orders')
          .add({
        'cart_details': cartItems,
        'total_amount': total,
        'timestamp': FieldValue.serverTimestamp(),
        'payment_status': 'not paid',
        'table_name': userName,
        'Food_Delivered': 'not delivered',
        'user_created_by': adminId, // Store Admin ID for isolation
      }).then((docRef) {
        // FIX: Check if mounted before updating UI
        if (!mounted) return;
        
        widget.onOrderPlaced();
        setState(() {});
        // Use 'this.context' to be safe, though 'context' passed here is usually stable
        _showOrderSavedDialog(this.context, total, widget.onOrderPlaced, cartItems, docRef.id);
      });
    } catch (error) {
      debugPrint("Error adding to firestore: $error");
    }
  }

  void _showOrderSavedDialog(
      BuildContext parentContext,
      double total,
      VoidCallback onOrderPlaced,
      List<Map<String, dynamic>> cartItems,
      String orderId) {
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Food Eaters')
              .doc(widget.mobileNumber)
              .collection('orders')
              .doc(orderId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() as Map<String, dynamic>?;
            // Robust check: convert to string, trim whitespace, and check case-insensitive
            final String status = (data?['Food_Delivered'] ?? 'not delivered').toString();
            final bool isDelivered = status.trim().toLowerCase() == 'delivered';

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              title: Text(isDelivered ? 'Food Delivered' : 'Order Placed'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isDelivered) ...[
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(color: Colors.orange),
                    ),
                    const Text(
                      'Waiting for food delivery...',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Payment button will be enabled once food is delivered.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ] else
                    const Text('Your food has been delivered. Please proceed to payment.'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Close'),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isDelivered
                        ? () {
                            Navigator.pop(dialogContext); // Close saved dialog
                            _showPaymentDialog(
                                parentContext, total, onOrderPlaced, cartItems, orderId);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Proceed to Payment'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPaymentDialog(
      BuildContext parentContext, 
      double total, 
      VoidCallback onOrderPlaced, 
      List<Map<String, dynamic>> cartItems, 
      String orderId) {
    
    // --- UPI QR Generation Logic ---
    const String upiId = "venkatapathivenkat2004@okaxis"; 
    const String name = "Venkatapathi K";
    
    final String upiUrl = 
        "upi://pay?pa=$upiId&pn=$name&am=${total.toStringAsFixed(2)}&cu=INR";
    // -----------------------------

    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Payment Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.orange,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Scan to Pay',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // --- QR Code Display ---
              Container(
                width: 200,
                height: 200,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: Center(
                  child: QrImageView(
                    data: upiUrl,
                    version: QrVersions.auto,
                    size: 180.0,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 25),

              // Amount
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.orange.shade100, width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      'Payable Amount',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '₹${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Success Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Update payment status to 'paid'
                    await FirebaseFirestore.instance
                        .collection('Food Eaters')
                        .doc(widget.mobileNumber)
                        .collection('orders')
                        .doc(orderId)
                        .update({'payment_status': 'paid'});

                    // FIX 1: Check if the Widget is still in the tree
                    if (!mounted) return;

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext); // Close payment dialog
                      
                      // FIX 2: Use 'context' (the class property) instead of 'parentContext'
                      // 'parentContext' might be dead if the list refreshed.
                      _showSuccessAnimation(context, () {
                        onOrderPlaced(); // Clear cart
                        // Check mounted again before popping the main page
                        if (mounted) {
                          Navigator.pop(context); // Close cart page
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Payment Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Note
              Text(
                'After payment, your order will be confirmed',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

  void _showSuccessAnimation(BuildContext parentContext, VoidCallback onSuccess) {
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green.shade100, width: 3),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 60,
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your order has been placed',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext); // Close success dialog
                    onSuccess();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Veg':
        return Colors.green;
      case 'Non-Veg':
        return Colors.red;
      case 'South Indian':
        return Colors.orange;
      case 'Chinese':
        return Colors.redAccent;
      case 'Fast Food':
        return Colors.deepOrange;
      case 'Desserts':
        return Colors.pink;
      case 'Drinks':
        return Colors.blue;
      case 'Beverages':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }