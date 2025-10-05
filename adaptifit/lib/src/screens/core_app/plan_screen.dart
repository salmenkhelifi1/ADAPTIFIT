import 'package:adaptifit/src/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:adaptifit/src/constants/app_colors.dart';
import 'package:adaptifit/src/models/calendar_entry.dart';
import 'package:adaptifit/src/models/nutrition.dart';
import 'package:adaptifit/src/models/plan.dart';
import 'package:adaptifit/src/models/workout.dart';
import 'package:adaptifit/src/screens/core_app/calendar_screen.dart';
import 'package:adaptifit/src/screens/core_app/daily_plan_detail_screen.dart';
import 'package:adaptifit/src/screens/core_app/nutrition_overview_screen.dart';
import 'package:adaptifit/src/screens/core_app/plan_details_screen.dart';
import 'package:adaptifit/src/screens/core_app/workout_overview_screen.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final ApiService _apiService = ApiService();
  late Future<CalendarEntry?> _calendarEntryFuture;
  late Future<List<Plan>> _plansFuture;

  @override
  void initState() {
    super.initState();
    _calendarEntryFuture = _apiService.getCalendarEntry(DateTime.now());
    _plansFuture = _apiService.getMyPlans();
  }

  Future<void> _completeWorkout(DateTime date, bool completed) async {
    try {
      await _apiService.completeWorkout(date, completed: completed);
      // Refresh the calendar entry to update the completed status
      setState(() {
        _calendarEntryFuture = _apiService.getCalendarEntry(DateTime.now());
      });
    } catch (e) {
      debugPrint("Error completing workout: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to complete workout.')),
        );
      }
    }
  }

  Future<void> _completeNutrition(DateTime date, String nutritionId) async {
    try {
      await _apiService.completeNutrition(date, nutritionId);
      // Refresh the calendar entry to update the completed status
      setState(() {
        _calendarEntryFuture = _apiService.getCalendarEntry(DateTime.now());
      });
    } catch (e) {
      debugPrint("Error completing nutrition: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to complete nutrition.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              _buildTodaysPlan(),
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
              _buildWorkoutLibraryList(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysPlan() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: FutureBuilder<CalendarEntry?>(
        future: _calendarEntryFuture,
        builder: (context, calendarSnapshot) {
          if (calendarSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (calendarSnapshot.hasError) {
            return _buildNoPlanCard(title: "Error", message: "Could not load today's plan.");
          }
          if (!calendarSnapshot.hasData || calendarSnapshot.data == null) {
            return _buildNoPlanCard(title: "Rest Day");
          }

          final calendarDay = calendarSnapshot.data!;

          return Column(
            children: [
              if (calendarDay.workoutId != null && calendarDay.planId != null)
                FutureBuilder<List<Workout>>(
                  future: _apiService.getWorkoutsForPlan(calendarDay.planId!),
                  builder: (context, workoutSnapshot) {
                    if (workoutSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!workoutSnapshot.hasData || workoutSnapshot.data!.isEmpty) {
                      return const Center(child: Text("Workout not found"));
                    }
                    final workout = workoutSnapshot.data!.firstWhere((w) => w.id == calendarDay.workoutId, orElse: () => null as Workout);
                    if (workout == null) {
                      return const Center(child: Text("Today's workout not found in the plan."));
                    }
                    return _buildWorkoutCard(workout, calendarDay);
                  },
                )
              else
                _buildNoPlanCard(title: "Rest Day", message: "Enjoy your day off!"),
              if (calendarDay.nutritionIds != null && calendarDay.nutritionIds!.isNotEmpty && calendarDay.planId != null) ...[
                const SizedBox(height: 16),
                FutureBuilder<Nutrition>(
                  future: _apiService.getNutritionForPlan(calendarDay.planId!),
                  builder: (context, nutritionSnapshot) {
                     if (nutritionSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!nutritionSnapshot.hasData) {
                      return const Center(child: Text("Nutrition plan not found"));
                    }
                    return _buildNutritionCard(nutritionSnapshot.data!, calendarDay);
                  },
                ),
              ]
            ],
          );
        },
      ),
    );
  }

  Widget _buildWeeklyProgress() {
    // Placeholder data as API endpoint is not available
    return _buildWeeklyProgressCard(3, 5, 12, 21);
  }

  Widget _buildWorkoutLibraryList() {
    return FutureBuilder<List<Plan>>(
      future: _plansFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: _buildStyledContainer(child: Text('Error: ${snapshot.error}')),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: _buildStyledContainer(child: const Text('No plans found.')),
          );
        }

        final plans = snapshot.data!;
        // For now, just show the first plan details
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
                  builder: (context) => PlanDetailsScreen(plan: firstPlan),
                ),
              );
            },
          ),
        );
      },
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
              const Text('My Plan', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(DateFormat('EEEE, MMMM d').format(DateTime.now()), style: const TextStyle(fontSize: 16, color: Colors.black54)),
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

  Widget _buildSectionHeader({required String title, String? actionText, VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        if (actionText != null)
          GestureDetector(
            onTap: onTap,
            child: Text(actionText, style: TextStyle(color: Colors.green[600], fontWeight: FontWeight.w600, fontSize: 16)),
          ),
      ],
    );
  }

  Widget _buildStyledContainer({required Widget child, bool isCentered = false}) {
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

  Widget _buildWorkoutCard(Workout workout, CalendarEntry calendar) {
    final bool isCompleted = calendar.workoutCompleted;
    const primaryGreen = Color(0xFF1EB955);

    return _buildStyledContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.fitness_center, color: primaryGreen, size: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(workout.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 16, color: Colors.black54),
                        const SizedBox(width: 4),
                        Text(workout.duration, style: const TextStyle(color: Colors.black54, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WorkoutOverviewScreen(workout: workout)),
                );
              },
              child: const Text('View Details >', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w600))),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: isCompleted ? null : () => _completeWorkout(calendar.date, !isCompleted),
              style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted ? const Color(0xFFE0E0E0) : primaryGreen,
                  disabledBackgroundColor: const Color(0xFFE0E0E0),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Workout Completed', style: TextStyle(color: isCompleted ? Colors.black54 : Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildNutritionCard(Nutrition nutrition, CalendarEntry calendar) {
    final bool isCompleted = calendar.completedNutritionIds.contains(nutrition.id);
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
                  decoration: BoxDecoration(color: primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.apple, color: primaryBlue, size: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nutrition.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    const Text('Balanced nutrition plan', style: const TextStyle(color: Colors.black54, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
              onTap: () {
                if (calendar.nutritionIds!.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NutritionOverviewScreen(nutritionId: calendar.nutritionIds!.first)),
                  );
                }
              },
              child: const Text('View Details >', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w600))),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: isCompleted ? null : () => _completeNutrition(calendar.date, nutrition.id),
              style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted ? const Color(0xFFE0E0E0) : primaryGreen,
                  disabledBackgroundColor: const Color(0xFFE0E0E0),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Nutrition Completed', style: TextStyle(color: isCompleted ? Colors.black54 : Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildWeeklyProgressCard(int completedWorkouts, int totalWorkouts, int completedMeals, int totalMeals) {
    return _buildStyledContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.trending_up, color: AppColors.darkText),
            SizedBox(width: 8),
            Text('Weekly Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
          ]),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressItem(value: completedWorkouts, total: totalWorkouts, label: 'Workouts', color: AppColors.primaryGreen),
              _buildProgressItem(value: completedMeals, total: totalMeals, label: 'Meals', color: AppColors.secondaryBlue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem({required int value, required int total, required String label, required Color color}) {
    return Column(
      children: [
        Text('$value/$total', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkText)),
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

  Widget _buildUpcomingPlanCard({required String dayOfWeek, required String date, required String workoutName, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: _buildStyledContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dayOfWeek, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText)),
            const SizedBox(height: 4),
            Text(date, style: const TextStyle(color: AppColors.subtitleGray, fontSize: 14)),
            const SizedBox(height: 20),
            Row(children: [
              Text(_getWorkoutEmoji(workoutName), style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(workoutName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkText)),
              ),
            ]),
            const SizedBox(height: 16),
            const Align(
                alignment: Alignment.centerRight,
                child: Text('View Details >', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 16))),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPlanCard({String title = "No plan for today", String message = "Enjoy your day off!"}) {
    return _buildStyledContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, fontSize: 16)),
          const SizedBox(height: 16),
          const Icon(Icons.celebration_outlined, size: 40, color: Colors.grey),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
