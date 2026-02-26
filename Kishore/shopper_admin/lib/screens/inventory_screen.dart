import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';

class InventoryScreen extends StatefulWidget {
  final String shopId;
  const InventoryScreen({super.key, required this.shopId});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ['FOOD', 'SNACKS', 'DRINKS'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showInventoryDialog(BuildContext context, {DocumentSnapshot? item}) {
    final isEditing = item != null;
    final data = isEditing ? (item.data() as Map<String, dynamic>) : null;

    final nameController = TextEditingController(text: isEditing ? data!['name'] : '');
    final priceController = TextEditingController(
      text: isEditing ? data!['price'].toString() : ''
    );
    
    bool isCounted = isEditing ? (data!['isCounted'] ?? true) : true;
    final stockController = TextEditingController(
      text: isEditing && isCounted ? data!['stock'].toString() : ''
    );

    String selectedTag = isEditing ? (data!['tag'] ?? 'FOOD') : 'FOOD';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceGlass,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Edit Item' : 'Add New Item',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Item Name',
                        prefixIcon: Icon(Icons.shopping_bag_outlined),
                        hintText: 'e.g. Burger, Pizza',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        prefixIcon: Icon(Icons.attach_money),
                        hintText: '0.00',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedTag,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: _categories.map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text(t),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedTag = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.inventory_outlined,
                            size: 20,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Track Stock',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: isCounted,
                            onChanged: (val) => setState(() => isCounted = val),
                            activeColor: AppTheme.primary,
                          ),
                        ],
                      ),
                    ),
                    if (isCounted) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: stockController,
                        decoration: const InputDecoration(
                          labelText: 'Stock Quantity',
                          prefixIcon: Icon(Icons.numbers_outlined),
                          hintText: '0',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final collection = FirebaseFirestore.instance
                                  .collection('shopkeepers')
                                  .doc(widget.shopId)
                                  .collection('inventory');
                              
                              final saveData = {
                                'name': nameController.text,
                                'price': double.tryParse(priceController.text) ?? 0,
                                'isCounted': isCounted,
                                'stock': isCounted ? (int.tryParse(stockController.text) ?? 0) : 0,
                                'tag': selectedTag,
                                'updatedAt': FieldValue.serverTimestamp(),
                              };

                              if (isEditing) {
                                collection.doc(item.id).update(saveData);
                              } else {
                                collection.add(saveData);
                              }
                              
                              Navigator.pop(context);
                            },
                            child: Text(isEditing ? 'Save' : 'Add Item'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _categories.map((category) => Tab(text: category)).toList(),
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
              AppTheme.background.withOpacity(0.95),
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('shopkeepers')
              .doc(widget.shopId)
              .collection('inventory')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return const Center(child: Text('No data'));
            }

            final allDocs = snapshot.data!.docs;

            return TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                final filteredDocs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return (data['tag'] ?? 'FOOD') == category;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceGlass,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 40,
                            color: AppTheme.textSecondary.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No $category items',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add new item',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final isCounted = data['isCounted'] ?? true;
                    final stock = data['stock'] ?? 0;
                    
                    // Stock status color
                    Color stockColor = AppTheme.success;
                    if (isCounted && stock <= 5) {
                      stockColor = AppTheme.error;
                    } else if (isCounted && stock <= 10) {
                      stockColor = AppTheme.warning;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceGlass,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getCategoryIcon(category),
                            color: _getCategoryColor(category),
                            size: 24,
                          ),
                        ),
                        title: Text(
                          data['name'] ?? 'Unnamed',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(category).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _getCategoryColor(category),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (isCounted)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.inventory,
                                        size: 14,
                                        color: stockColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Stock: $stock',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: stockColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  const Text(
                                    'Available',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₹${data['price']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.background,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                  color: AppTheme.primary,
                                ),
                                onPressed: () => _showInventoryDialog(context, item: doc),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton.extended(
          onPressed: () => _showInventoryDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Add Item'),
          backgroundColor: AppTheme.primary,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'FOOD':
        return Colors.orange;
      case 'SNACKS':
        return Colors.purple;
      case 'DRINKS':
        return Colors.teal;
      default:
        return AppTheme.primary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'FOOD':
        return Icons.lunch_dining_outlined;
      case 'SNACKS':
        return Icons.cookie_outlined;
      case 'DRINKS':
        return Icons.local_cafe_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }
}