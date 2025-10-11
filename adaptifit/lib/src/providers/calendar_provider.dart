import 'package:adaptifit/src/models/calendar_entry.dart';
import 'package:adaptifit/src/providers/api_service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calendar_provider.g.dart';

@Riverpod(keepAlive: true)
Future<List<CalendarEntry>> calendarEntries(CalendarEntriesRef ref) async {
  print('📅 [Calendar Provider] Fetching calendar entries...');
  final apiService = ref.watch(apiServiceProvider);
  final entries = await apiService.getCalendarEntries();
  print('📅 [Calendar Provider] Fetched ${entries.length} calendar entries');

  // Log each entry for debugging
  for (final entry in entries) {
    print(
        '📅 [Calendar Provider] Entry for ${entry.date.toString().split(' ')[0]}:');
    print('   - Workout ID: ${entry.workoutId}');
    print('   - Workout Completed: ${entry.workoutCompleted}');
    print('   - Nutrition IDs: ${entry.nutritionIds}');
    print('   - Completed Meals: ${entry.completedMeals}');
    print('   - Completed: ${entry.completed}');
    print('   - Completed Nutrition IDs: ${entry.completedNutritionIds}');
  }

  // Log summary of completion status from API
  final completedWorkouts = entries.where((e) => e.workoutCompleted).length;
  final totalWorkouts = entries.where((e) => e.workoutId.isNotEmpty).length;
  final totalCompletedMeals =
      entries.fold<int>(0, (sum, e) => sum + e.completedMeals.length);
  final totalMeals = entries.fold<int>(
      0,
      (sum, e) =>
          sum + e.nutritionIds.length * 4); // Assume 4 meals per nutrition plan

  print('📊 [Calendar Provider] API Data Summary:');
  print('   - Completed Workouts: $completedWorkouts');
  print('   - Total Workouts: $totalWorkouts');
  print('   - Completed Meals: $totalCompletedMeals');
  print('   - Estimated Total Meals: $totalMeals');

  return entries;
}

@Riverpod(keepAlive: true)
Future<CalendarEntry?> todayCalendarEntry(TodayCalendarEntryRef ref) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getCalendarEntry(DateTime.now());
}

@riverpod
Future<CalendarEntry?> calendarEntry(CalendarEntryRef ref, DateTime date) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getCalendarEntry(date);
}
