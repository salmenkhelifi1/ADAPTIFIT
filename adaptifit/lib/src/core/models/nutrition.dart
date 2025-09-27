import 'package:cloud_firestore/cloud_firestore.dart';

class Meal {
  final String name;
  final List<String> items;
  final int calories;
  final int protein;

  Meal({
    this.name = '',
    this.items = const [],
    this.calories = 0,
    this.protein = 0,
  });

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      name: map['name'] ?? '',
      items: List<String>.from(map['items'] ?? []),
      calories: map['calories'] ?? 0,
      protein: map['protein'] ?? 0,
    );
  }

  // Method to convert a Meal object to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'items': items,
      'calories': calories,
      'protein': protein,
    };
  }
}

class Nutrition {
  final String nutritionId;
  final String name; // e.g., "High Protein Focus"
  final Map<String, Meal>
      meals; // Keys: "breakfast", "lunch", "dinner", "snacks"
  final double hydrationGoal; // In Liters
  final int totalCalories;
  final int totalProtein;

  Nutrition({
    required this.nutritionId,
    this.name = '',
    this.meals = const {},
    this.hydrationGoal = 0.0,
    this.totalCalories = 0,
    this.totalProtein = 0,
  });

  factory Nutrition.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    var mealData = data['meals'] as Map<String, dynamic>? ?? {};
    Map<String, Meal> mealsMap = mealData.map((key, value) {
      return MapEntry(key, Meal.fromMap(value as Map<String, dynamic>));
    });

    return Nutrition(
      nutritionId: doc.id,
      name: data['name'] ?? 'Personalized meal plan',
      meals: mealsMap,
      hydrationGoal: (data['hydrationGoal'] as num?)?.toDouble() ?? 0.0,
      totalCalories: data['totalCalories'] ?? 0,
      totalProtein: data['totalProtein'] ?? 0,
    );
  }

  // FIX: Added the missing toFirestore method
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      // Convert the Meal objects back to Maps for Firestore
      'meals': meals.map((key, value) => MapEntry(key, value.toMap())),
      'hydrationGoal': hydrationGoal,
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
    };
  }
}
