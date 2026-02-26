import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../services/firebase_service.dart';
import '../models/food_item.dart';
import 'food_detail_screen.dart';
import 'login_screen.dart';
import 'cart_screen.dart';
import 'order_history_screen.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _foodItems = [];
  String? shopId;
  String? shopName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && shopId == null) {
      shopId = args['shopId'];
      shopName = args['shopName'];
    }
  }


  Future<void> _logout() async {
    await FirebaseService.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: _selectedIndex == 0
          ? AppBar(
              title: Text(shopName ?? 'Menu'),
              centerTitle: true,
              backgroundColor: const Color(0xFFF2F2F7),
              foregroundColor: const Color(0xFF007AFF),
              actions: [
                IconButton(
                  icon: const Icon(CupertinoIcons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: FoodSearchDelegate(_foodItems),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.square_arrow_right),
                  onPressed: _logout,
                ),
              ],
            )
          : null,
      body: _buildBody(),
      bottomNavigationBar: Container(
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
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              activeIcon: Icon(CupertinoIcons.hare_fill),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.cart),
              activeIcon: Icon(CupertinoIcons.cart_fill),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.clock),
              activeIcon: Icon(CupertinoIcons.clock_fill),
              label: 'History',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF007AFF),
          unselectedItemColor: const Color(0xFF8E8E93),
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        if (shopId == null) {
          return const Center(child: CupertinoActivityIndicator(radius: 18));
        }
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('shopkeepers')
              .doc(shopId)
              .collection('inventory')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator(radius: 18));
            }

            final docs = snapshot.data?.docs ?? [];
            final items = docs.map<Map<String, dynamic>>((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'id': doc.id,
                'name': data['name'] ?? '',
                'price': (data['price'] ?? 0).toDouble(),
                'category': data['tag'] ?? 'Other',
                'stock': data['stock'] ?? 0,
                'isCounted': data['isCounted'] ?? false,
              };
            }).toList();

            items.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
            _foodItems = items;

            if (items.isEmpty) {
              return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.bag,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No food items available',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
            }

            return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isAvailable = (item['stock'] as int) > 0;
                        
                        return TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 400 + (index * 50)),
                          curve: Curves.easeOutQuad,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: child,
                            );
                          },
                          child: GestureDetector(
                            onTap: isAvailable ? () {
                              final foodItem = FoodItem(
                                id: item['id'],
                                name: item['name'],
                                description: '',
                                price: item['price'],
                                imageUrl: '',
                                isAvailable: isAvailable,
                                category: item['category'],
                              );
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => FoodDetailScreen(foodItem: foodItem),
                                  transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                                ),
                              );
                            } : null,
                            child: Container(
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isAvailable
                                              ? [const Color(0xFF007AFF), const Color(0xFF5856D6)]
                                              : [Colors.grey.shade400, Colors.grey.shade600],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          CupertinoIcons.circle_grid_hex,
                                          size: 60,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1C1C1E),
                                            letterSpacing: -0.3,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              '₹${item['price']}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF007AFF),
                                              ),
                                            ),
                                            const Spacer(),
                                            if (!isAvailable)
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'Out',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey.shade600,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item['category'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
          },
        );
      case 1:
        return CartScreen(shopId: shopId ?? '');
      case 2:
        return const OrderHistoryScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}

class FoodSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> foodItems;

  FoodSearchDelegate(this.foodItems);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF2F2F7),
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Color(0xFF8E8E93)),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(CupertinoIcons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(CupertinoIcons.back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = foodItems.where((item) {
      return item['name'].toLowerCase().contains(query.toLowerCase()) ||
             item['category'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    return _buildSearchResults(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = foodItems.where((item) {
      return item['name'].toLowerCase().contains(query.toLowerCase()) ||
             item['category'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    return _buildSearchResults(suggestions);
  }

  Widget _buildSearchResults(List<Map<String, dynamic>> results) {
    return Container(
      color: const Color(0xFFF2F2F7),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final item = results[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.circle_grid_hex,
                  color: Colors.white,
                ),
              ),
              title: Text(
                item['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              subtitle: Text(
                item['category'],
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
              trailing: Text(
                '₹${item['price']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF007AFF),
                ),
              ),
              onTap: () {
                close(context, null);
                // Navigate to detail screen
              },
            ),
          );
        },
      ),
    );
  }
}