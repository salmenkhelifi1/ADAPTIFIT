import 'package:adaptifit/src/constants/app_colors.dart';
import 'package:adaptifit/src/models/workout.dart';
import 'package:adaptifit/src/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:adaptifit/src/models/plan.dart';

class PlanDetailsScreen extends StatefulWidget {
  final Plan plan;

  const PlanDetailsScreen({super.key, required this.plan});

  @override
  State<PlanDetailsScreen> createState() => _PlanDetailsScreenState();
}

class _PlanDetailsScreenState extends State<PlanDetailsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Workout>> _workoutsFuture;

  @override
  void initState() {
    super.initState();
    _workoutsFuture = _apiService.getWorkoutsForPlan(widget.plan.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plan.planName),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: FutureBuilder<List<Workout>>(
        future: _workoutsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No workouts found for this plan.'));
          }

          final workouts = snapshot.data!;

          return ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                color: AppColors.white,
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
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...workout.exercises.map((exercise) {
                        return ListTile(
                          title: Text(exercise.name,
                              style: const TextStyle(
                                  color: AppColors.darkText)),
                          subtitle: Text(
                              'Sets: ${exercise.sets}, Reps: ${exercise.reps}',
                              style: const TextStyle(
                                  color: AppColors.subtitleGray)),
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
