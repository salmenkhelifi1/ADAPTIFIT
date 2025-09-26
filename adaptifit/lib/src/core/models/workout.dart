import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

class Exercise {
  final String name;
  final int sets;
  final String reps; // Changed to String to handle ranges like "8-12"
  final String? rest;
  final String? instructions;
  final String? modifications;
  final String? category;
  final String? exerciseId;
  final String? targetMuscle;
  final String? weight;

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.rest,
    this.instructions,
    this.modifications,
    this.category,
    this.exerciseId,
    this.targetMuscle,
    this.weight,
  });

  // Updated factory to match the fields from your n8n/Firebase data
  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      name: map['name'] ?? '',
      sets: map['sets'] ?? 0,
      reps: map['reps']?.toString() ?? '0', // Safely handle reps
      rest: map['rest'],
      instructions: map['instructions'],
      modifications: map['modifications'],
      category: map['category'],
      exerciseId: map['exerciseId'],
      targetMuscle: map['targetMuscle'],
      weight: map['weight'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'rest': rest,
      'instructions': instructions,
      'modifications': modifications,
      'category': category,
      'exerciseId': exerciseId,
      'targetMuscle': targetMuscle,
      'weight': weight,
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
  final String? notes; // This can be kept for future use
  final List<String>? targetMuscles;
  final int? week;
  final String? duration;

  Workout({
    required this.workoutId,
    required this.userId,
    this.planId,
    required this.name,
    this.day,
    required this.exercises,
    this.notes,
    this.targetMuscles,
    this.week,
    this.duration,
  });

  // Updated factory to correctly parse the nested 'workout' map
  factory Workout.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // --- DEBUG PRINT STATEMENT ---
    // This will print the raw data from Firestore to your terminal.
    debugPrint("--- Raw Workout Data from Firestore for doc ${doc.id} ---");
    debugPrint(data.toString());
    // ---------------------------

    // The main workout data is nested inside a 'workout' map.
    // We need to access it directly.
    if (!data.containsKey('workout')) {
      debugPrint(
          "--- ERROR: 'workout' key not found in document ${doc.id} ---");
      // Return a default or error workout if the structure is wrong
      return Workout(
        workoutId: doc.id,
        userId: data['userId'] ?? '',
        planId: data['planId'],
        name: 'Invalid Workout Data',
        exercises: [],
      );
    }

    Map<String, dynamic> workoutData = data['workout'] as Map<String, dynamic>;

    return Workout(
      workoutId: doc.id,
      // userId and planId are at the top level
      userId: data['userId'] ?? '',
      planId: data['planId'],
      // The rest of the data comes from the nested map
      name: workoutData['name'] ?? 'Untitled Workout',
      day: workoutData['day'],
      exercises: (workoutData['exercises'] as List<dynamic>?)
              ?.map((e) => Exercise.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: workoutData['notes'], // Check for notes inside the nested map
      targetMuscles: workoutData['targetMuscles'] != null ? List<String>.from(workoutData['targetMuscles']) : null,
      week: workoutData['week'],
      duration: workoutData['duration'],
    );
  }

  Map<String, dynamic> toFirestore() {
    // This is for writing data back to Firestore, ensure it matches your needs
    return {
      'userId': userId,
      'planId': planId,
      // Nest the workout data to match the read structure
      'workout': {
        'name': name,
        'day': day,
        'exercises': exercises.map((e) => e.toMap()).toList(),
        'notes': notes,
        'targetMuscles': targetMuscles,
        'week': week,
        'duration': duration,
      }
    };
  }
}