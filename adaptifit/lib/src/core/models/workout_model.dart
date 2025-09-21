
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutModel {
  final String id;
  final String name;
  final List<Map<String, dynamic>> exercises;

  WorkoutModel({
    required this.id,
    required this.name,
    required this.exercises,
  });

  factory WorkoutModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WorkoutModel(
      id: doc.id,
      name: data['name'] ?? '',
      exercises: List<Map<String, dynamic>>.from(data['exercises'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'exercises': exercises,
    };
  }
}
