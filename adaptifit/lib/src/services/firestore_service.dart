// lib/src/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:adaptifit/src/core/models/models.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:intl/intl.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => FirebaseAuth.instance.currentUser;

  // Get user document reference
  DocumentReference<Map<String, dynamic>> get userDoc {
    final user = currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    return _db.collection('users').doc(user.uid);
  }

  // Create a new user document
  Future<void> createUserDocument({
    required String uid,
    required String email,
    required String firstName,
  }) {
    final user = UserModel(
      id: uid,
      name: firstName,
      email: email,
      age: 0,
      daysPerWeek: 3,
      fitnessLevel: 'beginner',
      goal: '',
      workoutStyle: 'split',
      dietType: '',
      planStartDate: '',
      skipNutrition: false,
      onboardingCompleted: false,
      macros: {},
      onboardingAnswers: {},
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      progress: {},
    );
    return _db.collection('users').doc(uid).set(user.toFirestore());
  }

  // Get user model stream
  Stream<UserModel> getUser() {
    return userDoc
        .snapshots()
        .map((snapshot) => UserModel.fromFirestore(snapshot));
  }

  // Update onboarding answers
  Future<void> updateOnboardingAnswers(Map<String, dynamic> answers) {
    return userDoc.update({
      'onboardingAnswers': answers,
      'onboardingCompleted': true,
      'updatedAt': Timestamp.now(),
    });
  }

  //-- Plans --//

  // Get all plans for the current user
  Stream<List<Plan>> getPlans() {
    return userDoc.collection('plans').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Plan.fromFirestore(doc)).toList());
  }

  //-- Workouts --//

  // Get all workouts for a user
  Stream<List<Workout>> getWorkouts() {
    return userDoc
        .collection('workouts')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Workout.fromFirestore(doc)).toList();
    });
  }

  // Get a single workout
  Stream<Workout> getWorkout(String workoutId) {
    return userDoc
        .collection('workouts')
        .doc(workoutId)
        .snapshots()
        .map((doc) => Workout.fromFirestore(doc));
  }

  //-- Calendar --//

  // Get calendar entry for a specific date
  Stream<Calendar> getCalendarEntry(String date) {
    return userDoc
        .collection('calendar')
        .doc(date)
        .snapshots()
        .map((snapshot) => Calendar.fromFirestore(snapshot));
  }

  // Get all calendar entries
  Stream<List<Calendar>> getCalendarEntries() {
    return userDoc.collection('calendar').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Calendar.fromFirestore(doc)).toList());
  }

  // Get upcoming calendar entries for the next 7 days
  Stream<List<Calendar>> getUpcomingCalendarEntries() {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return userDoc
        .collection('calendar')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: todayStr)
        .orderBy(FieldPath.documentId)
        .limit(7) // Fetch today and the next 6 days
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Calendar.fromFirestore(doc)).toList());
  }

  // Set or update a calendar entry
  Future<void> setCalendarEntry(String date, Calendar data) {
    return userDoc.collection('calendar').doc(date).set(data.toFirestore());
  }

  // NEW: Update the completion status of a calendar entry
  Future<void> updateCalendarEntryCompletion(String date, bool isCompleted) {
    return userDoc.collection('calendar').doc(date).update({
      'completed': isCompleted,
    });
  }

  //-- Nutrition --//

  // Get all nutrition plans
  Stream<List<Nutrition>> getNutritionPlans() {
    return userDoc.collection('nutrition').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Nutrition.fromFirestore(doc)).toList());
  }

  // Get multiple nutrition plans by their IDs
  Stream<List<Nutrition>> getNutritionsByIds(List<String> ids) {
    if (ids.isEmpty) {
      return Stream.value([]);
    }
    return userDoc
        .collection('nutrition')
        .where(FieldPath.documentId, whereIn: ids)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Nutrition.fromFirestore(doc)).toList());
  }

  // Get a single nutrition plan by its associated Plan ID
  Stream<Nutrition?> getNutritionByPlanId(String planId) {
    return userDoc
        .collection('nutrition')
        .where('planId', isEqualTo: planId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null; // Return null if no matching nutrition plan is found
      }
      return Nutrition.fromFirestore(snapshot.docs.first);
    });
  }

  // Get a single nutrition plan
  Stream<Nutrition> getNutrition(String nutritionId) {
    return userDoc
        .collection('nutrition')
        .doc(nutritionId)
        .snapshots()
        .map((doc) => Nutrition.fromFirestore(doc));
  }

  // Add a nutrition plan
  Future<DocumentReference> addNutritionPlan(Nutrition nutrition) {
    return userDoc.collection('nutrition').add(nutrition.toFirestore());
  }

  // Update a nutrition plan
  Future<void> updateNutritionPlan(String nutritionId, Nutrition nutrition) {
    return userDoc
        .collection('nutrition')
        .doc(nutritionId)
        .update(nutrition.toFirestore());
  }

  // Delete a nutrition plan
  Future<void> deleteNutritionPlan(String nutritionId) {
    return userDoc.collection('nutrition').doc(nutritionId).delete();
  }

  //-- Chat --//

  // Add a new chat message
  Future<void> addChatMessage(ChatMessage message) {
    return userDoc.collection('chatMessages').add(message.toJson());
  }

  // Get chat messages for the current user
  Stream<List<ChatMessage>> getChatMessages() {
    return userDoc
        .collection('chatMessages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc.data()))
            .toList());
  }

  //-- Progress Stats --//
  /// Calculates user progress stats by querying the database.
  Future<Map<String, int>> getUserProgressStats() async {
    final user = currentUser;
    if (user == null) {
      debugPrint('[Stats] User not logged in, returning zeros.');
      return {'completedWorkouts': 0, 'mealsCompleted': 0, 'weeks': 0};
    }

    debugPrint(
        '[Stats] Starting to fetch progress stats for user: ${user.uid}');

    final userDocument = await userDoc.get();
    if (!userDocument.exists) {
      debugPrint('[Stats] User document not found!');
      throw Exception('User document not found!');
    }

    final calendarRef = userDoc.collection('calendar');

    final workoutQuery = calendarRef
        .where('hasWorkout', isEqualTo: true)
        .where('completed', isEqualTo: true)
        .count();

    final mealQuery = calendarRef
        .where('hasNutrition', isEqualTo: true)
        .where('completed', isEqualTo: true)
        .count();

    final responses = await Future.wait([
      workoutQuery.get(),
      mealQuery.get(),
    ]);

    final completedWorkouts = responses[0].count ?? 0;
    final mealsCompleted = responses[1].count ?? 0;

    debugPrint('[Stats] Completed Workouts Found: $completedWorkouts');
    debugPrint('[Stats] Completed Meals Found: $mealsCompleted');

    final createdAtTimestamp = userDocument.data()?['createdAt'] as Timestamp;
    final createdAtDate = createdAtTimestamp.toDate();
    final weeks = DateTime.now().difference(createdAtDate).inDays ~/ 7;

    debugPrint('[Stats] Weeks since creation: $weeks');

    final result = {
      'completedWorkouts': completedWorkouts,
      'mealsCompleted': mealsCompleted,
      'weeks': weeks,
    };

    debugPrint('[Stats] Returning final stats: $result');

    return result;
  }
}
