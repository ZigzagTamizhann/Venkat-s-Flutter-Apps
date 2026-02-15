import 'package:flutter/material.dart';
import 'package:user_app/models/order_item.dart';

class CartPage extends StatefulWidget {
  final List<OrderItem> cart;
  CartPage({required this.cart});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double get totalAmount => widget.cart.fold(0, (sum, item) => sum + (item.price * item.quantity));

  void _removeItem(int index) {
    setState(() {
      widget.cart.removeAt(index);
    });
  }

  void _updateQuantity(int index, int quantity) {
    setState(() {
      if (quantity > 0) {
        widget.cart[index] = OrderItem(
          itemId: widget.cart[index].itemId,
          itemName: widget.cart[index].itemName,
          quantity: quantity,
          price: widget.cart[index].price,
        );
      } else {
        widget.cart.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cart')),
      body: widget.cart.isEmpty
          ? Center(child: Text('Your cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cart.length,
                    itemBuilder: (context, index) {
                      OrderItem item = widget.cart[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          title: Text(item.itemName),
                          subtitle: Text('₹${item.price} x ${item.quantity}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () => _updateQuantity(index, item.quantity - 1),
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () => _updateQuantity(index, item.quantity + 1),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeItem(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('₹${totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
