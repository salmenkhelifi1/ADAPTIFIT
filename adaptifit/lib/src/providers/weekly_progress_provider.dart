import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adaptifit/src/providers/calendar_provider.dart';
import 'package:adaptifit/src/providers/nutrition_provider.dart';
import 'package:adaptifit/src/providers/today_plan_provider.dart';

class WeeklyProgress {
  final int completedWorkouts;
  final int totalWorkouts;
  final int completedMeals;
  final int totalMeals;

  WeeklyProgress({
    required this.completedWorkouts,
    required this.totalWorkouts,
    required this.completedMeals,
    required this.totalMeals,
  });
}

class WeeklyProgressNotifier extends StateNotifier<AsyncValue<WeeklyProgress>> {
  WeeklyProgressNotifier(this.ref) : super(const AsyncValue.loading());

  final Ref ref;

  Future<void> calculateWeeklyProgress() async {
    try {
      state = const AsyncValue.loading();

      print('🔄 [Weekly Progress] Starting calculation...');

      // Get calendar entries
      final calendarEntries = await ref.read(calendarEntriesProvider.future);
      print(
          '📅 [Weekly Progress] Total calendar entries: ${calendarEntries.length}');

      // Calculate the start and end of the current week
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      print(
          '📅 [Weekly Progress] Week range: ${startOfWeek.toString().split(' ')[0]} to ${endOfWeek.toString().split(' ')[0]}');

      // Filter entries for the current week
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

      print(
          '📅 [Weekly Progress] Weekly entries found: ${weeklyEntries.length}');

      // Calculate workout progress with real data
      int completedWorkouts = 0;
      int totalWorkouts = 0;
      int completedMeals = 0;
      int totalMeals = 0;

      for (final entry in weeklyEntries) {
        print(
            '📅 [Weekly Progress] Processing entry for ${entry.date.toString().split(' ')[0]}');
        print('   - Workout ID: ${entry.workoutId}');
        print('   - Workout Completed: ${entry.workoutCompleted}');
        print('   - Nutrition IDs: ${entry.nutritionIds}');
        print('   - Completed Meals: ${entry.completedMeals}');
        print('   - Completed Nutrition IDs: ${entry.completedNutritionIds}');

        // Count workouts with real data
        if (entry.workoutId.isNotEmpty && entry.planId.isNotEmpty) {
          totalWorkouts++;
          print('   ✅ Added to total workouts');
          if (entry.workoutCompleted) {
            completedWorkouts++;
            print('   ✅ Added to completed workouts');
          }
        }

        // Count meals with real nutrition data
        if (entry.nutritionIds.isNotEmpty) {
          try {
            // Get actual nutrition data to count real meals
            for (final nutritionId in entry.nutritionIds) {
              final nutrition =
                  await ref.read(nutritionProvider(nutritionId).future);
              totalMeals +=
                  nutrition.meals.length; // Real meal count from nutrition plan
              print(
                  '   🍽️ Nutrition plan $nutritionId has ${nutrition.meals.length} meals');
            }
            completedMeals +=
                entry.completedMeals.length; // Real completed meals
            print('   🍽️ Completed meals: ${entry.completedMeals.length}');
          } catch (e) {
            // Fallback to estimated count if nutrition data is not available
            totalMeals += entry.nutritionIds.length * 3;
            completedMeals += entry.completedMeals.length;
            print(
                '   ⚠️ Fallback: ${entry.nutritionIds.length * 3} estimated meals');
          }
        }
      }

      print('📊 [Weekly Progress] Final counts:');
      print('   - Completed Workouts: $completedWorkouts');
      print('   - Total Workouts: $totalWorkouts');
      print('   - Completed Meals: $completedMeals');
      print('   - Total Meals: $totalMeals');

      // Compare with API data summary
      final apiCompletedWorkouts =
          calendarEntries.where((e) => e.workoutCompleted).length;
      final apiTotalWorkouts =
          calendarEntries.where((e) => e.workoutId.isNotEmpty).length;
      final apiCompletedMeals = calendarEntries.fold<int>(
          0, (sum, e) => sum + e.completedMeals.length);

      print('🔍 [Weekly Progress] Comparison with API data:');
      print(
          '   - API Completed Workouts: $apiCompletedWorkouts vs Weekly: $completedWorkouts');
      print(
          '   - API Total Workouts: $apiTotalWorkouts vs Weekly: $totalWorkouts');
      print(
          '   - API Completed Meals: $apiCompletedMeals vs Weekly: $completedMeals');

      final weeklyProgress = WeeklyProgress(
        completedWorkouts: completedWorkouts,
        totalWorkouts: totalWorkouts,
        completedMeals: completedMeals,
        totalMeals: totalMeals,
      );

      state = AsyncValue.data(weeklyProgress);
      print('✅ [Weekly Progress] Calculation completed successfully');
    } catch (e, stackTrace) {
      print('❌ [Weekly Progress] Error: $e');
      print('❌ [Weekly Progress] Stack trace: $stackTrace');
      state = AsyncValue.error(e, stackTrace);
    }
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
  print('🔄 [Weekly Progress Stream] Starting stream...');

  // Initial calculation
  final notifier = ref.read(weeklyProgressProvider.notifier);
  await notifier.calculateWeeklyProgress();

  // Yield the current state
  final currentState = ref.read(weeklyProgressProvider);
  if (currentState.hasValue) {
    yield currentState.value!;
  }

  // Listen for changes and yield updates more frequently
  await for (final _ in Stream.periodic(const Duration(seconds: 2))) {
    print('🔄 [Weekly Progress Stream] Periodic update...');
    await notifier.calculateWeeklyProgress();
    final newState = ref.read(weeklyProgressProvider);
    if (newState.hasValue) {
      yield newState.value!;
    }
  }
});
