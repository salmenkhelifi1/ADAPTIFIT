
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/models/plan_model.dart';
import '../core/models/workout_model.dart';
import '../core/models/user_model.dart';
import '../core/models/nutrition_model.dart';
import '../core/models/calendar_day_model.dart';
import '../core/models/chat_message.dart'; // Import ChatMessage model

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
    return _db.collection('users').doc(uid).set(user.toMap());
  }

  // Get user model
  Stream<UserModel> getUser() {
    return userDoc.snapshots().map((snapshot) => UserModel.fromFirestore(snapshot));
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
  Stream<List<PlanModel>> getPlans() {
    return userDoc
        .collection('plans')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PlanModel.fromFirestore(doc))
            .toList());
  }

  // Add a new plan
  Future<DocumentReference> addPlan(PlanModel plan) {
    return userDoc.collection('plans').add(plan.toMap());
  }

  // Update a plan
  Future<void> updatePlan(String planId, PlanModel plan) {
    return userDoc.collection('plans').doc(planId).update(plan.toMap());
  }

  // Delete a plan
  Future<void> deletePlan(String planId) {
    return userDoc.collection('plans').doc(planId).delete();
  }

  //-- Workouts --//

  // Get all workouts for a specific plan
  Stream<List<WorkoutModel>> getWorkouts(String planId) {
    return userDoc
        .collection('plans')
        .doc(planId)
        .collection('workouts')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorkoutModel.fromFirestore(doc))
            .toList());
  }

  // Add a new workout to a plan
  Future<DocumentReference> addWorkout(String planId, WorkoutModel workout) {
    return userDoc
        .collection('plans')
        .doc(planId)
        .collection('workouts')
        .add(workout.toMap());
  }

  // Update a workout
  Future<void> updateWorkout(String planId, String workoutId, WorkoutModel workout) {
    return userDoc
        .collection('plans')
        .doc(planId)
        .collection('workouts')
        .doc(workoutId)
        .update(workout.toMap());
  }

  // Delete a workout
  Future<void> deleteWorkout(String planId, String workoutId) {
    return userDoc
        .collection('plans')
        .doc(planId)
        .collection('workouts')
        .doc(workoutId)
        .delete();
  }

  //-- Calendar --//

  // Get calendar entry for a specific date
  Stream<CalendarDayModel> getCalendarEntry(String date) {
    return userDoc
        .collection('calendar')
        .doc(date)
        .snapshots()
        .map((snapshot) => CalendarDayModel.fromFirestore(snapshot));
  }

  // Get all calendar entries
  Stream<List<CalendarDayModel>> getCalendarEntries() {
    return userDoc
        .collection('calendar')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CalendarDayModel.fromFirestore(doc))
            .toList());
  }

  // Set or update a calendar entry
  Future<void> setCalendarEntry(String date, CalendarDayModel data) {
    return userDoc.collection('calendar').doc(date).set(data.toMap());
  }

  //-- Nutrition --//

  // Get all nutrition plans
  Stream<List<NutritionModel>> getNutritionPlans() {
    return userDoc
        .collection('nutrition')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NutritionModel.fromFirestore(doc))
            .toList());
  }

  // Add a nutrition plan
  Future<DocumentReference> addNutritionPlan(NutritionModel nutrition) {
    return userDoc.collection('nutrition').add(nutrition.toMap());
  }

  // Update a nutrition plan
  Future<void> updateNutritionPlan(String nutritionId, NutritionModel nutrition) {
    return userDoc
        .collection('nutrition')
        .doc(nutritionId)
        .update(nutrition.toMap());
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
