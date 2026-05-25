import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meals/models/meal.dart';
import 'package:meals/models/review.dart';
import 'package:meals/data/dummy_data.dart';

class MealService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;



  /// Seeds Firestore with dummy data if the meals collection is empty.
  Future<void> seedMealsIfEmpty() async {
    final snapshot = await _db.collection('meals').limit(1).get();
    if (snapshot.docs.isEmpty) {
      final batch = _db.batch();
      for (final meal in dummyMeals) {
        final ref = _db.collection('meals').doc(meal.id);
        batch.set(ref, meal.toFirestore());
      }
      await batch.commit();
    }
  }

  Stream<List<Meal>> mealsStream() {
    return _db.collection('meals').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Meal.fromFirestore(doc.data(), doc.id)).toList());
  }

  Future<Meal?> getMeal(String mealId) async {
    final doc = await _db.collection('meals').doc(mealId).get();
    if (!doc.exists) return null;
    return Meal.fromFirestore(doc.data()!, doc.id);
  }


  Stream<List<String>> favouritesStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('favourites')
        .snapshots()
        .map((s) => s.docs.map((d) => d.id).toList());
  }

  Future<void> toggleFavourite(String userId, String mealId, bool isCurrentlyFav) async {
    final ref = _db.collection('users').doc(userId).collection('favourites').doc(mealId);
    if (isCurrentlyFav) {
      await ref.delete();
    } else {
      await ref.set({'addedAt': FieldValue.serverTimestamp()});
    }
  }


  Stream<Map<String, bool>> shoppingListStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('shoppingList')
        .snapshots()
        .map((s) => {for (final doc in s.docs) doc.id: (doc.data()['checked'] as bool? ?? false)});
  }

  Future<void> addIngredientsToShoppingList(String userId, List<String> ingredients) async {
    final batch = _db.batch();
    for (final ingredient in ingredients) {
      final key = ingredient.toLowerCase().replaceAll(' ', '_').replaceAll(RegExp(r'[^a-z0-9_]'), '');
      final ref = _db.collection('users').doc(userId).collection('shoppingList').doc(key);
      batch.set(ref, {'name': ingredient, 'checked': false}, SetOptions(merge: true));
    }
    await batch.commit();
  }

  Future<void> toggleShoppingItem(String userId, String itemId, bool checked) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('shoppingList')
        .doc(itemId)
        .update({'checked': checked});
  }

  Future<void> removeShoppingItem(String userId, String itemId) async {
    await _db.collection('users').doc(userId).collection('shoppingList').doc(itemId).delete();
  }

  Future<void> clearCheckedItems(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('shoppingList')
        .where('checked', isEqualTo: true)
        .get();
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }



  Stream<List<Review>> reviewsStream(String mealId) {
    return _db
        .collection('reviews')
        .where('mealId', isEqualTo: mealId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Review.fromFirestore(d.data(), d.id)).toList());
  }

  Future<bool> hasUserReviewed(String userId, String mealId) async {
    final snapshot = await _db
        .collection('reviews')
        .where('mealId', isEqualTo: mealId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void> submitReview(Review review) async {
    // Add review
    await _db.collection('reviews').add(review.toFirestore());

    // Recalculate average rating on the meal doc
    final allReviews = await _db
        .collection('reviews')
        .where('mealId', isEqualTo: review.mealId)
        .get();

    final ratings = allReviews.docs.map((d) => (d.data()['rating'] as num).toDouble()).toList();
    final avg = ratings.reduce((a, b) => a + b) / ratings.length;

    await _db.collection('meals').doc(review.mealId).update({
      'averageRating': avg,
      'reviewCount': ratings.length,
    });
  }
}
