class OrderItem {
  final String itemId;
  final String itemName;
  final double price;
  final int quantity;

  OrderItem({
    required this.itemId,
    required this.itemName,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      "itemId": itemId,
      "itemName": itemName,
      "price": price,
      "quantity": quantity,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      itemId: map["itemId"] ?? "",
      itemName: map["itemName"] ?? "",
      price: (map["price"] ?? 0).toDouble(),
      quantity: (map["quantity"] ?? 0).toInt(),
    );
  }
}
