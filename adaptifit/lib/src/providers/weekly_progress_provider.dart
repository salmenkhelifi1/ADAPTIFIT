import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adaptifit/src/providers/calendar_provider.dart';
import 'package:adaptifit/src/providers/today_plan_provider.dart';
import 'package:adaptifit/src/providers/api_service_provider.dart';
import 'package:adaptifit/src/providers/plan_provider.dart';
import 'package:intl/intl.dart';

/// Weekly progress data structure that tracks workouts and meals for the current week
/// This provides dynamic data from the database showing real progress
class WeeklyProgress {
  final int
      completedWorkouts; // Number of completed workouts in the week (all sets finished)
  final int totalWorkouts; // Total number of workouts planned in the week
  final int completedMealDays; // Number of days where all meals are completed
  final int totalMealDays; // Total number of days with meals planned

  WeeklyProgress({
    required this.completedWorkouts,
    required this.totalWorkouts,
    required this.completedMealDays,
    required this.totalMealDays,
  });
}

class WeeklyProgressNotifier extends StateNotifier<AsyncValue<WeeklyProgress>> {
  WeeklyProgressNotifier(this.ref) : super(const AsyncValue.loading());

  final Ref ref;

  Future<void> calculateWeeklyProgress() async {
    try {
      state = const AsyncValue.loading();

      print('🔄 [Weekly Progress] Starting calculation...');

      // Calculate the start of the current week
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startDateString = DateFormat('yyyy-MM-dd').format(startOfWeek);

      print('📅 [Weekly Progress] Week start date: $startDateString');

      final api = ref.read(apiServiceProvider);

      // Get weekly workout progress from the dedicated API endpoint
      Map<String, dynamic> weeklyWorkoutData = {};
      try {
        weeklyWorkoutData = await api.getWeeklyProgress(startDateString);
        print('🏋️ [Weekly Progress] Got workout data from API');
      } catch (e) {
        print('⚠️ [Weekly Progress] Could not get weekly workout data: $e');
      }

      // Get calendar entries for meal data (since there's no weekly nutrition endpoint)
      final calendarEntries = await ref.read(calendarEntriesProvider.future);
      print(
          '📅 [Weekly Progress] Total calendar entries: ${calendarEntries.length}');

      // Calculate workout progress from API data
      int completedWorkouts = 0;
      int totalWorkouts = 0;

      if (weeklyWorkoutData.containsKey('weekData')) {
        final weekData = weeklyWorkoutData['weekData'] as List? ?? [];
        for (var dayData in weekData) {
          final hasWorkout = dayData['hasWorkout'] as bool? ?? false;
          final totalCompletedSets = dayData['totalCompletedSets'] as int? ?? 0;
          final totalPlannedSets = dayData['totalPlannedSets'] as int? ?? 0;

          if (hasWorkout && totalPlannedSets > 0) {
            totalWorkouts++;
            // Workout is completed only when ALL sets are finished
            if (totalCompletedSets == totalPlannedSets) {
              completedWorkouts++;
              print(
                  '   🏋️ ${dayData['date']}: COMPLETED ($totalCompletedSets/$totalPlannedSets sets)');
            } else {
              print(
                  '   🏋️ ${dayData['date']}: INCOMPLETE ($totalCompletedSets/$totalPlannedSets sets)');
            }
          }
        }
      }

      // Calculate meal progress from calendar entries
      int completedMealDays = 0;
      int totalMealDays = 0;

      // Filter entries for the current week
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      final weeklyEntries = calendarEntries.where((entry) {
        final entryDate =
            DateTime(entry.date.year, entry.date.month, entry.date.day);
        final startDate =
            DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        final endDate =
            DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day);

        return entryDate.isAtSameMomentAs(startDate) ||
            entryDate.isAtSameMomentAs(endDate) ||
            (entryDate.isAfter(startDate) && entryDate.isBefore(endDate));
      }).toList();

      for (final entry in weeklyEntries) {
        if (entry.nutritionIds.isNotEmpty) {
          totalMealDays++;

          // Check if all meals for the day are completed
          // We need to get the nutrition plan to see how many meals it has
          bool areAllMealsCompleted = false;
          
          try {
            // Get the nutrition plan to count total meals
            final nutrition = await ref.read(planNutritionProvider(entry.planId).future);
            
            if (nutrition != null) {
              // Count total meals in the nutrition plan
              int totalMeals = nutrition.meals.length;
              int completedMeals = entry.completedMeals.length;
              
              // All meals are completed only when ALL meals for the day are done
              areAllMealsCompleted = totalMeals > 0 && completedMeals == totalMeals;
            } else {
              // If we can't find the nutrition plan, use fallback
              areAllMealsCompleted = entry.nutritionIds.every((id) => 
                  entry.completedNutritionIds.contains(id));
            }
            
            if (nutrition != null) {
              print('   🍽️ ${entry.date.toString().split(' ')[0]}: ${entry.completedMeals.length}/${nutrition.meals.length} meals - ${areAllMealsCompleted ? "ALL COMPLETED" : "INCOMPLETE"}');
            } else {
              print('   🍽️ ${entry.date.toString().split(' ')[0]}: Using fallback - ${areAllMealsCompleted ? "COMPLETED" : "INCOMPLETE"}');
            }
          } catch (e) {
            print('   ⚠️ Could not get nutrition plan data: $e');
            // Fallback: check if all nutrition IDs are completed
            areAllMealsCompleted = entry.nutritionIds.every((id) => 
                entry.completedNutritionIds.contains(id));
            print('   🍽️ ${entry.date.toString().split(' ')[0]}: Using fallback - ${areAllMealsCompleted ? "COMPLETED" : "INCOMPLETE"}');
          }

          if (areAllMealsCompleted) {
            completedMealDays++;
            print('   ✅ Added to completed meal days');
          }
        }
      }

      print('📊 [Weekly Progress] Final counts:');
      print('   - Completed Workouts: $completedWorkouts');
      print('   - Total Workouts: $totalWorkouts');
      print('   - Completed Meal Days: $completedMealDays');
      print('   - Total Meal Days: $totalMealDays');

      final weeklyProgress = WeeklyProgress(
        completedWorkouts: completedWorkouts,
        totalWorkouts: totalWorkouts,
        completedMealDays: completedMealDays,
        totalMealDays: totalMealDays,
      );

      state = AsyncValue.data(weeklyProgress);
      print('✅ [Weekly Progress] Calculation completed successfully');
    } catch (e, stackTrace) {
      print('❌ [Weekly Progress] Error: $e');
      print('❌ [Weekly Progress] Stack trace: $stackTrace');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Public method for manual refresh
  Future<void> refresh() async {
    await calculateWeeklyProgress();
  }
}

// Create a provider that automatically refreshes when any relevant data changes
final weeklyProgressProvider =
    StateNotifierProvider<WeeklyProgressNotifier, AsyncValue<WeeklyProgress>>(
        (ref) {
  final notifier = WeeklyProgressNotifier(ref);

  // Calculate progress when the provider is first created
  notifier.calculateWeeklyProgress();

  // Listen to calendar entries changes and refresh weekly progress
  ref.listen(calendarEntriesProvider, (previous, next) {
    if (next.hasValue) {
      print('🔄 [Weekly Progress] Calendar entries changed, refreshing...');
      notifier.calculateWeeklyProgress();
    }
  });

  // Also listen to today's plan changes for real-time updates
  ref.listen(todayPlanNotifierProvider, (previous, next) {
    print('🔄 [Weekly Progress] Today plan changed, refreshing...');
    notifier.calculateWeeklyProgress();
  });

  return notifier;
});

// Create a stream provider for real-time updates
final weeklyProgressStreamProvider =
    StreamProvider<WeeklyProgress>((ref) async* {
  // Initial calculation
  final notifier = ref.read(weeklyProgressProvider.notifier);
  await notifier.calculateWeeklyProgress();

  // Yield the current state
  final currentState = ref.read(weeklyProgressProvider);
  if (currentState.hasValue) {
    yield currentState.value!;
  }

  // Create a stream that emits whenever the weekly progress changes
  // This will be triggered by the listeners in the weeklyProgressProvider
  final controller = StreamController<WeeklyProgress>();

  // Listen to the weekly progress provider state changes
  ref.listen(weeklyProgressProvider, (previous, next) {
    if (next.hasValue && !controller.isClosed) {
      controller.add(next.value!);
    }
  });

  // Yield from the controller stream
  await for (final progress in controller.stream) {
    yield progress;
  }
});
