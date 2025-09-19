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

  factory NutritionModel.fromMap(String id, Map<String, dynamic> map) {
    return NutritionModel(
      nutritionId: id,
      mealPlanName: map['mealPlanName'] ?? '',
      day: map['day'] ?? '',
      meals: List<String>.from(map['meals'] ?? []),
      calories: map['calories'] ?? 0,
      protein: map['protein'] ?? 0,
      carbs: map['carbs'] ?? 0,
      fat: map['fat'] ?? 0,
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
