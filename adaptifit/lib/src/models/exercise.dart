class Exercise {
  final String name;
  final int sets;
  final int reps;

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      name: map['name'] ?? '',
      sets: map['sets'] ?? 0,
      reps: map['reps'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
    };
  }
}
