class Macros {
  final String carbs;
  final String fats;
  final String protein;

  Macros({required this.carbs, required this.fats, required this.protein});

  factory Macros.fromJson(Map<String, dynamic> json) {
    return Macros(
      carbs: json['carbs'] ?? '',
      fats: json['fats'] ?? '',
      protein: json['protein'] ?? '',
    );
  }
}

class Meal {
  final String name;
  final List<String> items;
  final int calories;
  final int protein;

  Meal({
    required this.name,
    required this.items,
    required this.calories,
    required this.protein,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      name: json['name'] ?? '',
      items: List<String>.from(json['items'] ?? []),
      calories: json['calories'] ?? 0,
      protein: json['protein'] ?? 0,
    );
  }
}

class Nutrition {
  final String id;
  final String planId;
  final String name;
  final int dailyCalories;
  final String dailyWater;
  final Macros macros;
  final Map<String, Meal> meals;

  Nutrition({
    required this.id,
    required this.planId,
    required this.name,
    required this.dailyCalories,
    required this.dailyWater,
    required this.macros,
    required this.meals,
  });

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    var mealsMap = json['meals'] as Map<String, dynamic>? ?? {};
    Map<String, Meal> meals = mealsMap.map((key, value) => MapEntry(key, Meal.fromJson(value)));

    return Nutrition(
      id: json['_id'] ?? '',
      planId: json['planId'] ?? '',
      name: json['name'] ?? '',
      dailyCalories: json['dailyCalories'] ?? 0,
      dailyWater: json['dailyWater'] ?? '',
      macros: json['macros'] != null ? Macros.fromJson(json['macros']) : Macros(carbs: '', fats: '', protein: ''),
      meals: meals,
    );
  }
}