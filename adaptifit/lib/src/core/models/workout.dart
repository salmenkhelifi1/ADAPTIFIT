import 'package:cloud_firestore/cloud_firestore.dart';

class Exercise {
  final String name;
  final int sets;
  final int reps;
  final int? rest;
  final String? notes;

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.rest,
    this.notes,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      name: map['name'] ?? '',
      sets: map['sets'] ?? 0,
      reps: map['reps'] ?? 0,
      rest: map['rest'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'rest': rest,
      'notes': notes,
    };
  }
}

class Workout {
  final String workoutId;
  final String userId;
  final String? planId;
  final String name;
  final String? day;
  final List<Exercise> exercises;
  final String? notes;

  Workout({
    required this.workoutId,
    required this.userId,
    this.planId,
    required this.name,
    this.day,
    required this.exercises,
    this.notes,
  });

  factory Workout.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, dynamic> workoutData = data['workout'] ?? data;

    return Workout(
      workoutId: doc.id,
      userId: data['userId'] ?? '',
      planId: data['planId'],
      name: workoutData['name'] ?? 'Untitled Workout',
      day: workoutData['day'],
      exercises: (workoutData['exercises'] as List<dynamic>?)
              ?.map((e) => Exercise.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'planId': planId,
      'name': name,
      'day': day,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'notes': notes,
    };
  }
}