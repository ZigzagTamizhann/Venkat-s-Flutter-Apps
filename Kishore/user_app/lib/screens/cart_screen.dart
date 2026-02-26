import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../services/firebase_service.dart';
import '../models/cart_item.dart';
import 'payment_screen.dart';

class CartScreen extends StatefulWidget {
  final String shopId;
  const CartScreen({super.key, required this.shopId});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];
  bool _isLoading = true;
  String? _userMobile;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseService.currentUser;

      if (user != null && user.email != null) {
        _userMobile = user.email!.split("@")[0];
      }

      if (_userMobile == null || _userMobile!.isEmpty) {
        throw Exception("User mobile not found");
      }

      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(_userMobile)
          .collection("order_details")
          .get();

      final items = snapshot.docs.map((doc) {
        final data = doc.data();
        data["id"] = doc.id;

        if (data["price"] is int) data["price"] = (data["price"] as int).toDouble();
        if (data["price"] == null) data["price"] = 0.0;
        if (data["quantity"] == null) data["quantity"] = 1;

        return CartItem.fromJson(data);
      }).toList();

      if (!mounted) return;
      setState(() {
        _cartItems = items;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading cart: ${e.toString().split(':').last}"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity < 1) return;
    if (_userMobile == null) return;

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(_userMobile)
          .collection("order_details")
          .doc(item.id)
          .update({"quantity": newQuantity});

      _loadCartItems();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating quantity: ${e.toString().split(':').last}"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _removeItem(String itemId) async {
    if (_userMobile == null) return;

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(_userMobile)
          .collection("order_details")
          .doc(itemId)
          .delete();

      _loadCartItems();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Item removed"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: const Color(0xFFFF3B30),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error removing item: ${e.toString().split(':').last}"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  double get _totalAmount {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text("My Cart"),
        centerTitle: true,
        backgroundColor: const Color(0xFFF2F2F7),
        foregroundColor: const Color(0xFF007AFF),
      ),
      body: _isLoading
          ? const Center(child: CupertinoActivityIndicator(radius: 18))
          : _cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.cart,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Your cart is empty",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Add items to get started",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          
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
                            child: Container(
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
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        CupertinoIcons.bag_fill,
                                        size: 40,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name ?? "Item",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1C1C1E),
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "₹${(item.price ?? 0).toStringAsFixed(2)} each",
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: const Color(0xFFE5E5EA),
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  onPressed: () =>
                                                      _updateQuantity(item, item.quantity - 1),
                                                  icon: const Icon(CupertinoIcons.minus),
                                                  iconSize: 18,
                                                  color: const Color(0xFF007AFF),
                                                ),
                                                Container(
                                                  width: 30,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    "${item.quantity}",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFF1C1C1E),
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () =>
                                                      _updateQuantity(item, item.quantity + 1),
                                                  icon: const Icon(CupertinoIcons.plus),
                                                  iconSize: 18,
                                                  color: const Color(0xFF007AFF),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "₹${item.totalPrice.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF007AFF),
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        IconButton(
                                          onPressed: () => _removeItem(item.id),
                                          icon: const Icon(
                                            CupertinoIcons.delete,
                                            color: Color(0xFFFF3B30),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, -8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1C1C1E),
                                ),
                              ),
                              Text(
                                "₹${_totalAmount.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF007AFF),
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => PaymentScreen(
                                      cartItems: _cartItems,
                                      totalAmount: _totalAmount,
                                      shopId: widget.shopId,
                                    ),
                                    transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF007AFF),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(CupertinoIcons.creditcard_fill),
                                  SizedBox(width: 8),
                                  Text(
                                    "Proceed to Payment",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}