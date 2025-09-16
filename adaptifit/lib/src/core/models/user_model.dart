// lib/src/core/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String firstName;
  final Timestamp createdAt;
  final Map<String, dynamic> onboardingAnswers;
  final String? activePlanId;

  UserModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.createdAt,
    required this.onboardingAnswers,
    this.activePlanId,
  });

  // A factory constructor to create a UserModel from a Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      onboardingAnswers: data['onboardingAnswers'] ?? {},
      activePlanId: data['activePlanId'],
    );
  }

  // A method to convert the UserModel to a Map for writing to Firestore
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'createdAt': createdAt,
      'onboardingAnswers': onboardingAnswers,
      'activePlanId': activePlanId,
    };
  }
}

// You should create similar models for your 'Plan' and 'CoachChat' data.
