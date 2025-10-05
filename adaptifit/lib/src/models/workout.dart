class Exercise {
  final String name;
  final int sets;
  final String reps;
  final String rest;
  final String instructions;

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.rest,
    required this.instructions,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] ?? '',
      sets: json['sets'] ?? 0,
      reps: json['reps'] ?? '',
      rest: json['rest'] ?? '',
      instructions: json['instructions'] ?? '',
    );
  }
}

class Workout {
  final String id;
  final String planId;
  final String name;
  final String day;
  final String duration;
  final List<String> targetMuscles;
  final List<Exercise> exercises;

  Workout({
    required this.id,
    required this.planId,
    required this.name,
    required this.day,
    required this.duration,
    required this.targetMuscles,
    required this.exercises,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    var exercisesList = json['exercises'] as List? ?? [];
    List<Exercise> exercises = exercisesList.map((i) => Exercise.fromJson(i)).toList();

    return Workout(
      id: json['_id'] ?? '',
      planId: json['planId'] ?? '',
      name: json['name'] ?? '',
      day: json['day'] ?? '',
      duration: json['duration'] ?? '',
      targetMuscles: List<String>.from(json['targetMuscles'] ?? []),
      exercises: exercises,
    );
  }
}