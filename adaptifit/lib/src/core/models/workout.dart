// lib/src/core/models/workout.dart

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

class Exercise {
  final String name;
  final int sets;
  final String reps;
  final String? rest;
  final String? instructions;
  final String? modifications;
  final String? category;
  final String? exerciseId;
  final String? targetMuscle;
  final String? weight;
  final String? duration; // Added to handle exercises like "Plank"

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
    this.duration,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      name: map['name'] ?? '',
      sets: map['sets'] ?? 0,
      reps: map['reps']?.toString() ?? '0',
      rest: map['rest'],
      instructions: map['instructions'],
      modifications: map['modifications'],
      category: map['category'],
      exerciseId: map['exerciseId'],
      targetMuscle: map['targetMuscle'],
      weight: map['weight'],
      duration: map['duration'],
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
      'duration': duration,
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

  factory Workout.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    debugPrint("--- Parsing Workout Data for doc ${doc.id} ---");
    debugPrint(data.toString());

    Map<String, dynamic> workoutData = data.containsKey('workout') ? data['workout'] as Map<String, dynamic> : data;


    List<Exercise> exercisesList = [];
    if (workoutData.containsKey('blocksJson') && workoutData['blocksJson'] is String) {
      final List<dynamic> blocks = jsonDecode(workoutData['blocksJson']);
      for (var block in blocks) {
        if (block['items'] is List) {
          for (var item in block['items']) {
            exercisesList.add(Exercise.fromMap({
              'name': item['name'],
              'sets': item['sets'],
              'reps': item['reps_or_duration'],
              'rest': item['rest'],
              'instructions': item['coaching_cue'],
            }));
          }
        }
      }
    } else if (workoutData.containsKey('exercises') && workoutData['exercises'] is List) {
        exercisesList = (workoutData['exercises'] as List)
            .map((e) => Exercise.fromMap(e as Map<String, dynamic>))
            .toList();
    }


    return Workout(
      workoutId: doc.id,
      userId: data['userId'] ?? '',
      planId: data['planId'],
      name: workoutData['name'] ?? 'Untitled Workout',
      day: workoutData['day'],
      exercises: exercisesList,
      notes: workoutData['notes'] ?? workoutData['description'],
      targetMuscles: workoutData['targetMuscles'] != null
          ? List<String>.from(workoutData['targetMuscles'])
          : null,
      week: workoutData['week'],
      duration: workoutData['duration'],
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
      'targetMuscles': targetMuscles,
      'week': week,
      'duration': duration,
    };
  }
}
