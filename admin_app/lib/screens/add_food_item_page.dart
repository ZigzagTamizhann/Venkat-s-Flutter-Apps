import 'package:flutter/material.dart';
import 'package:admin_app/models/food_item_model.dart';
import 'package:admin_app/services/food_service.dart';

class AddFoodItemPage extends StatefulWidget {
  @override
  _AddFoodItemPageState createState() => _AddFoodItemPageState();
}

class _AddFoodItemPageState extends State<AddFoodItemPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _available = true;
  final FoodService _foodService = FoodService(); 

  String? _selectedCategory;
  final List<String> _categories = [
    'Food',
    'Snake',
    'Beverage\'s',
  ];


  Future<void> _addItem() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a category')));
      return;
    }

    FoodItemModel item = FoodItemModel(
      itemId: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      price: double.parse(_priceController.text),
      category: _selectedCategory!,
      available: _available,
      description: _descriptionController.text,
    );

    await _foodService.addFoodItem(item);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Food Item')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Food Name', border: OutlineInputBorder())),
            SizedBox(height: 15),
            TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Price', border: OutlineInputBorder())),
            SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
            ),
            SizedBox(height: 15),
            TextField(controller: _descriptionController, maxLines: 3, decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
            SizedBox(height: 15),
            SwitchListTile(
              title: Text('Available'),
              value: _available,
              onChanged: (val) => setState(() => _available = val),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addItem,
              child: Text('Add Item'),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}