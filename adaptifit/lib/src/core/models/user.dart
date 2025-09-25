import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final int age;
  final int daysPerWeek;
  final String fitnessLevel;
  final String goal;
  final String workoutStyle;
  final String dietType;
  final String planStartDate;
  final bool skipNutrition;
  final bool onboardingCompleted;
  final Map<String, dynamic> macros;
  final Map<String, dynamic> onboardingAnswers; // Added missing field
  final String? activePlanId;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  final Map<String, dynamic> progress; // Added progress field

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.daysPerWeek,
    required this.fitnessLevel,
    required this.goal,
    required this.workoutStyle,
    required this.dietType,
    required this.planStartDate,
    required this.skipNutrition,
    required this.onboardingCompleted,
    required this.macros,
    required this.onboardingAnswers, // Added to constructor
    this.activePlanId,
    required this.createdAt,
    required this.updatedAt,
    required this.progress, // Added to constructor
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] ?? 0,
      daysPerWeek: map['daysPerWeek'] ?? 3,
      fitnessLevel: map['fitnessLevel'] ?? 'beginner',
      goal: map['goal'] ?? '',
      workoutStyle: map['workoutStyle'] ?? 'split',
      dietType: map['dietType'] ?? '',
      planStartDate: map['planStartDate'] ?? '',
      skipNutrition: map['skipNutrition'] ?? false,
      progress: Map<String, dynamic>.from(map['progress'] ??
          {
            'currentStreak': 0,
            'longestStreak': 0,
            'completedWorkouts': 0,
            'badges': [],
          }), // Added
      onboardingCompleted: map['onboardingCompleted'] ?? false,
      macros: Map<String, dynamic>.from(map['macros'] ?? {}),
      onboardingAnswers:
          Map<String, dynamic>.from(map['onboardingAnswers'] ?? {}), // Added
      activePlanId: map['activePlanId'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'age': age,
      'daysPerWeek': daysPerWeek,
      'fitnessLevel': fitnessLevel,
      'goal': goal,
      'workoutStyle': workoutStyle,
      'dietType': dietType,
      'planStartDate': planStartDate,
      'skipNutrition': skipNutrition,
      'onboardingCompleted': onboardingCompleted,
      'macros': macros,
      'onboardingAnswers': onboardingAnswers, // Added
      'activePlanId': activePlanId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
