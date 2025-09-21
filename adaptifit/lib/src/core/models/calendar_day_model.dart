import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory CalendarDayModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CalendarDayModel(
      date: doc.id,
      planId: data['planId'] ?? '',
      weekday: data['weekday'] ?? '',
      workoutId: data['workoutId'] ?? '',
      workoutType: data['workoutType'] ?? '',
      weekIndex: data['weekIndex'] ?? 0,
      workoutSequenceIndex: data['workoutSequenceIndex'] ?? 0,
      hasWorkout: data['hasWorkout'] ?? false,
      hasNutrition: data['hasNutrition'] ?? false,
      nutritionIds: List<String>.from(data['nutritionIds'] ?? []),
      status: data['status'] ?? 'not started',
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
