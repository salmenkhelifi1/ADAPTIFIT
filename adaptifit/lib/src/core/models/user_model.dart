import 'package.cloud_firestore/cloud_firestore.dart';

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
  final Map<String, int> macros;
  final String? activePlanId;
  final Timestamp createdAt;
  final Timestamp updatedAt;

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
    this.activePlanId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
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
      onboardingCompleted: map['onboardingCompleted'] ?? false,
      macros: Map<String, int>.from(map['macros'] ?? {}),
      activePlanId: map['activePlanId'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
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
      'activePlanId': activePlanId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
