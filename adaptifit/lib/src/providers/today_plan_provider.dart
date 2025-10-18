import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';
import 'package:adaptifit/src/models/calendar_entry.dart';
import 'package:adaptifit/src/models/workout.dart';
import 'package:adaptifit/src/models/nutrition.dart';
import 'package:adaptifit/src/providers/api_service_provider.dart';
import 'package:adaptifit/src/providers/calendar_provider.dart';
import 'package:adaptifit/src/providers/weekly_progress_provider.dart';

part 'today_plan_provider.g.dart';

// 1. DEFINE THE STATE CLASS (this should already exist)
class TodayPlanState {
  final AsyncValue<CalendarEntry?> entry;
  final AsyncValue<Workout?> workout;
  final AsyncValue<Nutrition?> nutrition;
  final AsyncValue<Map<int, int>> workoutProgress;
  final AsyncValue<Map<String, bool>> nutritionProgress;
  final AsyncValue<Map<int, bool>> exerciseProgress;

  const TodayPlanState({
    this.entry = const AsyncLoading(),
    this.workout = const AsyncLoading(),
    this.nutrition = const AsyncLoading(),
    this.workoutProgress = const AsyncLoading(),
    this.nutritionProgress = const AsyncLoading(),
    this.exerciseProgress = const AsyncLoading(),
  });

  TodayPlanState copyWith({
    AsyncValue<CalendarEntry?>? entry,
    AsyncValue<Workout?>? workout,
    AsyncValue<Nutrition?>? nutrition,
    AsyncValue<Map<int, int>>? workoutProgress,
    AsyncValue<Map<String, bool>>? nutritionProgress,
    AsyncValue<Map<int, bool>>? exerciseProgress,
  }) {
    return TodayPlanState(
      entry: entry ?? this.entry,
      workout: workout ?? this.workout,
      nutrition: nutrition ?? this.nutrition,
      workoutProgress: workoutProgress ?? this.workoutProgress,
      nutritionProgress: nutritionProgress ?? this.nutritionProgress,
      exerciseProgress: exerciseProgress ?? this.exerciseProgress,
    );
  }

  /// Helper getters for easy access to completion status
  bool get isWorkoutCompleted {
    return workoutProgress.when(
      data: (progress) {
        final total = workout.when(
          data: (workout) =>
              workout?.exercises.fold<int>(0, (acc, ex) => acc + ex.sets) ?? 0,
          loading: () => 0,
          error: (_, __) => 0,
        );
        if (total == 0) return false;
        final completed =
            progress.values.fold<int>(0, (acc, completed) => acc + completed);
        return completed == total;
      },
      loading: () => false,
      error: (_, __) => false,
    );
  }

  /// Check if all exercises are completed (similar to meal completion)
  bool get areAllExercisesCompleted {
    return exerciseProgress.when(
      data: (progress) {
        final total = workout.when(
          data: (workout) => workout?.exercises.length ?? 0,
          loading: () => 0,
          error: (_, __) => 0,
        );
        if (total == 0) return false;
        final completed =
            progress.values.where((isCompleted) => isCompleted).length;
        return completed == total;
      },
      loading: () => false,
      error: (_, __) => false,
    );
  }

  bool get isNutritionCompleted {
    return nutritionProgress.when(
      data: (progress) {
        final total = nutrition.when(
          data: (nutrition) => nutrition?.meals.length ?? 0,
          loading: () => 0,
          error: (_, __) => 0,
        );
        if (total == 0) return false;
        final completed =
            progress.values.where((isCompleted) => isCompleted).length;
        return completed == total;
      },
      loading: () => false,
      error: (_, __) => false,
    );
  }

  /// Get total workout progress
  Map<String, int> get workoutProgressCount {
    return workoutProgress.when(
      data: (progress) {
        final total = workout.when(
          data: (workout) =>
              workout?.exercises.fold<int>(0, (acc, ex) => acc + ex.sets) ?? 0,
          loading: () => 0,
          error: (_, __) => 0,
        );
        final completed =
            progress.values.fold<int>(0, (acc, completed) => acc + completed);
        return {'completed': completed, 'total': total};
      },
      loading: () => const {'completed': 0, 'total': 0},
      error: (_, __) => const {'completed': 0, 'total': 0},
    );
  }

  /// Get total nutrition progress
  Map<String, int> get nutritionProgressCount {
    return nutritionProgress.when(
      data: (progress) {
        final total = nutrition.when(
          data: (nutrition) => nutrition?.meals.length ?? 0,
          loading: () => 0,
          error: (_, __) => 0,
        );
        final completed =
            progress.values.where((isCompleted) => isCompleted).length;
        return {'completed': completed, 'total': total};
      },
      loading: () => const {'completed': 0, 'total': 0},
      error: (_, __) => const {'completed': 0, 'total': 0},
    );
  }

  /// Get total exercise progress
  Map<String, int> get exerciseProgressCount {
    return exerciseProgress.when(
      data: (progress) {
        final total = workout.when(
          data: (workout) => workout?.exercises.length ?? 0,
          loading: () => 0,
          error: (_, __) => 0,
        );
        final completed =
            progress.values.where((isCompleted) => isCompleted).length;
        return {'completed': completed, 'total': total};
      },
      loading: () => const {'completed': 0, 'total': 0},
      error: (_, __) => const {'completed': 0, 'total': 0},
    );
  }
}

// 2. REPLACE THE NOTIFIER WITH THIS ROBUST IMPLEMENTATION
@riverpod
class TodayPlanNotifier extends _$TodayPlanNotifier {
  bool _hasInitialized = false;

  @override
  TodayPlanState build() {
    // Only fetch data once on initialization
    if (!_hasInitialized) {
      _hasInitialized = true;
      _fetchAllData();
    }
    // Return a state that indicates we're fetching data but not in loading state
    return const TodayPlanState(
      entry: AsyncData(null),
      workout: AsyncData(null),
      nutrition: AsyncData(null),
      workoutProgress: AsyncData({}),
      nutritionProgress: AsyncData({}),
    );
  }

  // --- CORE DATA FETCHING LOGIC ---
  Future<void> _fetchAllData() async {
    // Don't reset state unnecessarily - just fetch data
    final api = ref.read(apiServiceProvider);
    final today = DateTime.now();
    print(
        '📅 [Today Plan] Fetching data for today: ${today.toString().split(' ')[0]}');

    try {
      // Step 1: Fetch the main calendar entry for today
      final calendarEntry = await api.getCalendarEntry(today);
      print(
          '📅 [Today Plan] Calendar entry result: ${calendarEntry != null ? "Found" : "Not found"}');
      state = state.copyWith(entry: AsyncData(calendarEntry));

      if (calendarEntry == null) {
        // If there's no plan for today, set everything to data(null) and stop.
        state = state.copyWith(
          workout: const AsyncData(null),
          nutrition: const AsyncData(null),
          workoutProgress: const AsyncData({}),
          nutritionProgress: const AsyncData({}),
        );
        return;
      }

      // Step 2: Fetch Workout and Nutrition data in parallel for speed
      Workout? workout;
      Nutrition? nutrition;
      Map<String, dynamic> progressData = {};

      // Fetch workout if available
      if (calendarEntry.workoutId.isNotEmpty &&
          calendarEntry.planId.isNotEmpty) {
        try {
          final workouts = await api.getWorkoutsForPlan(calendarEntry.planId);
          workout = workouts.firstWhere((w) => w.id == calendarEntry.workoutId);
        } catch (e) {
          // Handle workout fetch error
        }
      }

      // Fetch nutrition if available
      if (calendarEntry.nutritionIds.isNotEmpty) {
        try {
          nutrition =
              await api.getNutritionById(calendarEntry.nutritionIds.first);
        } catch (e) {
          // Handle nutrition fetch error
        }
      }

      // Fetch progress data
      try {
        final todayString = DateFormat('yyyy-MM-dd').format(today);
        progressData = await api.getWorkoutProgress(todayString);
      } catch (e) {
        // Handle progress fetch error
      }

      // Nutrition progress data is derived from the calendar entry, so no separate API call is needed.
      // The _parseNutritionProgressWithFallback method will handle this.
      final nutritionProgressData = <String, dynamic>{};

      // Step 3: Update state with all the fetched data
      state = state.copyWith(
        workout: AsyncData(workout),
        nutrition: AsyncData(nutrition),
        workoutProgress: AsyncData(_parseWorkoutProgress(progressData)),
        nutritionProgress: AsyncData(_parseNutritionProgressWithFallback(
            nutritionProgressData, nutrition, calendarEntry)),
        exerciseProgress:
            AsyncData(_parseExerciseProgress(workout, calendarEntry)),
      );
    } catch (e, stack) {
      // IMPORTANT: If anything fails, update the state with an error.
      state = state.copyWith(entry: AsyncError(e, stack));
    }
  }

  Map<int, int> _parseWorkoutProgress(Map<String, dynamic> progressData) {
    final workoutProgress = <int, int>{};
    if (progressData.containsKey('exercises')) {
      final exercises = progressData['exercises'] as List? ?? [];
      for (var exercise in exercises) {
        final index = exercise['index'] as int? ?? 0;
        final completedSets = exercise['completedSets'] as int? ?? 0;
        workoutProgress[index] = completedSets;
      }
    }
    return workoutProgress;
  }

  Map<String, bool> _parseNutritionProgressFromAPI(
      Map<String, dynamic> progressData, Nutrition? nutrition) {
    final nutritionProgress = <String, bool>{};

    if (nutrition != null) {
      // Initialize all meals as not completed
      for (final mealKey in nutrition.meals.keys) {
        nutritionProgress[mealKey] = false;
      }

      // Mark completed meals as true from API data
      if (progressData.containsKey('completedMeals')) {
        final completedMeals = progressData['completedMeals'] as List? ?? [];
        for (final completedMeal in completedMeals) {
          if (nutritionProgress.containsKey(completedMeal)) {
            nutritionProgress[completedMeal] = true;
          }
        }
      }
    }
    return nutritionProgress;
  }

  Map<String, bool> _parseNutritionProgressWithFallback(
      Map<String, dynamic> progressData,
      Nutrition? nutrition,
      CalendarEntry? entry) {
    // If we have API data, use it
    if (progressData.isNotEmpty && progressData.containsKey('completedMeals')) {
      return _parseNutritionProgressFromAPI(progressData, nutrition);
    }

    // Fallback to calendar entry method
    final nutritionProgress = <String, bool>{};

    if (nutrition != null && entry != null) {
      // Initialize all meals as not completed
      for (final mealKey in nutrition.meals.keys) {
        nutritionProgress[mealKey] = false;
      }

      // Mark completed meals as true from calendar entry
      for (final completedMeal in entry.completedMeals) {
        if (nutritionProgress.containsKey(completedMeal)) {
          nutritionProgress[completedMeal] = true;
        }
      }
    }
    return nutritionProgress;
  }

  Map<int, bool> _parseExerciseProgress(
      Workout? workout, CalendarEntry? entry) {
    final exerciseProgress = <int, bool>{};

    if (workout != null && entry != null) {
      // Initialize all exercises as not completed
      for (int i = 0; i < workout.exercises.length; i++) {
        exerciseProgress[i] = false;
      }

      // Mark completed exercises as true from calendar entry
      for (final completedExerciseIndex in entry.completedExercises) {
        if (exerciseProgress.containsKey(completedExerciseIndex)) {
          exerciseProgress[completedExerciseIndex] = true;
        }
      }
    }
    return exerciseProgress;
  }

  // Public method for manual refresh (e.g., pull-to-refresh)
  Future<void> refresh() async {
    await _fetchAllData();
  }

  // --- ACTION METHODS (to be called from UI) ---

  Future<void> completeTodayWorkout() async {
    final api = ref.read(apiServiceProvider);
    final todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await api.completeAllWorkout(todayString);

    // Optimistically update the workout progress to show all sets completed
    final workout = state.workout.value;
    if (workout != null) {
      final completedProgress = <int, int>{};
      for (int i = 0; i < workout.exercises.length; i++) {
        completedProgress[i] = workout.exercises[i].sets;
      }
      state = state.copyWith(workoutProgress: AsyncData(completedProgress));
    }

    // Force refresh calendar entries to get latest data
    ref.invalidate(calendarEntriesProvider);

    // Wait a moment for the invalidation to take effect
    await Future.delayed(const Duration(milliseconds: 500));

    // Also refresh weekly progress directly
    ref.read(weeklyProgressProvider.notifier).calculateWeeklyProgress();
  }

  Future<void> completeTodayNutrition() async {
    final api = ref.read(apiServiceProvider);
    final todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await api.completeAllNutrition(todayString);

    // Optimistically update the nutrition progress to show all meals completed
    final nutrition = state.nutrition.value;
    if (nutrition != null) {
      final completedProgress = <String, bool>{};
      for (final mealKey in nutrition.meals.keys) {
        completedProgress[mealKey] = true;
      }
      state = state.copyWith(nutritionProgress: AsyncData(completedProgress));
    }

    // Force refresh calendar entries to get latest data
    ref.invalidate(calendarEntriesProvider);

    // Wait a moment for the invalidation to take effect
    await Future.delayed(const Duration(milliseconds: 500));

    // Also refresh weekly progress directly
    ref.read(weeklyProgressProvider.notifier).calculateWeeklyProgress();
  }

  Future<void> completeAllExercises() async {
    final api = ref.read(apiServiceProvider);
    final todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await api.completeAllWorkout(todayString);

    // Optimistically update both exercise progress and set progress to show all completed
    final workout = state.workout.value;
    if (workout != null) {
      // Update exercise progress
      final completedExerciseProgress = <int, bool>{};
      for (int i = 0; i < workout.exercises.length; i++) {
        completedExerciseProgress[i] = true;
      }

      // Update set progress to maintain backward compatibility
      final completedSetProgress = <int, int>{};
      for (int i = 0; i < workout.exercises.length; i++) {
        completedSetProgress[i] = workout.exercises[i].sets;
      }

      state = state.copyWith(
        exerciseProgress: AsyncData(completedExerciseProgress),
        workoutProgress: AsyncData(completedSetProgress),
      );
    }

    // Force refresh calendar entries to get latest data
    ref.invalidate(calendarEntriesProvider);

    // Wait a moment for the invalidation to take effect
    await Future.delayed(const Duration(milliseconds: 500));

    // Also refresh weekly progress directly
    ref.read(weeklyProgressProvider.notifier).calculateWeeklyProgress();
  }

  Future<void> updateSetProgress(
      int exerciseIndex, int newCompletedSets) async {
    final api = ref.read(apiServiceProvider);
    final workoutId = state.workout.value?.id;
    if (workoutId == null) return;

    final today = DateTime.now();

    // Optimistic Update: Update the UI instantly
    final currentProgress =
        Map<int, int>.from(state.workoutProgress.value ?? {});
    currentProgress[exerciseIndex] = newCompletedSets;
    state = state.copyWith(workoutProgress: AsyncData(currentProgress));

    // Then, make the API call in the background
    await api.updateWorkoutSetProgress(
        workoutId, exerciseIndex, newCompletedSets, today);
    // Optional: You can re-fetch data here if you want to be extra sure it's in sync
    // await _fetchAllData();
  }

  Future<void> updateMealProgress(String mealKey, bool isCompleted) async {
    final api = ref.read(apiServiceProvider);
    final nutrition = state.nutrition.value;
    final entry = state.entry.value;
    if (nutrition == null || entry == null) return;

    // Optimistic Update: Update the UI instantly
    final currentProgress =
        Map<String, bool>.from(state.nutritionProgress.value ?? {});
    currentProgress[mealKey] = isCompleted;
    state = state.copyWith(nutritionProgress: AsyncData(currentProgress));

    // Make the API call to update the calendar entry with the new list of completed meals.
    try {
      final allCompletedMeals = currentProgress.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      // The 'completed' field is also required by the API when updating meals.
      // We can derive it or just pass the current value.
      final isDayCompleted = state.isNutritionCompleted;

      await api.updateCalendarEntry(entry.date,
          {'completedMeals': allCompletedMeals, 'completed': isDayCompleted});

      // Force refresh calendar entries to get latest data
      ref.invalidate(calendarEntriesProvider);

      // Wait a moment for the invalidation to take effect
      await Future.delayed(const Duration(milliseconds: 500));

      // Also refresh weekly progress directly
      ref.read(weeklyProgressProvider.notifier).calculateWeeklyProgress();
    } catch (e) {
      debugPrint("Failed to update meal progress: $e");
      // Revert optimistic update on error
      await _fetchAllData();
    }
  }

  Future<void> updateExerciseProgress(
      int exerciseIndex, bool isCompleted) async {
    final api = ref.read(apiServiceProvider);
    final workout = state.workout.value;
    final entry = state.entry.value;
    if (workout == null || entry == null) return;

    // Optimistic Update: Update the UI instantly
    final currentProgress =
        Map<int, bool>.from(state.exerciseProgress.value ?? {});
    currentProgress[exerciseIndex] = isCompleted;
    state = state.copyWith(exerciseProgress: AsyncData(currentProgress));

    // Make the API call to update the calendar entry with the new list of completed exercises.
    try {
      final allCompletedExercises = currentProgress.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      // The 'workoutCompleted' field is also required by the API when updating exercises.
      // We can derive it or just pass the current value.
      final isWorkoutCompleted = state.areAllExercisesCompleted;

      await api.updateCalendarEntry(entry.date, {
        'completedExercises': allCompletedExercises,
        'workoutCompleted': isWorkoutCompleted
      });

      // Force refresh calendar entries to get latest data
      ref.invalidate(calendarEntriesProvider);

      // Wait a moment for the invalidation to take effect
      await Future.delayed(const Duration(milliseconds: 500));

      // Also refresh weekly progress directly
      ref.read(weeklyProgressProvider.notifier).calculateWeeklyProgress();
    } catch (e) {
      debugPrint("Failed to update exercise progress: $e");
      // Revert optimistic update on error
      await _fetchAllData();
    }
  }

  Future<void> markWorkoutIncomplete() async {
    final api = ref.read(apiServiceProvider);
    final todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      // Call API to mark workout as incomplete
      await api.completeAllWorkout(
          todayString); // This should handle incomplete status

      // Force refresh calendar entries to get latest data
      ref.invalidate(calendarEntriesProvider);

      // Wait a moment for the invalidation to take effect
      await Future.delayed(const Duration(milliseconds: 500));

      // Also refresh weekly progress directly
      ref.read(weeklyProgressProvider.notifier).calculateWeeklyProgress();
    } catch (e) {
      // Handle error silently or rethrow if needed
      rethrow;
    }
  }

  Future<void> markNutritionIncomplete() async {
    final api = ref.read(apiServiceProvider);
    final todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      // Call API to mark nutrition as incomplete
      await api.completeAllNutrition(
          todayString); // This should handle incomplete status

      // Force refresh calendar entries to get latest data
      ref.invalidate(calendarEntriesProvider);

      // Wait a moment for the invalidation to take effect
      await Future.delayed(const Duration(milliseconds: 500));

      // Also refresh weekly progress directly
      ref.read(weeklyProgressProvider.notifier).calculateWeeklyProgress();
    } catch (e) {
      // Handle error silently or rethrow if needed
      rethrow;
    }
  }
}
