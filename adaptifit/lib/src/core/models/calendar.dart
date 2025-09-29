import 'dart:convert'; // Required for jsonDecode
import 'package:cloud_firestore/cloud_firestore.dart';

class Calendar {
  final String dateId;
  final bool hasWorkout;
  final String? workoutId;
  final String? planId;
  final String? workoutName; // Added field to match your DB
  final String? status; // Added field to match your DB
  final bool hasNutrition;
  final List<String> nutritionIds;
  final bool completed; // Renamed from isCompleted to match your DB

  Calendar({
    required this.dateId,
    required this.hasWorkout,
    this.workoutId,
    this.planId,
    this.workoutName,
    this.status,
    required this.hasNutrition,
    required this.nutritionIds,
    this.completed = false,
  });

  factory Calendar.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // --- NEW LOGIC TO HANDLE NUTRITIONIDS STRING ---
    final dynamic nutritionIdsData = data['nutritionIds'];
    List<String> nutritionIdsList;

    if (nutritionIdsData is String && nutritionIdsData.isNotEmpty) {
      // If it's a string from n8n, decode it from JSON
      nutritionIdsList = List<String>.from(jsonDecode(nutritionIdsData));
    } else if (nutritionIdsData is List) {
      // For backwards compatibility if you have old data that is a list
      nutritionIdsList = List<String>.from(nutritionIdsData);
    } else {
      // Otherwise, default to an empty list
      nutritionIdsList = [];
    }
    // --- END OF NEW LOGIC ---

    return Calendar(
      dateId: doc.id,
      hasWorkout: data['hasWorkout'] ?? false,
      workoutId: data['workoutId'],
      planId: data['planId'],
      workoutName: data['workoutName'],
      status: data['status'],
      hasNutrition: data['hasNutrition'] ?? false,
      nutritionIds: nutritionIdsList, // Use the correctly parsed list
      completed: data['completed'] ?? false, // Fixed to use 'completed'
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'hasWorkout': hasWorkout,
      'workoutId': workoutId,
      'planId': planId,
      'workoutName': workoutName,
      'status': status,
      'hasNutrition': hasNutrition,
      // Convert list to string when sending data TO firestore
      'nutritionIds': jsonEncode(nutritionIds),
      'completed': completed,
    };
  }
}
