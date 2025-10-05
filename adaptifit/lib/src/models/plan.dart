class Plan {
  final String id;
  final String userId;
  final String planName;
  final int duration;
  final String difficulty;
  final DateTime startDate;
  final DateTime endDate;

  Plan({
    required this.id,
    required this.userId,
    required this.planName,
    required this.duration,
    required this.difficulty,
    required this.startDate,
    required this.endDate,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['_id'],
      userId: json['userId'],
      planName: json['planName'],
      duration: json['duration'],
      difficulty: json['difficulty'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }
}