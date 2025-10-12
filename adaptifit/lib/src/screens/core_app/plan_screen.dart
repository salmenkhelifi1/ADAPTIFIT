import 'package:adaptifit/src/providers/calendar_provider.dart';
import 'package:adaptifit/src/providers/plan_provider.dart';
import 'package:adaptifit/src/providers/nutrition_provider.dart';
import 'package:adaptifit/src/providers/today_plan_provider.dart';
import 'package:adaptifit/src/providers/weekly_progress_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:adaptifit/src/constants/app_colors.dart';
import 'package:adaptifit/src/models/calendar_entry.dart';
import 'package:adaptifit/src/models/nutrition.dart';

import 'package:adaptifit/src/models/workout.dart';

import 'package:adaptifit/src/screens/core_app/calendar_screen.dart';
import 'package:adaptifit/src/screens/core_app/daily_plan_detail_screen.dart';
import 'package:adaptifit/src/screens/core_app/workout_detail_screen.dart';
import 'package:adaptifit/src/screens/core_app/nutrition_plan_screen.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  Future<void> _completeWorkout(
      BuildContext context, WidgetRef ref, DateTime date) async {
    try {
      await ref.read(todayPlanNotifierProvider.notifier).completeTodayWorkout();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout marked as complete!')),
        );
      }
    } catch (e) {
      debugPrint("Error completing workout: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to complete workout.')),
        );
      }
    }
  }

  Future<void> _completeNutrition(
      BuildContext context, WidgetRef ref, DateTime date) async {
    try {
      await ref
          .read(todayPlanNotifierProvider.notifier)
          .completeTodayNutrition();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nutrition marked as complete!')),
        );
      }
    } catch (e) {
      debugPrint("Error completing nutrition: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to complete nutrition.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildSectionHeader(
                  title: "Today's Plan",
                  actionText: "Plan Overview >",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DailyPlanDetailScreen(date: DateTime.now()),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              _buildTodaysPlan(context, ref),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildSectionHeader(title: "Weekly Progress"),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildWeeklyProgress(ref),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildSectionHeader(title: "Upcoming Plans"),
              ),
              const SizedBox(height: 10),
              _buildUpcomingPlansList(context, ref),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysPlan(BuildContext context, WidgetRef ref) {
    final todayPlanState = ref.watch(todayPlanNotifierProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: todayPlanState.entry.when(
        data: (calendarDay) {
          if (calendarDay == null) {
            return _buildNoPlanCard(title: "Rest Day");
          }
          return Column(
            children: [
              if (calendarDay.workoutId.isNotEmpty &&
                  calendarDay.planId.isNotEmpty)
                todayPlanState.workout.when(
                  data: (workout) {
                    if (workout == null) {
                      return const Center(
                          child:
                              Text("Today's workout not found in the plan."));
                    }
                    return _buildWorkoutCard(
                        context, workout, calendarDay, ref);
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) =>
                      const Center(child: Text("Workout not found")),
                )
              else
                _buildNoPlanCard(
                    title: "Rest Day", message: "Enjoy your day off!"),
              if (calendarDay.nutritionIds.isNotEmpty &&
                  calendarDay.planId.isNotEmpty) ...[
                const SizedBox(height: 16),
                todayPlanState.nutrition.when(
                  data: (nutrition) {
                    if (nutrition == null) {
                      return const Center(
                          child: Text("Nutrition plan not found"));
                    }
                    return _buildNutritionCard(
                        context, nutrition, calendarDay, ref);
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) =>
                      const Center(child: Text("Nutrition plan not found")),
                ),
              ]
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => _buildNoPlanCard(
            title: "Error", message: "Could not load today's plan."),
      ),
    );
  }

  Widget _buildWeeklyProgress(WidgetRef ref) {
    final weeklyProgressState = ref.watch(weeklyProgressStreamProvider);

    return weeklyProgressState.when(
      data: (weeklyProgress) {
        return _buildWeeklyProgressCard(
          weeklyProgress.completedWorkouts,
          weeklyProgress.totalWorkouts,
          weeklyProgress.completedMealDays,
          weeklyProgress.totalMealDays,
        );
      },
      loading: () => _buildWeeklyProgressCard(0, 0, 0, 0),
      error: (error, stackTrace) {
        // Fallback to regular provider if stream fails
        final fallbackState = ref.watch(weeklyProgressProvider);
        return fallbackState.when(
          data: (weeklyProgress) {
            return _buildWeeklyProgressCard(
              weeklyProgress.completedWorkouts,
              weeklyProgress.totalWorkouts,
              weeklyProgress.completedMealDays,
              weeklyProgress.totalMealDays,
            );
          },
          loading: () => _buildWeeklyProgressCard(0, 0, 0, 0),
          error: (error, stackTrace) => _buildWeeklyProgressCard(0, 0, 0, 0),
        );
      },
    );
  }

  Widget _buildUpcomingPlansList(BuildContext context, WidgetRef ref) {
    final calendarEntriesValue = ref.watch(calendarEntriesProvider);
    return calendarEntriesValue.when(
      data: (calendarEntries) {
        // Filter to get only today and future entries
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final upcomingEntries = calendarEntries.where((entry) {
          final entryDate =
              DateTime(entry.date.year, entry.date.month, entry.date.day);
          return entryDate.isAtSameMomentAs(today) || entryDate.isAfter(today);
        }).toList();

        if (upcomingEntries.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: _buildStyledContainer(
                child: const Text('No upcoming plans found.')),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            children: upcomingEntries
                .map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildUpcomingPlanCard(entry: entry),
                    ))
                .toList(),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: _buildStyledContainer(child: Text('Error: $e')),
      ),
    );
  }

  // ... (rest of the helper methods are the same as before)

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('My Plan',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(DateFormat('EEEE, MMMM d').format(DateTime.now()),
                  style: const TextStyle(fontSize: 16, color: Colors.black54)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      {required String title, String? actionText, VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        if (actionText != null)
          GestureDetector(
            onTap: onTap,
            child: Text(actionText,
                style: TextStyle(
                    color: Colors.green[600],
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
          ),
      ],
    );
  }

  Widget _buildStyledContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildWorkoutCard(BuildContext context, Workout workout,
      CalendarEntry calendar, WidgetRef ref) {
    final todayPlanState = ref.watch(todayPlanNotifierProvider);
    final setProgressCounts = todayPlanState.workoutProgressCount;
    final totalSetSlots = setProgressCounts['total']!;
    final totalCompletedSlots = setProgressCounts['completed']!;
    final bool isWorkoutCompleted = todayPlanState.isWorkoutCompleted;

    const primaryGreen = Color(0xFF1EB955);

    return _buildStyledContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.fitness_center,
                      color: primaryGreen, size: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(workout.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 16, color: Colors.black54),
                        const SizedBox(width: 4),
                        Text(workout.duration,
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
              value: totalSetSlots == 0
                  ? 0.0
                  : totalCompletedSlots / totalSetSlots,
              minHeight: 8,
              backgroundColor: AppColors.lightGrey2,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          WorkoutDetailScreen(workout: workout)),
                );
              },
              child: const Text('View Details >',
                  style: TextStyle(
                      color: primaryGreen, fontWeight: FontWeight.w600))),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: isWorkoutCompleted
                  ? null
                  : () => _completeWorkout(context, ref, calendar.date),
              style: ElevatedButton.styleFrom(
                  backgroundColor: isWorkoutCompleted
                      ? const Color(0xFFE0E0E0)
                      : primaryGreen,
                  disabledBackgroundColor: const Color(0xFFE0E0E0),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      isWorkoutCompleted
                          ? 'Workout Completed'
                          : totalCompletedSlots > 0
                              ? '${totalCompletedSlots}/${totalSetSlots} sets done'
                              : 'Complete Workout',
                      style: TextStyle(
                          color: isWorkoutCompleted
                              ? Colors.black54
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  if (isWorkoutCompleted) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.check, color: Colors.black54, size: 20),
                  ]
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(BuildContext context, Nutrition nutrition,
      CalendarEntry calendar, WidgetRef ref) {
    final todayPlanState = ref.watch(todayPlanNotifierProvider);
    final progressCounts = todayPlanState.nutritionProgressCount;
    final totalMeals = progressCounts['total']!;
    final totalCompletedMeals = progressCounts['completed']!;
    final bool isNutritionCompleted = todayPlanState.isNutritionCompleted;

    const primaryBlue = Color(0xFF3A7DFF);
    const primaryGreen = Color(0xFF1EB955);

    return _buildStyledContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.apple, color: primaryBlue, size: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nutrition.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    const Text('Balanced nutrition plan',
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Progress',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Text('${totalCompletedMeals}/${totalMeals} meals',
                  style: const TextStyle(color: AppColors.subtitleGray)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: totalMeals == 0 ? 0.0 : totalCompletedMeals / totalMeals,
              minHeight: 8,
              backgroundColor: AppColors.lightGrey2,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          NutritionPlanScreen(nutrition: nutrition)),
                );
              },
              child: const Text('View Details >',
                  style: TextStyle(
                      color: primaryGreen, fontWeight: FontWeight.w600))),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: isNutritionCompleted
                  ? null
                  : () => _completeNutrition(context, ref, calendar.date),
              style: ElevatedButton.styleFrom(
                  backgroundColor: isNutritionCompleted
                      ? const Color(0xFFE0E0E0)
                      : primaryGreen,
                  disabledBackgroundColor: const Color(0xFFE0E0E0),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      isNutritionCompleted
                          ? 'Nutrition Completed'
                          : totalCompletedMeals > 0
                              ? '${totalCompletedMeals}/${totalMeals} meals done'
                              : 'Complete Nutrition',
                      style: TextStyle(
                          color: isNutritionCompleted
                              ? Colors.black54
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  if (isNutritionCompleted) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.check, color: Colors.black54, size: 20),
                  ]
                ],
              )),
        ],
      ),
    );
  }

  /// Builds the weekly progress card showing workouts and meals progress
  /// Data is dynamically fetched from the database and updates in real-time
  Widget _buildWeeklyProgressCard(int completedWorkouts, int totalWorkouts,
      int completedMealDays, int totalMealDays) {
    return _buildStyledContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.trending_up, color: AppColors.darkText),
            SizedBox(width: 8),
            Text('Weekly Progress',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
          ]),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Workouts section - completed only when all sets are 100% finished
              _buildProgressItem(
                  value: completedWorkouts,
                  total: totalWorkouts,
                  label: 'Workouts',
                  color: AppColors.primaryGreen,
                  progressTextColor: AppColors.primaryGreen),
              // Meals section - completed only when all meals for the day are finished
              _buildProgressItem(
                  value: completedMealDays,
                  total: totalMealDays,
                  label: 'Meals',
                  color: AppColors.secondaryBlue,
                  progressTextColor: AppColors.secondaryBlue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(
      {required int value,
      required int total,
      required String label,
      required Color color,
      // 1. Add the new color parameter here
      required Color progressTextColor}) {
    return Column(
      children: [
        Text('$value/$total',
            // 2. Use the parameter to set the text color
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: progressTextColor)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.subtitleGray)),
        const SizedBox(height: 8),
        SizedBox(
          width: 120,
          child: LinearProgressIndicator(
              value: total == 0 ? 0 : value / total,
              backgroundColor: AppColors.lightGrey2,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3)),
        ),
      ],
    );
  }

  Widget _buildUpcomingPlanCard({CalendarEntry? entry}) {
    if (entry == null) {
      return _buildStyledContainer(
        child: const Text('No plan data available'),
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        return _buildStyledContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day of week and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getDayOfWeek(entry.date),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  Text(
                    DateFormat('EEE, MMM d').format(entry.date),
                    style: const TextStyle(
                      color: AppColors.subtitleGray,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Workout information
              if (entry.workoutId.isNotEmpty) ...[
                ref.watch(planWorkoutsProvider(entry.planId)).when(
                      data: (workouts) {
                        if (workouts.isEmpty) return const SizedBox.shrink();
                        final workout = workouts.firstWhere(
                          (w) => w.id == entry.workoutId,
                          orElse: () => workouts.first,
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.fitness_center,
                                    color: AppColors.primaryGreen, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    workout.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.darkText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (e, s) => const SizedBox.shrink(),
                    ),
              ],

              // Nutrition information with detailed meals
              if (entry.nutritionIds.isNotEmpty) ...[
                ref.watch(nutritionProvider(entry.nutritionIds.first)).when(
                      data: (nutrition) {
                        // Extract breakfast and dinner meals
                        final breakfast = nutrition.meals['breakfast'];
                        final dinner = nutrition.meals['dinner'];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.apple,
                                    color: AppColors.secondaryBlue, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${nutrition.meals.length} meals planned',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.subtitleGray,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Detailed meal information
                            if (breakfast != null) ...[
                              Text(
                                'Breakfast: ${breakfast.name}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.darkText,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                            if (dinner != null) ...[
                              Text(
                                'Dinner: ${dinner.name}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.darkText,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                          ],
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (e, s) => const SizedBox.shrink(),
                    ),
              ],

              // View Details button
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DailyPlanDetailScreen(date: entry.date),
                      ),
                    );
                  },
                  child: const Text(
                    'View Details >',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getDayOfWeek(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(date.year, date.month, date.day);

    if (entryDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (entryDate.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      return 'Tomorrow';
    } else {
      return DateFormat('EEEE').format(date);
    }
  }

  Widget _buildNoPlanCard(
      {String title = "No plan for today",
      String message = "Enjoy your day off!"}) {
    return _buildStyledContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87)),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 16)),
          const SizedBox(height: 16),
          const Icon(Icons.celebration_outlined, size: 40, color: Colors.grey),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
