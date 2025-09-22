class NutritionItem {
  final String name;
  final int calories;
  final int protein;

  NutritionItem({
    required this.name,
    required this.calories,
    required this.protein,
  });

  factory NutritionItem.fromMap(Map<String, dynamic> map) {
    return NutritionItem(
      name: map['name'] ?? '',
      calories: map['calories'] ?? 0,
      protein: map['protein'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
    };
  }
}
