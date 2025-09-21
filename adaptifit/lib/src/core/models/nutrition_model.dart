import 'package:cloud_firestore/cloud_firestore.dart';

class NutritionModel {
  final String nutritionId;
  final String mealPlanName;
  final String day;
  final List<String> meals;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  NutritionModel({
    required this.nutritionId,
    required this.mealPlanName,
    required this.day,
    required this.meals,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory NutritionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NutritionModel(
      nutritionId: doc.id,
      mealPlanName: data['mealPlanName'] ?? '',
      day: data['day'] ?? '',
      meals: List<String>.from(data['meals'] ?? []),
      calories: data['calories'] ?? 0,
      protein: data['protein'] ?? 0,
      carbs: data['carbs'] ?? 0,
      fat: data['fat'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mealPlanName': mealPlanName,
      'day': day,
      'meals': meals,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}
