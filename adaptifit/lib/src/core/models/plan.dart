import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Plan {
  final String planId;
  final String userId;
  final String planName;
  final String? goal;
  final String planType;
  final String duration;
  final String difficulty;
  final String status;
  final Timestamp createdAt;
  final Timestamp? lastModified;
  final String? startDate;
  final String? endDate;

  Plan({
    required this.planId,
    required this.userId,
    required this.planName,
    this.goal,
    required this.planType,
    required this.duration,
    required this.difficulty,
    required this.status,
    required this.createdAt,
    this.lastModified,
    this.startDate,
    this.endDate,
  });

  factory Plan.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Plan(
      planId: doc.id,
      userId: data['userId'] ?? '',
      planName: data['planName'] ?? data['title'] ?? 'Unnamed Plan',
      goal: data['goal'],
      planType: data['planType'] ?? 'general_fitness',
      duration: data['duration'] ?? 'N/A',
      difficulty: data['difficulty'] ?? 'beginner',
      status: data['status'] ?? 'inactive',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      lastModified: data['lastModified'] ?? data['updatedAt'],
      startDate: data['startDate'],
      endDate: data['endDate'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'planName': planName,
      'goal': goal,
      'planType': planType,
      'duration': duration,
      'difficulty': difficulty,
      'status': status,
      'createdAt': createdAt,
      'lastModified': lastModified,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}