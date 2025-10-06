import 'package:adaptifit/src/constants/app_colors.dart';
import 'package:adaptifit/src/models/workout.dart';
import 'package:adaptifit/src/providers/plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adaptifit/src/models/plan.dart';
import 'package:adaptifit/src/providers/plan_provider.dart';

class PlanDetailsScreen extends ConsumerWidget {
  final Plan plan;

  const PlanDetailsScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsValue = ref.watch(workoutsForPlanProvider(plan.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(plan.planName),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: workoutsValue.when(
        data: (workouts) {
          if (workouts.isEmpty) {
            return const Center(
                child: Text('No workouts found for this plan.'));
          }

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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}