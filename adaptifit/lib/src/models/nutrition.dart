
class Nutrition {
  final String id;
  final String name;
  final int calories;
  final Map<String, Meal> meals;
  final String dailyWater;

  Nutrition({
    required this.id,
    required this.name,
    required this.calories,
    required this.meals,
    required this.dailyWater,
  });

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    return Nutrition(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unnamed Nutrition',
      calories: json['calories'] ?? 0,
      meals: (json['meals'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, Meal.fromJson(value)),
      ),
      dailyWater: json['dailyWater'] ?? '0L',
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
      name: json['name'] ?? 'Unnamed Meal',
      items: List<String>.from(json['items'] ?? []),
      calories: json['calories'] ?? 0,
      protein: json['protein'] ?? 0,
    );
  }
}
