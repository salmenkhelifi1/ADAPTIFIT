import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:adaptifit/src/core/models/models.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => FirebaseAuth.instance.currentUser;
  // Get user document
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

  // Get user model
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

  // Get a single workout
  Stream<Workout> getWorkout(String planId, String workoutId) {
    return userDoc
        .collection('plans')
        .doc(planId)
        .collection('workouts')
        .doc(workoutId)
        .snapshots()
        .map((doc) => Workout.fromFirestore(doc));
  }

  //-- Workouts --//

  // Get all workouts for a specific plan
  Stream<List<Workout>> getWorkouts(String planId) {
    return userDoc
        .collection('plans')
        .doc(planId)
        .collection('workouts')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Workout.fromFirestore(doc)).toList();
    });
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

  // Set or update a calendar entry
  Future<void> setCalendarEntry(String date, Calendar data) {
    return userDoc.collection('calendar').doc(date).set(data.toFirestore());
  }

  //-- Nutrition --//

  // Get all nutrition plans
  Stream<List<Nutrition>> getNutritionPlans() {
    return userDoc.collection('nutrition').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Nutrition.fromFirestore(doc)).toList());
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
        .orderBy('timestamp', descending: true) // Order by timestamp descending
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc.data()))
            .toList());
  }
}
