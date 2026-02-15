import 'package:flutter/material.dart';
import 'package:user_app/models/food_item_model.dart';

class FoodDetailPage extends StatelessWidget {
  final FoodItemModel item;
  final VoidCallback onAddToCart;

  FoodDetailPage({required this.item, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('₹${item.price}', style: TextStyle(fontSize: 22, color: Colors.green, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('Category: ${item.category}', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  SizedBox(height: 20),
                  Text('Description:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text(item.description, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      onAddToCart();
                      Navigator.pop(context);
                    },
                    child: Text('Add to Cart'),
                    style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}