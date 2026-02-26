class FoodItemModel {
  final String itemId;
  final String name;
  final double price;
  final String category;
  final bool available;
  final String description;

  FoodItemModel({
    required this.itemId,
    required this.name,
    required this.price,
    required this.category,
    required this.available,
    required this.description,
  });

  factory FoodItemModel.fromMap(Map<String, dynamic> map) {
    return FoodItemModel(
      itemId: map['itemId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      available: map['available'] ?? false,
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'name': name,
      'price': price,
      'category': category,
      'available': available,
      'description': description,
    };
  }
}