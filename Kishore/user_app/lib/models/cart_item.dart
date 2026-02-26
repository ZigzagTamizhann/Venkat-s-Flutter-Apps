class CartItem {
  final String id;
  final String foodItemId;
  final String? name;
  final double? price;
  final int quantity;
  final String? category;
  final String? description;
  final String? imageUrl;

  CartItem({
    required this.id,
    required this.foodItemId,
    this.name,
    this.price,
    required this.quantity,
    this.category,
    this.description,
    this.imageUrl,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      foodItemId: json['food_item_id'] ?? '',
      name: json['name'],
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : (json['price'] as double?),
      quantity: json['quantity'] ?? 1,
      category: json['category'],
      description: json['description'],
      imageUrl: json['image_url'],
    );
  }

  double get totalPrice => (price ?? 0.0) * quantity;
}