import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';
import 'package:adaptifit/src/models/calendar_entry.dart';
import 'package:adaptifit/src/models/workout.dart';
import 'package:adaptifit/src/models/nutrition.dart';
import 'package:adaptifit/src/providers/api_service_provider.dart';

part 'today_plan_provider.g.dart';

// 1. DEFINE THE STATE CLASS (this should already exist)
class TodayPlanState {
  final AsyncValue<CalendarEntry?> entry;
  final AsyncValue<Workout?> workout;
  final AsyncValue<Nutrition?> nutrition;
  final AsyncValue<Map<int, int>> workoutProgress;
  final AsyncValue<Map<String, bool>> nutritionProgress;

  const TodayPlanState({
    this.entry = const AsyncLoading(),
    this.workout = const AsyncLoading(),
    this.nutrition = const AsyncLoading(),
    this.workoutProgress = const AsyncLoading(),
    this.nutritionProgress = const AsyncLoading(),
  });

  TodayPlanState copyWith({
    AsyncValue<CalendarEntry?>? entry,
    AsyncValue<Workout?>? workout,
    AsyncValue<Nutrition?>? nutrition,
    AsyncValue<Map<int, int>>? workoutProgress,
    AsyncValue<Map<String, bool>>? nutritionProgress,
  }) {
    return TodayPlanState(
      entry: entry ?? this.entry,
      workout: workout ?? this.workout,
      nutrition: nutrition ?? this.nutrition,
      workoutProgress: workoutProgress ?? this.workoutProgress,
      nutritionProgress: nutritionProgress ?? this.nutritionProgress,
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

    try {
      // Step 1: Fetch the main calendar entry for today
      final calendarEntry = await api.getCalendarEntry(today);
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

      // Fetch nutrition progress data
      Map<String, dynamic> nutritionProgressData = {};
      try {
        final todayString = DateFormat('yyyy-MM-dd').format(today);
        nutritionProgressData = await api.getNutritionProgress(todayString);
      } catch (e) {
        // Handle nutrition progress fetch error - use fallback
        debugPrint("Nutrition progress API failed, using fallback: $e");
        nutritionProgressData = {};
      }

      // Step 3: Update state with all the fetched data
      state = state.copyWith(
        workout: AsyncData(workout),
        nutrition: AsyncData(nutrition),
        workoutProgress: AsyncData(_parseWorkoutProgress(progressData)),
        nutritionProgress: AsyncData(_parseNutritionProgressWithFallback(
            nutritionProgressData, nutrition, calendarEntry)),
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

    final today = DateTime.now();

    // Optimistic Update: Update the UI instantly
    final currentProgress =
        Map<String, bool>.from(state.nutritionProgress.value ?? {});
    currentProgress[mealKey] = isCompleted;
    state = state.copyWith(nutritionProgress: AsyncData(currentProgress));

    // Then, make the API call in the background
    try {
      await api.updateNutritionMealProgress(
          nutrition.id, mealKey, isCompleted, today);
    } catch (e) {
      // Fallback to calendar entry update if nutrition progress API fails
      debugPrint("Nutrition progress API failed, using fallback: $e");
      try {
        final allCompletedMeals = currentProgress.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();
        await api.updateCalendarEntry(
            entry.date, {'completedMeals': allCompletedMeals});
      } catch (fallbackError) {
        debugPrint("Fallback also failed: $fallbackError");
        // Revert optimistic update on error
        await _fetchAllData();
      }
    }
  }
}
