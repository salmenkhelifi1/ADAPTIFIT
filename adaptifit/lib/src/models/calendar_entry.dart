class CalendarEntry {
  final String id;
  final String userId;
  final DateTime date;
  final String planId;
  final String workoutId;
  final List<String> nutritionIds;
  final bool completed;

  CalendarEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.planId,
    required this.workoutId,
    required this.nutritionIds,
    required this.completed,
  });

  factory CalendarEntry.fromJson(Map<String, dynamic> json) {
    return CalendarEntry(
      id: json['_id'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      planId: json['planId'],
      workoutId: json['workoutId'],
      nutritionIds: List<String>.from(json['nutritionIds']),
      completed: json['completed'] ?? false,
    );
  }
}