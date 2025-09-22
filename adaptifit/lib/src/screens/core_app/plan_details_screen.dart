import 'package:adaptifit/src/core/models/workout_model.dart';
import 'package:adaptifit/src/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:adaptifit/src/core/models/plan_model.dart';

class PlanDetailsScreen extends StatefulWidget {
  final PlanModel plan;

  const PlanDetailsScreen({Key? key, required this.plan}) : super(key: key);

  @override
  State<PlanDetailsScreen> createState() => _PlanDetailsScreenState();
}

class _PlanDetailsScreenState extends State<PlanDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  Stream<List<WorkoutModel>>? _workoutsStream;

  @override
  void initState() {
    super.initState();
    _workoutsStream = _firestoreService.getWorkouts(widget.plan.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plan.title),
      ),
      body: StreamBuilder<List<WorkoutModel>>(
        stream: _workoutsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No workouts found for this plan.'));
          }

          final workouts = snapshot.data!;
          return ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...workout.exercises.map((exercise) {
                        return ListTile(
                          title: Text(exercise['name'] ?? ''),
                          subtitle: Text(
                              'Sets: ${exercise['sets']}, Reps: ${exercise['reps']}'),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}