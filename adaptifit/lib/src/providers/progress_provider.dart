import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adaptifit/src/providers/api_service_provider.dart';
import 'package:adaptifit/src/providers/calendar_provider.dart';
import 'package:intl/intl.dart';

// Workout Progress
class WorkoutProgressNotifier extends StateNotifier<List<int>> {
  WorkoutProgressNotifier(this.ref) : super([]);

  final Ref ref;
  List<int> _totalSets = []; // Track total sets for each exercise

  Future<void> loadProgress(String workoutId, int exerciseCount) async {
    state = List<int>.filled(exerciseCount, 0);
    try {
      final date = DateTime.now();
      final dateString =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final progress =
          await ref.read(apiServiceProvider).getWorkoutProgress(dateString);
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

  void setTotalSets(List<int> totalSets) {
    _totalSets = List<int>.from(totalSets);
  }

  void updateProgress(int exerciseIndex, int completedSets) {
    if (exerciseIndex < state.length) {
      final newState = List<int>.from(state);
      newState[exerciseIndex] = completedSets;
      state = newState;
    }
  }

  // Method to update progress from detail screens
  void updateProgressFromDetail(int exerciseIndex, int completedSets) {
    updateProgress(exerciseIndex, completedSets);
  }

  void updateSetCompletion(
      int exerciseIndex, int completedSets, int totalSets) {
    if (exerciseIndex < state.length) {
      final newState = List<int>.from(state);
      newState[exerciseIndex] = completedSets;
      state = newState;

      // Check if all sets for all exercises are complete
      if (isWorkoutCompleted) {
        _completeWorkout();
      }
    }
  }

  bool get isWorkoutCompleted {
    if (state.isEmpty || _totalSets.isEmpty) return false;
    if (state.length != _totalSets.length) return false;

    for (int i = 0; i < state.length; i++) {
      if (state[i] < _totalSets[i]) return false;
    }
    return true;
  }

  int get completedSetCount {
    return state.fold<int>(0, (sum, completed) => sum + completed);
  }

  int get totalSetCount {
    return _totalSets.fold<int>(0, (sum, total) => sum + total);
  }

  Future<void> _completeWorkout() async {
    try {
      final date = DateTime.now();
      final dateString =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      await ref.read(apiServiceProvider).completeAllWorkout(dateString);
      ref.invalidate(todayCalendarEntryProvider);
    } catch (e) {
      // Handle error silently or log it
      print('Error completing workout: $e');
    }
  }
}

final workoutProgressProvider =
    StateNotifierProvider<WorkoutProgressNotifier, List<int>>((ref) {
  return WorkoutProgressNotifier(ref);
});

// Nutrition Progress
class NutritionProgressNotifier extends StateNotifier<Map<String, bool>> {
  NutritionProgressNotifier(this.ref) : super({});

  final Ref ref;
  int _totalMeals = 0; // Track total number of meals

  Future<void> loadProgress(List<String> mealKeys) async {
    _totalMeals = mealKeys.length;
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

    // Check if all meals are completed
    if (areAllMealsCompleted) {
      _completeNutrition();
    }
  }

  void completeAll() {
    final newState = {for (var key in state.keys) key: true};
    state = newState;

    // Check if all meals are completed
    if (areAllMealsCompleted) {
      _completeNutrition();
    }
  }

  bool get areAllMealsCompleted {
    if (state.isEmpty || _totalMeals == 0) return false;
    return state.values.where((isCompleted) => isCompleted).length ==
        _totalMeals;
  }

  int get completedMealCount {
    return state.values.where((isCompleted) => isCompleted).length;
  }

  int get totalMealCount {
    return _totalMeals;
  }

  Future<void> _completeNutrition() async {
    try {
      final date = DateTime.now();
      final dateString =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      await ref.read(apiServiceProvider).completeAllNutrition(dateString);
      ref.invalidate(todayCalendarEntryProvider);
    } catch (e) {
      // Handle error silently or log it
      print('Error completing nutrition: $e');
    }
  }
}

final nutritionProgressProvider =
    StateNotifierProvider<NutritionProgressNotifier, Map<String, bool>>((ref) {
  return NutritionProgressNotifier(ref);
});

// Providers to expose completion state
final isWorkoutCompletedProvider = Provider<bool>((ref) {
  final notifier = ref.watch(workoutProgressProvider.notifier);
  return notifier.isWorkoutCompleted;
});

final areAllMealsCompletedProvider = Provider<bool>((ref) {
  final notifier = ref.watch(nutritionProgressProvider.notifier);
  return notifier.areAllMealsCompleted;
});

// Providers to expose progress counts
final workoutProgressCountProvider = Provider<Map<String, int>>((ref) {
  final notifier = ref.watch(workoutProgressProvider.notifier);
  return {
    'completed': notifier.completedSetCount,
    'total': notifier.totalSetCount,
  };
});

final nutritionProgressCountProvider = Provider<Map<String, int>>((ref) {
  final notifier = ref.watch(nutritionProgressProvider.notifier);
  return {
    'completed': notifier.completedMealCount,
    'total': notifier.totalMealCount,
  };
});

// Stream providers for real-time progress updates
final workoutProgressStreamProvider = StreamProvider<Map<String, int>>((ref) {
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  return ref.watch(apiServiceProvider).getWorkoutProgressStream(today);
});

final nutritionProgressStreamProvider = StreamProvider<Map<String, int>>((ref) {
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  return ref.watch(apiServiceProvider).getNutritionProgressStream(today);
});
