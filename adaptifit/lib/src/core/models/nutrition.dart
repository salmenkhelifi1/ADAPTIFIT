// lib/src/core/models/nutrition.dart

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
  final String name;
  final String? planId; // Added to link to a workout plan
  final Map<String, Meal> meals;
  final String? dailyWater;
  final int dailyCalories;
  final List<String> guidelines;
  final List<String> mealSuggestions;
  final Map<String, String> macros;

  Nutrition({
    required this.nutritionId,
    this.name = '',
    this.planId,
    this.meals = const {},
    this.dailyWater,
    this.dailyCalories = 0,
    this.guidelines = const [],
    this.mealSuggestions = const [],
    this.macros = const {},
  });

  factory Nutrition.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    var mealData = data['meals'] as Map<String, dynamic>? ?? {};
    Map<String, Meal> mealsMap = mealData.map((key, value) {
      return MapEntry(key, Meal.fromMap(value as Map<String, dynamic>));
    });

    // Generate a name from meal suggestions if 'name' is not present
    String planName = data['name'] ?? 'Personalized Meal Plan';
    if ((data['name'] == null || data['name'].isEmpty) &&
        (data['mealSuggestions'] as List).isNotEmpty) {
      planName = (data['mealSuggestions'] as List<dynamic>)
          .first
          .toString()
          .split(':')[0];
    }

    return Nutrition(
      nutritionId: doc.id,
      planId: data['planId'],
      name: planName,
      meals: mealsMap,
      dailyWater: data['dailyWater'],
      dailyCalories: data['dailyCalories'] ?? 0,
      guidelines: List<String>.from(data['guidelines'] ?? []),
      mealSuggestions: List<String>.from(data['mealSuggestions'] ?? []),
      macros: Map<String, String>.from(data['macros'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'planId': planId,
      'meals': meals.map((key, value) => MapEntry(key, value.toMap())),
      'dailyWater': dailyWater,
      'dailyCalories': dailyCalories,
      'guidelines': guidelines,
      'mealSuggestions': mealSuggestions,
      'macros': macros,
    };
  }
}
