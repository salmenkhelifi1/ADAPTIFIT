class CalendarEntry {
  final String id;
  final String userId;
  final DateTime date;
  final String planId;
  final String workoutId;
  final List<String> nutritionIds;
  final bool completed;
  final bool workoutCompleted;
  final List<String> completedNutritionIds;
  final List<String> completedMeals;
  final List<int> completedExercises;

  CalendarEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.planId,
    required this.workoutId,
    required this.nutritionIds,
    required this.completed,
    required this.workoutCompleted,
    required this.completedNutritionIds,
    required this.completedMeals,
    required this.completedExercises,
  });

  factory CalendarEntry.fromJson(Map<String, dynamic> json) {
    return CalendarEntry(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      planId: json['planId'] ?? '',
      workoutId: json['workoutId'] ?? '',
      nutritionIds: List<String>.from(json['nutritionIds'] ?? []),
      completed: json['completed'] ?? false,
      workoutCompleted: json['workoutCompleted'] ?? false,
      completedNutritionIds:
          List<String>.from(json['completedNutritionIds'] ?? []),
      completedMeals: List<String>.from(json['completedMeals'] ?? []),
      completedExercises: _parseCompletedExercises(json['completedExercises']),
    );
  }

  /// Helper method to parse completed exercises from JSON
  /// Handles both string and int values from the API
  static List<int> _parseCompletedExercises(dynamic data) {
    if (data == null) return [];

    try {
      if (data is List) {
        return data.map((item) {
          if (item is int) {
            return item;
          } else if (item is String) {
            return int.tryParse(item) ?? 0;
          }
          return 0;
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error parsing completedExercises: $e');
      return [];
    }
  }
}
