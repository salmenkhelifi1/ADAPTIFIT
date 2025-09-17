// lib/src/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Get a reference to the Firestore database
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Creates a new user document in the 'users' collection
  Future<void> createUserDocument({
    required String uid,
    required String email,
    required String firstName,
  }) async {
    await _db.collection('users').doc(uid).set({
      'email': email,
      'firstName': firstName,
      'createdAt': Timestamp.now(),
      'onboardingAnswers': {}, // Starts empty
      'onboardingCompleted': false, // Add this flag
      'activePlanId': null,
      'progress': {
        'currentStreak': 0,
        'longestStreak': 0,
        'completedWorkouts': 0,
        'badges': [],
      },
    });
  }

  /// Updates an existing user's document with their onboarding answers.
  Future<void> updateOnboardingAnswers({
    required String uid,
    required Map<String, dynamic> answers,
  }) async {
    await _db.collection('users').doc(uid).update({
      'onboardingAnswers': answers,
      'onboardingCompleted':
          true, // Set the flag to true when answers are saved
    });
  }

  /// Adds a new plan to the 'plans' collection and updates the user's activePlanId
  Future<void> addPlan({
    required String userId,
    required Map<String, dynamic> planData, // The JSON from OpenAI
  }) async {
    // Add the plan to the 'plans' collection
    DocumentReference planRef = await _db.collection('plans').add({
      'userId': userId,
      'createdAt': Timestamp.now(),
      'status': 'active',
      'planData': planData,
    });

    // Update the user's document with the new active plan ID
    await _db.collection('users').doc(userId).update({
      'activePlanId': planRef.id,
    });
  }

  /// Retrieves a specific plan from the 'plans' collection
  Future<DocumentSnapshot> getPlan(String planId) async {
    return await _db.collection('plans').doc(planId).get();
  }

  /// Retrieves a user's document from the 'users' collection
  Future<DocumentSnapshot> getUser(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }
}
