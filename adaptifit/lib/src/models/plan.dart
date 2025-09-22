import 'package:cloud_firestore/cloud_firestore.dart';

class Plan {
  final String planId;
  final String userId;
  final String title;
  final String goal;
  final String duration;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Plan({
    required this.planId,
    required this.userId,
    required this.title,
    required this.goal,
    required this.duration,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Plan.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Plan(
      planId: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      goal: data['goal'] ?? '',
      duration: data['duration'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'goal': goal,
      'duration': duration,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
