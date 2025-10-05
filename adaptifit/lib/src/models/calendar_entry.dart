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
  });

  factory CalendarEntry.fromJson(Map<String, dynamic> json) {
    return CalendarEntry(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      planId: json['planId'] ?? '',
      workoutId: json['workoutId'] ?? '',
      nutritionIds: List<String>.from(json['nutritionIds'] ?? []),
      completed: json['completed'] ?? false,
      workoutCompleted: json['workoutCompleted'] ?? false,
      completedNutritionIds: List<String>.from(json['completedNutritionIds'] ?? []),
    );
  }
}