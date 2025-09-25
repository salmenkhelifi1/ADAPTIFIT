import 'package:cloud_firestore/cloud_firestore.dart';

class Calendar {
  final String calendarId;
  final String userId;
  final String date;
  final String? planId;
  final String? workoutId;
  final String? workoutName;
  final String? notes;
  final String status;
  final bool completed;
  final Timestamp? reminder;
  final String? weekday;
  final String? workoutType;
  final int? weekIndex;
  final int? workoutSequenceIndex;
  final bool hasWorkout;
  final bool hasNutrition;
  final List<String> nutritionIds;

  Calendar({
    required this.calendarId,
    required this.userId,
    required this.date,
    this.planId,
    this.workoutId,
    this.workoutName,
    this.notes,
    required this.status,
    required this.completed,
    this.reminder,
    this.weekday,
    this.workoutType,
    this.weekIndex,
    this.workoutSequenceIndex,
    required this.hasWorkout,
    required this.hasNutrition,
    required this.nutritionIds,
  });

  factory Calendar.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Calendar(
      calendarId: doc.id,
      userId: data['userId'] ?? '',
      date: data['date'] ?? '',
      planId: data['planId'],
      workoutId: data['workoutId'],
      workoutName: data['workoutName'],
      notes: data['notes'],
      status: data['status'] ?? 'scheduled',
      completed: data['completed'] ?? false,
      reminder: data['reminder'],
      weekday: data['weekday'],
      workoutType: data['workoutType'],
      weekIndex: data['weekIndex'],
      workoutSequenceIndex: data['workoutSequenceIndex'],
      hasWorkout: data['hasWorkout'] ?? false,
      hasNutrition: data['hasNutrition'] ?? false,
      nutritionIds: List<String>.from(data['nutritionIds'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': date,
      'planId': planId,
      'workoutId': workoutId,
      'workoutName': workoutName,
      'notes': notes,
      'status': status,
      'completed': completed,
      'reminder': reminder,
      'weekday': weekday,
      'workoutType': workoutType,
      'weekIndex': weekIndex,
      'workoutSequenceIndex': workoutSequenceIndex,
      'hasWorkout': hasWorkout,
      'hasNutrition': hasNutrition,
      'nutritionIds': nutritionIds,
    };
  }
}