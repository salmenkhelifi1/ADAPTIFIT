import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adaptifit/src/services/api_service.dart';
import 'package:adaptifit/src/providers/api_service_provider.dart';
import 'package:adaptifit/src/providers/calendar_provider.dart';

// Workout Progress
class WorkoutProgressNotifier extends StateNotifier<List<int>> {
  WorkoutProgressNotifier(this.ref) : super([]);

  final Ref ref;

  Future<void> loadProgress(String workoutId, int exerciseCount) async {
    state = List<int>.filled(exerciseCount, 0);
    try {
      final date = DateTime.now();
      final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final progress = await ref.read(apiServiceProvider).getWorkoutProgress(dateString);
      if (progress['workoutId'] == workoutId) {
        final exercisesProgress = progress['exercises'] as List;
        final newProgress = List<int>.from(state);
        for (var exercise in exercisesProgress) {
          if (exercise['index'] < newProgress.length) {
            newProgress[exercise['index']] = exercise['completedSets'];
          }
        }
        state = newProgress;
      }
    } catch (e) {
      // No progress found is not an error
    }
  }

  void updateProgress(int exerciseIndex, int completedSets) {
    if (exerciseIndex < state.length) {
      final newState = List<int>.from(state);
      newState[exerciseIndex] = completedSets;
      state = newState;
    }
  }
}

final workoutProgressProvider = StateNotifierProvider<WorkoutProgressNotifier, List<int>>((ref) {
  return WorkoutProgressNotifier(ref);
});


// Nutrition Progress
class NutritionProgressNotifier extends StateNotifier<Map<String, bool>> {
  NutritionProgressNotifier(this.ref) : super({});

  final Ref ref;

  Future<void> loadProgress(List<String> mealKeys) async {
    state = {for (var key in mealKeys) key: false};
    try {
      final calendarEntry = await ref.read(todayCalendarEntryProvider.future);
      if (calendarEntry != null) {
        final newProgress = Map<String, bool>.from(state);
        for (var mealKey in calendarEntry.completedMeals) {
          if (newProgress.containsKey(mealKey)) {
            newProgress[mealKey] = true;
          }
        }
        state = newProgress;
      }
    } catch (e) {
      // No progress found is not an error
    }
  }

  void updateProgress(String mealKey, bool isCompleted) {
    final newState = Map<String, bool>.from(state);
    newState[mealKey] = isCompleted;
    state = newState;
  }

  void completeAll() {
    final newState = {for (var key in state.keys) key: true};
    state = newState;
  }
}

final nutritionProgressProvider = StateNotifierProvider<NutritionProgressNotifier, Map<String, bool>>((ref) {
  return NutritionProgressNotifier(ref);
});
