import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:user_app/models/food_item_model.dart';
import 'package:user_app/models/order_item.dart';
import 'package:user_app/screens/cart_page.dart';
import 'package:user_app/screens/food_detail_page.dart';
import 'package:user_app/screens/order_history_page.dart';
import 'package:user_app/services/food_service.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final FoodService _foodService = FoodService();
  late Stream<List<FoodItemModel>> _foodItemsStream;
  List<OrderItem> _cart = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Food', 'Snacks', 'Beverages'];

  @override
  void initState() {
    super.initState();
    _foodItemsStream = _foodService.getFoodItems();
  }

  void _addToCart(FoodItemModel item) {
    if (!item.available) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item is out of stock')));
      return;
    }
    setState(() {
      int index = _cart.indexWhere((e) => e.itemId == item.itemId);
      if (index >= 0) {
        _cart[index] = OrderItem(
          itemId: item.itemId,
          itemName: item.name,
          quantity: _cart[index].quantity + 1,
          price: item.price,
        );
      } else {
        _cart.add(OrderItem(
          itemId: item.itemId,
          itemName: item.name,
          quantity: 1,
          price: item.price,
        ));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.name} added to cart')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Food'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartPage(cart: _cart)),
                  );
                  setState(() {}); // Refresh state to update cart badge
                },
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text('${_cart.length}', style: const TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center
                    ),
                  ),
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.orange),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.account_circle, size: 60, color: Colors.white),
                  SizedBox(height: 10),
                  Text('Welcome', style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Order History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderHistoryPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search food...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      }
                    },
                    selectedColor: Colors.orange,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<FoodItemModel>>(
              stream: _foodItemsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                List<FoodItemModel> items = snapshot.data!.where((item) {
                  final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchesCategory = _selectedCategory == 'All' ||
                      item.category.toLowerCase() == _selectedCategory.toLowerCase();
                  return matchesSearch && matchesCategory;
                }).toList();

                if (items.isEmpty) {
                  return const Center(child: Text('No items found'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    FoodItemModel item = items[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FoodDetailPage(item: item, onAddToCart: () => _addToCart(item))),
                      ),
                      child: Card(
                        elevation: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('₹${item.price}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 5),
                                  ElevatedButton(
                                    onPressed: item.available ? () => _addToCart(item) : null,
                                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 36)),
                                    child: Text(item.available ? 'Add to Cart' : 'Out of Stock'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}