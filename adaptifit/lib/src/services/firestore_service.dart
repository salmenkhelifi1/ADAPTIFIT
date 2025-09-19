import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:adaptifit/src/core/models/chat_message.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Creates a new user document in the 'users' collection
  Future<void> createUserDocument({
    required String uid,
    required String email,
    required String firstName,
  }) async {
    try {
      debugPrint('Firestore: Creating user document for UID: $uid');
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'firstName': firstName,
        'createdAt': Timestamp.now(),
        'onboardingAnswers': {},
        'onboardingCompleted': false,
        'activePlanId': null,
        'progress': {
          'currentStreak': 0,
          'longestStreak': 0,
          'completedWorkouts': 0,
          'badges': [],
        },
      });
      debugPrint('Firestore: Successfully created user document for UID: $uid');
    } catch (e) {
      debugPrint('Firestore: ERROR creating user document: $e');
    }
  }

  /// Updates an existing user's document with their onboarding answers.
  Future<void> updateOnboardingAnswers({
    required String uid,
    required Map<String, dynamic> answers,
  }) async {
    try {
      debugPrint('Firestore: Updating onboarding answers for UID: $uid');
      await _db
          .collection('users')
          .doc(uid)
          .update({'onboardingAnswers': answers, 'onboardingCompleted': true});
      debugPrint(
          'Firestore: Successfully updated onboarding answers for UID: $uid');
    } catch (e) {
      debugPrint('Firestore: ERROR updating onboarding answers: $e');
    }
  }

  /// Parses the JSON from N8N and saves the plan, workouts, and calendar entries.
  Future<void> addPlanFromN8n({
    required String userId,
    required Map<String, dynamic> planJson,
  }) async {
    try {
      debugPrint('Firestore: Starting to add plan from N8N for user: $userId');
      final WriteBatch batch = _db.batch();
      final userRef = _db.collection('users').doc(userId);

      // 1. Create the main plan document
      final planId = planJson['planId'];
      final planRef = userRef.collection('plans').doc(planId);
      batch.set(planRef, {
        'userId': userId,
        'createdAt': Timestamp.now(),
        'status': 'active',
        'planMetadata': planJson['planMetadata'],
      });
      debugPrint('Firestore: Batch - Added plan document with ID: $planId');

      // 2. Add each workout to a subcollection within the plan
      for (var workout in planJson['workouts']) {
        final workoutRef =
            planRef.collection('workouts').doc(workout['workoutId']);
        batch.set(workoutRef, workout);
      }
      debugPrint(
          'Firestore: Batch - Added ${planJson['workouts'].length} workouts.');

      // 3. Add each calendar entry to a user-level calendar collection
      planJson['calendar'].forEach((date, details) {
        final calendarRef = userRef.collection('calendar').doc(date);
        batch.set(calendarRef, details);
      });
      debugPrint(
          'Firestore: Batch - Added ${planJson['calendar'].length} calendar entries.');

      // 4. Update the user's active plan ID
      batch.update(userRef, {'activePlanId': planId});
      debugPrint('Firestore: Batch - Set activePlanId to: $planId');

      // Commit all operations as a single transaction
      await batch.commit();
      debugPrint(
          "Firestore: Successfully committed plan from N8N to Firestore for user $userId.");
    } catch (e) {
      debugPrint('Firestore: ERROR adding plan from N8N: $e');
    }
  }

  /// Retrieves a user's document from the 'users' collection
  Future<DocumentSnapshot> getUser(String uid) {
    debugPrint('Firestore: Getting user document for UID: $uid');
    return _db.collection('users').doc(uid).get();
  }

  /// Retrieves the calendar data for a user.
  Future<QuerySnapshot> getCalendarData(String uid) {
    return _db.collection('users').doc(uid).collection('calendar').get();
  }

  // --- CHAT METHODS ---

  /// Adds a new chat message to the user's chat history subcollection.
  Future<void> addChatMessage({
    required String userId,
    required ChatMessage message,
  }) async {
    try {
      debugPrint(
          'Firestore: Adding chat message for user: $userId. IsUser: ${message.isUser}');
      await _db
          .collection('users')
          .doc(userId)
          .collection('chatHistory')
          .add(message.toJson());
      debugPrint(
          'Firestore: Successfully added chat message for user: $userId');
    } catch (e) {
      debugPrint('Firestore: ERROR adding chat message: $e');
    }
  }

  /// Returns a stream of chat messages for a given user, ordered by timestamp.
  Stream<QuerySnapshot> getChatStream(String userId) {
    debugPrint('Firestore: Setting up chat stream for user: $userId');
    return _db
        .collection('users')
        .doc(userId)
        .collection('chatHistory')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}