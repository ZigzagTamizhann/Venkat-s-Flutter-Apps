import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_app/models/food_item_model.dart';

class FoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<FoodItemModel>> getFoodItems() {
    return _firestore.collection('food_items').snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => FoodItemModel.fromMap(doc.data()))
          .toList(),
    );
  }

  Future<void> addFoodItem(FoodItemModel item) async {
    await _firestore.collection('food_items').doc(item.itemId).set(item.toMap());
  }

  Future<void> updateFoodItem(FoodItemModel item) async {
    await _firestore.collection('food_items').doc(item.itemId).update(item.toMap());
  }

  Future<void> deleteFoodItem(String itemId) async {
    await _firestore.collection('food_items').doc(itemId).delete();
  }

  Future<void> toggleAvailability(String itemId, bool available) async {
    await _firestore.collection('food_items').doc(itemId).update({
      'available': available,
    });
  }
}