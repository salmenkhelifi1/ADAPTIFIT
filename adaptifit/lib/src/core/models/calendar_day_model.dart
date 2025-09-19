class CalendarDayModel {
  final String date;
  final String planId;
  final String weekday;
  final String workoutId;
  final String workoutType;
  final int weekIndex;
  final int workoutSequenceIndex;
  final bool hasWorkout;
  final bool hasNutrition;
  final List<String> nutritionIds;
  final String status;

  CalendarDayModel({
    required this.date,
    required this.planId,
    required this.weekday,
    required this.workoutId,
    required this.workoutType,
    required this.weekIndex,
    required this.workoutSequenceIndex,
    required this.hasWorkout,
    required this.hasNutrition,
    required this.nutritionIds,
    required this.status,
  });

  factory CalendarDayModel.fromMap(String date, Map<String, dynamic> map) {
    return CalendarDayModel(
      date: date,
      planId: map['planId'] ?? '',
      weekday: map['weekday'] ?? '',
      workoutId: map['workoutId'] ?? '',
      workoutType: map['workoutType'] ?? '',
      weekIndex: map['weekIndex'] ?? 0,
      workoutSequenceIndex: map['workoutSequenceIndex'] ?? 0,
      hasWorkout: map['hasWorkout'] ?? false,
      hasNutrition: map['hasNutrition'] ?? false,
      nutritionIds: List<String>.from(map['nutritionIds'] ?? []),
      status: map['status'] ?? 'not started',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'planId': planId,
      'weekday': weekday,
      'workoutId': workoutId,
      'workoutType': workoutType,
      'weekIndex': weekIndex,
      'workoutSequenceIndex': workoutSequenceIndex,
      'hasWorkout': hasWorkout,
      'hasNutrition': hasNutrition,
      'nutritionIds': nutritionIds,
      'status': status,
    };
  }
}
