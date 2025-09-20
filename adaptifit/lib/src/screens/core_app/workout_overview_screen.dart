import 'package:flutter/material.dart';

class WorkoutOverviewScreen extends StatelessWidget {
  final String workoutId;

  const WorkoutOverviewScreen({Key? key, required this.workoutId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Overview'),
      ),
      body: Center(
        child: Text('Workout Overview for workout ID: $workoutId'),
      ),
    );
  }
}
