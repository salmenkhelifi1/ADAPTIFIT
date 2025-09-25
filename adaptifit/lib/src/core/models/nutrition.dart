import 'package:cloud_firestore/cloud_firestore.dart';

class NutritionItem {
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  NutritionItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory NutritionItem.fromMap(Map<String, dynamic> map) {
    return NutritionItem(
      name: map['name'] ?? '',
      calories: map['calories'] ?? 0,
      protein: map['protein'] ?? 0,
      carbs: map['carbs'] ?? 0,
      fat: map['fat'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}

class Nutrition {
  final String nutritionId;
  final String userId;
  final String? planId;
  final String mealType;
  final String? notes;
  final List<NutritionItem> items;
  final int totalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFat;

  Nutrition({
    required this.nutritionId,
    required this.userId,
    this.planId,
    required this.mealType,
    this.notes,
    required this.items,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });

  factory Nutrition.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List<NutritionItem> items = (data['items'] as List<dynamic>?)
            ?.map((e) => NutritionItem.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [];

    int totalCalories = items.fold(0, (sum, item) => sum + item.calories);
    int totalProtein = items.fold(0, (sum, item) => sum + item.protein);
    int totalCarbs = items.fold(0, (sum, item) => sum + item.carbs);
    int totalFat = items.fold(0, (sum, item) => sum + item.fat);

    return Nutrition(
      nutritionId: doc.id,
      userId: data['userId'] ?? '',
      planId: data['planId'],
      mealType: data['mealType'] ?? '',
      notes: data['notes'],
      items: items,
      totalCalories: data['totalCalories'] ?? totalCalories,
      totalProtein: data['totalProtein'] ?? totalProtein,
      totalCarbs: data['totalCarbs'] ?? totalCarbs,
      totalFat: data['totalFat'] ?? totalFat,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'planId': planId,
      'mealType': mealType,
      'notes': notes,
      'items': items.map((e) => e.toMap()).toList(),
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
    };
  }
}