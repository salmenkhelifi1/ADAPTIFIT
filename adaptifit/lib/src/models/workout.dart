import 'package:cloud_firestore/cloud_firestore.dart';
import './exercise.dart';

class Workout {
  final String workoutId;
  final String planId;
  final String userId;
  final dynamic day; // Can be int or String
  final String title;
  final List<Exercise> exercises;
  final String? notes;

  Workout({
    required this.workoutId,
    required this.planId,
    required this.userId,
    required this.day,
    required this.title,
    required this.exercises,
    this.notes,
  });

  factory Workout.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Workout(
      workoutId: doc.id,
      planId: data['planId'] ?? '',
      userId: data['userId'] ?? '',
      day: data['day'],
      title: data['title'] ?? '',
      exercises: (data['exercises'] as List<dynamic>?)
              ?.map((e) => Exercise.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'planId': planId,
      'userId': userId,
      'day': day,
      'title': title,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'notes': notes,
    };
  }
}
