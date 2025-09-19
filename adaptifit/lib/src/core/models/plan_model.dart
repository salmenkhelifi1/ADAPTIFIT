import 'package:cloud_firestore/cloud_firestore.dart';

class PlanModel {
  final String id;
  final String userId;
  final Timestamp createdAt;
  final String status;
  final Map<String, dynamic> planData; // This will hold the detailed JSON plan

  PlanModel({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.status,
    required this.planData,
  });

  factory PlanModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PlanModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      status: data['status'] ?? 'active',
      planData: data['planData'] ?? {},
    );
  }
}
