import 'package:cloud_firestore/cloud_firestore.dart';
import './nutrition_item.dart';

class Nutrition {
  final String nutritionId;
  final String planId;
  final String userId;
  final String mealType;
  final List<NutritionItem> items;
  final String? notes;

  Nutrition({
    required this.nutritionId,
    required this.planId,
    required this.userId,
    required this.mealType,
    required this.items,
    this.notes,
  });

  factory Nutrition.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Nutrition(
      nutritionId: doc.id,
      planId: data['planId'] ?? '',
      userId: data['userId'] ?? '',
      mealType: data['mealType'] ?? '',
      items: (data['items'] as List<dynamic>?)
              ?.map((e) => NutritionItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'planId': planId,
      'userId': userId,
      'mealType': mealType,
      'items': items.map((e) => e.toMap()).toList(),
      'notes': notes,
    };
  }
}
