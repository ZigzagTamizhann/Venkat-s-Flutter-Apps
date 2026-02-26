import 'package:flutter/material.dart';
import 'package:admin_app/models/food_item_model.dart';
import 'package:admin_app/services/food_service.dart';


class EditFoodItemPage extends StatefulWidget {
  final FoodItemModel item;
  EditFoodItemPage({required this.item});

  @override
  _EditFoodItemPageState createState() => _EditFoodItemPageState();
}

class _EditFoodItemPageState extends State<EditFoodItemPage> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  late bool _available;
  final FoodService _foodService = FoodService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _priceController = TextEditingController(text: widget.item.price.toString());
    _categoryController = TextEditingController(text: widget.item.category);
    _descriptionController = TextEditingController(text: widget.item.description);
    _available = widget.item.available;
  }

  Future<void> _updateItem() async {
    FoodItemModel updatedItem = FoodItemModel(
      itemId: widget.item.itemId,
      name: _nameController.text,
      price: double.parse(_priceController.text),
      category: _categoryController.text,
      available: _available,
      description: _descriptionController.text,
    );

    await _foodService.updateFoodItem(updatedItem);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Food Item')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Food Name', border: OutlineInputBorder())),
            SizedBox(height: 15),
            TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Price', border: OutlineInputBorder())),
            SizedBox(height: 15),
            TextField(controller: _categoryController, decoration: InputDecoration(labelText: 'Category', border: OutlineInputBorder())),
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
              onPressed: _updateItem,
              child: Text('Update Item'),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}
