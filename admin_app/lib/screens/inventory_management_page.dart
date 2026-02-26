import 'package:flutter/material.dart';
import 'package:admin_app/models/food_item_model.dart';
import 'package:admin_app/services/food_service.dart';
import 'package:admin_app/screens/add_food_item_page.dart';
import 'package:admin_app/screens/edit_food_item_page.dart';


class InventoryManagementPage extends StatelessWidget {
  final FoodService _foodService = FoodService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inventory Management')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddFoodItemPage())),
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<List<FoodItemModel>>(
        stream: _foodService.getFoodItems(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          List<FoodItemModel> items = snapshot.data!;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              FoodItemModel item = items[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(item.name),
                  subtitle: Text('₹${item.price} • ${item.available ? "Available" : "Unavailable"}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: item.available,
                        onChanged: (val) => _foodService.toggleAvailability(item.itemId, val),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditFoodItemPage(item: item)),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _foodService.deleteFoodItem(item.itemId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}