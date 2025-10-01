// lib/src/screens/core_app/plan_screen.dart

import 'package:adaptifit/src/core/models/models.dart';

import 'package:adaptifit/src/constants/app_colors.dart';

import 'package:adaptifit/src/services/firestore_service.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:adaptifit/src/screens/core_app/calendar_screen.dart';

import 'package:adaptifit/src/screens/core_app/workout_overview_screen.dart';

import 'package:adaptifit/src/screens/core_app/nutrition_overview_screen.dart';

import 'package:adaptifit/src/screens/core_app/daily_plan_detail_screen.dart';

import 'package:intl/intl.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  Stream<List<Plan>>? _plansStream;

  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    if (_currentUser != null) {
      _plansStream = _firestoreService.getPlans();
    }
  }

  Future<void> _toggleCompletion(String date, bool currentStatus) async {
    try {
      await _firestoreService.updateCalendarEntryCompletion(
          date, !currentStatus);
    } catch (e) {
      debugPrint("Error updating completion status: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update status.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.screenBackground, // Updated background color

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---

              _buildHeader(context),

              const SizedBox(height: 20),

              // --- Today's Plan Section ---

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

              _buildTodaysPlan(today),

              const SizedBox(height: 24),

              // --- Weekly Progress Section ---

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

              // --- Upcoming Plans Section (UPDATED LOGIC) ---

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

  Widget _buildTodaysPlan(String today) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: StreamBuilder<Calendar>(
        stream: _firestoreService.getCalendarEntry(today),
        builder: (context, calendarSnapshot) {
          if (calendarSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!calendarSnapshot.hasData || calendarSnapshot.data == null) {
            return _buildNoPlanCard(title: "Rest Day");
          }

          final calendarDay = calendarSnapshot.data!;

          return Column(
            children: [
              if (calendarDay.hasWorkout &&
                  calendarDay.planId != null &&
                  calendarDay.workoutId != null)
                StreamBuilder<Workout>(
                  stream: _firestoreService.getWorkout(
                      calendarDay.planId!, calendarDay.workoutId!),
                  builder: (context, workoutSnapshot) {
                    if (workoutSnapshot.hasData) {
                      return _buildWorkoutCard(
                          workoutSnapshot.data!, calendarDay);
                    }

                    return const Center(child: CircularProgressIndicator());
                  },
                )
              else
                _buildNoPlanCard(
                    title: "Rest Day", message: "Enjoy your day off!"),
              if (calendarDay.hasNutrition) ...[
                const SizedBox(height: 16),
                _buildNutritionCard(calendarDay),
              ]
            ],
          );
        },
      ),
    );
  }

  Widget _buildWeeklyProgress() {
    return FutureBuilder<Map<String, int>>(
      future: _firestoreService.getUserProgressStats(),
      builder: (context, statsSnapshot) {
        if (statsSnapshot.connectionState == ConnectionState.waiting) {
          return _buildWeeklyProgressCard(0, 0, 0, 0);
        }

        if (statsSnapshot.hasError) {
          return _buildStyledContainer(
              child: const Text("Error loading progress."));
        }

        if (!statsSnapshot.hasData) {
          return _buildWeeklyProgressCard(0, 0, 0, 0);
        }

        final stats = statsSnapshot.data!;

        final completedWorkouts = stats['completedWorkouts'] ?? 0;

        final completedMeals = stats['mealsCompleted'] ?? 0;

        return StreamBuilder<UserModel>(
          stream: _firestoreService.getUser(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return _buildWeeklyProgressCard(
                  completedWorkouts, 7, completedMeals, 21);
            }

            final user = userSnapshot.data!;

            final totalWorkouts = user.daysPerWeek;

            final totalMeals = totalWorkouts * 3;

            return _buildWeeklyProgressCard(
                completedWorkouts, totalWorkouts, completedMeals, totalMeals);
          },
        );
      },
    );
  }

  Widget _buildWorkoutLibraryList() {
    return StreamBuilder<List<Plan>>(
      stream: _plansStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child:
                _buildStyledContainer(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: _buildStyledContainer(child: const Text('No plans found.')),
          );
        }

        final plans = snapshot.data!;

        return Column(
          children: plans.map((plan) {
            return StreamBuilder<List<Workout>>(
              stream: _firestoreService.getWorkouts(plan.planId),
              builder: (context, workoutSnapshot) {
                if (workoutSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }

                if (!workoutSnapshot.hasData || workoutSnapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                }

                final workouts = workoutSnapshot.data!;

                return Column(
                  children: workouts.map((workout) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: _buildUpcomingPlanCard(
                        dayOfWeek: plan.planName,
                        date: workout.targetMuscles?.join(', ') ??
                            'General Workout',
                        workoutName: workout.name,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkoutOverviewScreen(
                                planId: plan.planId,
                                workoutId: workout.workoutId,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

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

  Widget _buildWorkoutCard(Workout workout, Calendar calendar) {
    final bool isCompleted = calendar.completed;

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
                    if (workout.duration != null)
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined,
                              size: 16, color: Colors.black54),
                          const SizedBox(width: 4),
                          Text(workout.duration!,
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
          GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WorkoutOverviewScreen(
                          planId: workout.planId!,
                          workoutId: workout.workoutId)),
                );
              },
              child: const Text('View Details >',
                  style: TextStyle(
                      color: primaryGreen, fontWeight: FontWeight.w600))),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: isCompleted
                  ? null
                  : () => _toggleCompletion(calendar.dateId, isCompleted),
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

  Widget _buildNutritionCard(Calendar calendar) {
    final bool isCompleted = calendar.completed;

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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("High Protein Focus",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 4),
                    Text('Balanced nutrition plan',
                        style: TextStyle(color: Colors.black54, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
              onTap: () {
                if (calendar.nutritionIds.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NutritionOverviewScreen(
                            nutritionId: calendar.nutritionIds.first)),
                  );
                }
              },
              child: const Text('View Details >',
                  style: TextStyle(
                      color: primaryGreen, fontWeight: FontWeight.w600))),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: isCompleted
                  ? null
                  : () => _toggleCompletion(calendar.dateId, isCompleted),
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
              _buildProgressItem(
                  value: completedWorkouts,
                  total: totalWorkouts,
                  label: 'Workouts',
                  color: AppColors.primaryGreen),
              _buildProgressItem(
                  value: completedMeals,
                  total: totalMeals,
                  label: 'Meals',
                  color: AppColors.secondaryBlue),
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
      required Color color}) {
    return Column(
      children: [
        Text('$value/$total',
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText)),
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
                        fontWeight: FontWeight.bold,
                        fontSize: 16))),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratingPlanCard() {
    return _buildStyledContainer(
      child: Column(
        children: const [
          Text("Generating Your Plan...",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 8),
          Text(
              "Please wait while we create your personalized fitness and nutrition plan. This may take a few minutes.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.subtitleGray)),
          SizedBox(height: 16),
          CircularProgressIndicator(),
        ],
      ),
    );
  }

  // UPDATED: This widget now reflects the new UI from the screenshot

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
