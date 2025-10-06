import 'package:adaptifit/src/providers/calendar_provider.dart';
import 'package:adaptifit/src/providers/api_service_provider.dart';
import 'package:adaptifit/src/providers/plan_provider.dart';
import 'package:adaptifit/src/providers/progress_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:adaptifit/src/constants/app_colors.dart';
import 'package:adaptifit/src/models/calendar_entry.dart';
import 'package:adaptifit/src/models/nutrition.dart';

import 'package:adaptifit/src/models/workout.dart';

import 'package:adaptifit/src/screens/core_app/calendar_screen.dart';
import 'package:adaptifit/src/screens/core_app/daily_plan_detail_screen.dart';
import 'package:adaptifit/src/screens/core_app/plan_details_screen.dart';
import 'package:adaptifit/src/screens/core_app/workout_overview_screen.dart';
import 'package:adaptifit/src/screens/core_app/workout_detail_screen.dart';
import 'package:adaptifit/src/screens/core_app/nutrition_plan_screen.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  Future<void> _completeWorkout(BuildContext context, WidgetRef ref,
      DateTime date) async {
    try {
      final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      await ref.read(apiServiceProvider).completeAllWorkout(dateString);
      ref.refresh(todayCalendarEntryProvider);
    } catch (e) {
      debugPrint("Error completing workout: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to complete workout.')),
        );
      }
    }
  }

  Future<void> _completeNutrition(BuildContext context, WidgetRef ref,
      DateTime date) async {
    try {
      final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      await ref.read(apiServiceProvider).completeAllNutrition(dateString);
      ref.refresh(todayCalendarEntryProvider);
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
                child: _buildWeeklyProgress(),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildSectionHeader(title: "Your Workout Library"),
              ),
              const SizedBox(height: 10),
              _buildWorkoutLibraryList(context, ref),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysPlan(BuildContext context, WidgetRef ref) {
    final calendarEntryValue = ref.watch(todayCalendarEntryProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: calendarEntryValue.when(
        data: (calendarDay) {
          if (calendarDay == null) {
            return _buildNoPlanCard(title: "Rest Day");
          }
          return Column(
            children: [
              if (calendarDay.workoutId.isNotEmpty &&
                  calendarDay.planId.isNotEmpty)
                ref.watch(workoutsForPlanProvider(calendarDay.planId)).when(
                      data: (workouts) {
                        Workout? workout;
                        for (final w in workouts) {
                          if (w.id == calendarDay.workoutId) {
                            workout = w;
                            break;
                          }
                        }
                        if (workout == null) {
                          return const Center(
                              child: Text(
                                  "Today's workout not found in the plan."));
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
                ref.watch(planNutritionProvider(calendarDay.planId)).when(
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

  Widget _buildWeeklyProgress() {
    // Placeholder data as API endpoint is not available
    return _buildWeeklyProgressCard(3, 5, 12, 21);
  }

  Widget _buildWorkoutLibraryList(BuildContext context, WidgetRef ref) {
    final plansValue = ref.watch(myPlansProvider);
    return plansValue.when(
      data: (plans) {
        if (plans.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: _buildStyledContainer(child: const Text('No plans found.')),
          );
        }
        final firstPlan = plans.first;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: _buildUpcomingPlanCard(
            dayOfWeek: firstPlan.planName,
            date: '${firstPlan.duration} days - ${firstPlan.difficulty}',
            workoutName: firstPlan.planName,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Consumer(builder: (context, ref, _) {
                      final workoutsAsync =
                          ref.watch(workoutsForPlanProvider(firstPlan.id));
                      return workoutsAsync.when(
                        data: (workouts) {
                          if (workouts.isEmpty) {
                            return Scaffold(
                              backgroundColor: AppColors.screenBackground,
                              appBar: AppBar(
                                backgroundColor: AppColors.screenBackground,
                                elevation: 0,
                              ),
                              body: const Center(
                                  child:
                                      Text('No workouts found in this plan.')),
                            );
                          }
                          return WorkoutOverviewScreen(workout: workouts.first);
                        },
                        loading: () => const Scaffold(
                          backgroundColor: AppColors.screenBackground,
                          body: Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, s) => Scaffold(
                          backgroundColor: AppColors.screenBackground,
                          appBar: AppBar(
                            backgroundColor: AppColors.screenBackground,
                            elevation: 0,
                          ),
                          body: Center(child: Text('Error: $e')),
                        ),
                      );
                    });
                  },
                ),
              );
            },
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

  Widget _buildStyledContainer(
      {required Widget child, bool isCentered = false}) {
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
    final workoutProgress = ref.watch(workoutProgressProvider);
    final totalSetSlots = workout.exercises.fold<int>(0, (acc, ex) => acc + (ex.sets));
    final totalCompletedSlots = workoutProgress.fold<int>(0, (a, b) => a + b);
    final bool isCompleted = totalCompletedSlots > 0 && totalCompletedSlots == totalSetSlots;

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
              const Text('Progress', style: TextStyle(fontWeight: FontWeight.w600)),
              Text('${totalCompletedSlots}/${totalSetSlots} sets', style: const TextStyle(color: AppColors.subtitleGray)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: totalSetSlots == 0 ? 0.0 : totalCompletedSlots / totalSetSlots,
              minHeight: 8,
              backgroundColor: AppColors.lightGrey2,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
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
              onPressed: isCompleted
                  ? null
                  : () => _completeWorkout(
                      context, ref, calendar.date),
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isCompleted ? const Color(0xFFE0E0E0) : primaryGreen,
                  disabledBackgroundColor: const Color(0xFFE0E0E0),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Workout Completed',
                      style: TextStyle(
                          color: isCompleted ? Colors.black54 : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  if (isCompleted) ...[
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
    final nutritionProgress = ref.watch(nutritionProgressProvider);
    final totalMeals = nutrition.meals.length;
    final totalCompletedMeals = nutritionProgress.values.where((isCompleted) => isCompleted).length;
    final bool isCompleted = totalCompletedMeals > 0 && totalCompletedMeals == totalMeals;

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
              const Text('Progress', style: TextStyle(fontWeight: FontWeight.w600)),
              Text('${totalCompletedMeals}/${totalMeals} meals', style: const TextStyle(color: AppColors.subtitleGray)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: totalMeals == 0 ? 0.0 : totalCompletedMeals / totalMeals,
              minHeight: 8,
              backgroundColor: AppColors.lightGrey2,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
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
              onPressed: isCompleted
                  ? null
                  : () => _completeNutrition(
                      context, ref, calendar.date),
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isCompleted ? const Color(0xFFE0E0E0) : primaryGreen,
                  disabledBackgroundColor: const Color(0xFFE0E0E0),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Nutrition Completed',
                      style: TextStyle(
                          color: isCompleted ? Colors.black54 : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  if (isCompleted) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.check, color: Colors.black54, size: 20),
                  ]
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgressCard(int completedWorkouts, int totalWorkouts,
      int completedMeals, int totalMeals) {
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
              // Pass the green text color for Workouts
              _buildProgressItem(
                  value: completedWorkouts,
                  total: totalWorkouts,
                  label: 'Workouts',
                  color: AppColors.primaryGreen,
                  progressTextColor: AppColors.primaryGreen),
              // Pass the blue text color for Meals
              _buildProgressItem(
                  value: completedMeals,
                  total: totalMeals,
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

  String _getWorkoutEmoji(String workoutName) {
    final name = workoutName.toLowerCase();
    if (name.contains('strength')) return '💪';
    if (name.contains('cardio')) return '🏃';
    if (name.contains('recovery')) return '🧘';
    if (name.contains('rest')) return '😌';
    return '🏋️';
  }

  Widget _buildUpcomingPlanCard(
      {required String dayOfWeek,
      required String date,
      required String workoutName,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: _buildStyledContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dayOfWeek,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText)),
            const SizedBox(height: 4),
            Text(date,
                style: const TextStyle(
                    color: AppColors.subtitleGray, fontSize: 14)),
            const SizedBox(height: 20),
            Row(children: [
              Text(_getWorkoutEmoji(workoutName),
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(workoutName,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText)),
              ),
            ]),
            const SizedBox(height: 16),
            const Align(
                alignment: Alignment.centerRight,
                child: Text('View Details >',
                    style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
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
