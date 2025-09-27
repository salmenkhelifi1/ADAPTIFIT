import 'package:cloud_firestore/cloud_firestore.dart';

class Calendar {
  // FIX: Added this field to store the document ID
  final String dateId;
  final bool hasWorkout;
  final String? workoutId;
  final String? planId;
  final bool hasNutrition;
  final List<String> nutritionIds;
  final bool isCompleted;

  Calendar({
    required this.dateId,
    required this.hasWorkout,
    this.workoutId,
    this.planId,
    required this.hasNutrition,
    required this.nutritionIds,
    this.isCompleted = false,
  });

  factory Calendar.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Calendar(
      // FIX: Populate the dateId from the document ID
      dateId: doc.id,
      hasWorkout: data['hasWorkout'] ?? false,
      workoutId: data['workoutId'],
      planId: data['planId'],
      hasNutrition: data['hasNutrition'] ?? false,
      nutritionIds: List<String>.from(data['nutritionIds'] ?? []),
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'hasWorkout': hasWorkout,
      'workoutId': workoutId,
      'planId': planId,
      'hasNutrition': hasNutrition,
      'nutritionIds': nutritionIds,
      'isCompleted': isCompleted,
    };
  }

  // ADDED: copyWith method for easier updates
  Calendar copyWith({
    String? dateId,
    bool? hasWorkout,
    String? workoutId,
    String? planId,
    bool? hasNutrition,
    List<String>? nutritionIds,
    bool? isCompleted,
  }) {
    return Calendar(
      dateId: dateId ?? this.dateId,
      hasWorkout: hasWorkout ?? this.hasWorkout,
      workoutId: workoutId ?? this.workoutId,
      planId: planId ?? this.planId,
      hasNutrition: hasNutrition ?? this.hasNutrition,
      nutritionIds: nutritionIds ?? this.nutritionIds,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
