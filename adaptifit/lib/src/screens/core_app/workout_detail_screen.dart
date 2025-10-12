import 'package:adaptifit/src/constants/app_colors.dart';
import 'package:adaptifit/src/models/workout.dart';
import 'package:adaptifit/src/providers/today_plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkoutDetailScreen extends ConsumerStatefulWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  ConsumerState<WorkoutDetailScreen> createState() =>
      _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen> {
  @override
  void initState() {
    super.initState();
    // No need to manually load progress - the TodayPlanNotifier handles this
  }

  int get totalSetSlots =>
      widget.workout.exercises.fold<int>(0, (acc, ex) => acc + (ex.sets));

  Future<void> _updateProgress(int exerciseIndex, int sets) async {
    try {
      await ref
          .read(todayPlanNotifierProvider.notifier)
          .updateSetProgress(exerciseIndex, sets);
    } catch (e) {
      debugPrint("Error updating workout progress: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sync progress.')),
        );
      }
    }
  }

  Future<void> _completeAllExercises() async {
    try {
      await ref.read(todayPlanNotifierProvider.notifier).completeAllExercises();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All exercises completed!')),
        );
      }
    } catch (e) {
      debugPrint("Error completing all exercises: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to complete all exercises.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final workout = widget.workout;
    final exercises = workout.exercises;
    final exercisesCount = exercises.length;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.screenBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Workout Plan',
            style: const TextStyle(color: AppColors.darkText)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.workout.name,
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText)),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.access_time,
                  size: 18, color: AppColors.primaryGreen),
              const SizedBox(width: 6),
              Text(widget.workout.duration,
                  style: const TextStyle(color: AppColors.darkText)),
              const SizedBox(width: 16),
              const Icon(Icons.fitness_center,
                  size: 18, color: AppColors.primaryGreen),
              const SizedBox(width: 6),
              Text('$exercisesCount exercises',
                  style: const TextStyle(color: AppColors.darkText)),
            ]),
            const SizedBox(height: 16),
            _buildProgressCard(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _completeAllExercises,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text('Complete All Exercises',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
            const SizedBox(height: 16),
            const Text('Exercises',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: AppColors.darkText)),
            const SizedBox(height: 12),
            ...exercises
                .asMap()
                .entries
                .map((entry) => _buildExerciseCard(entry.key, entry.value))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final todayPlanState = ref.watch(todayPlanNotifierProvider);
    final setProgressCounts = todayPlanState.workoutProgressCount;
    final totalCompletedSlots = setProgressCounts['completed']!;
    final setProgress =
        totalSetSlots == 0 ? 0.0 : totalCompletedSlots / totalSetSlots;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              spreadRadius: 2,
              blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Progress',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Text('${totalCompletedSlots}/${totalSetSlots} sets',
                  style: const TextStyle(color: AppColors.subtitleGray)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: setProgress,
              minHeight: 8,
              backgroundColor: AppColors.lightGrey2,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildExerciseCard(int index, Exercise exercise) {
    final reps = exercise.reps;
    final rest = exercise.rest;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              spreadRadius: 2,
              blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(exercise.name,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.darkText)),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.fitness_center,
                size: 16, color: AppColors.subtitleGray),
            const SizedBox(width: 6),
            Text('${exercise.sets} sets',
                style: const TextStyle(color: AppColors.subtitleGray)),
            const SizedBox(width: 12),
            const Icon(Icons.change_circle_outlined,
                size: 16, color: AppColors.subtitleGray),
            const SizedBox(width: 6),
            Text(reps, style: const TextStyle(color: AppColors.subtitleGray)),
            const SizedBox(width: 12),
            const Icon(Icons.access_time,
                size: 16, color: AppColors.subtitleGray),
            const SizedBox(width: 6),
            Text('$rest rest',
                style: const TextStyle(color: AppColors.subtitleGray)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const Text('Sets:', style: TextStyle(color: AppColors.darkText)),
            const SizedBox(width: 10),
            ...List.generate(
                exercise.sets, (slot) => _buildSetCheckbox(index, slot)),
          ]),
          if (exercise.instructions.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(exercise.instructions,
                style: const TextStyle(color: AppColors.subtitleGray)),
          ]
        ],
      ),
    );
  }

  Widget _buildSetCheckbox(int exerciseIndex, int slotIndex) {
    final todayPlanState = ref.watch(todayPlanNotifierProvider);
    final workoutProgress =
        todayPlanState.workoutProgress.valueOrNull ?? <int, int>{};
    final completedSets = workoutProgress[exerciseIndex] ?? 0;
    final isChecked = completedSets > slotIndex;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () {
          int newCompletedSets;
          if (isChecked) {
            newCompletedSets = slotIndex;
          } else {
            newCompletedSets = slotIndex + 1;
          }
          _updateProgress(exerciseIndex, newCompletedSets);
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.timestampGray),
            color: isChecked ? AppColors.primaryGreen : Colors.white,
          ),
          child: isChecked
              ? const Icon(Icons.check, size: 18, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}
