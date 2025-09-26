import 'package:adaptifit/src/core/models/workout.dart';
import 'package:adaptifit/src/services/firestore_service.dart';
import 'package:flutter/material.dart';

class WorkoutOverviewScreen extends StatefulWidget {
  final String planId;
  final String workoutId;

  const WorkoutOverviewScreen(
      {Key? key, required this.planId, required this.workoutId})
      : super(key: key);

  @override
  _WorkoutOverviewScreenState createState() => _WorkoutOverviewScreenState();
}

class _WorkoutOverviewScreenState extends State<WorkoutOverviewScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Overview'),
      ),
      body: StreamBuilder<Workout>(
        stream: _firestoreService.getWorkout(widget.planId, widget.workoutId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Workout not found.'));
          }

          final workout = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                if (workout.day != null)
                  Text('Day: ${workout.day}',
                      style: Theme.of(context).textTheme.titleMedium),
                if (workout.duration != null)
                  Text('Duration: ${workout.duration}',
                      style: Theme.of(context).textTheme.titleMedium),
                if (workout.week != null)
                  Text('Week: ${workout.week}',
                      style: Theme.of(context).textTheme.titleMedium),
                if (workout.targetMuscles != null &&
                    workout.targetMuscles!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Wrap(
                      spacing: 8.0,
                      children: workout.targetMuscles!
                          .map((muscle) => Chip(label: Text(muscle)))
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Exercises',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Divider(),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: workout.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = workout.exercises[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            if (exercise.category != null)
                              Text('Category: ${exercise.category}'),
                            if (exercise.targetMuscle != null)
                              Text('Target: ${exercise.targetMuscle}'),
                            if (exercise.weight != null)
                              Text('Weight: ${exercise.weight}'),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Sets: ${exercise.sets}'),
                                Text('Reps: ${exercise.reps}'),
                                if (exercise.rest != null)
                                  Text('Rest: ${exercise.rest}'),
                              ],
                            ),
                            if (exercise.instructions != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text('Instructions: ${exercise.instructions}'),
                              ),
                            if (exercise.modifications != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text('Modifications: ${exercise.modifications}'),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}