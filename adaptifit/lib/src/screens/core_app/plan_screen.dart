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
      // Stream for the new "Your Workout Library" section
      _plansStream = _firestoreService.getPlans();
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
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
      child: StreamBuilder<UserModel>(
        stream: _firestoreService.getUser(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = userSnapshot.data;

          return StreamBuilder<Calendar>(
            stream: _firestoreService.getCalendarEntry(today),
            builder: (context, calendarSnapshot) {
              if (calendarSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (user != null &&
                  user.onboardingCompleted &&
                  !calendarSnapshot.hasData) {
                return _buildGeneratingPlanCard();
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
                          return _buildWorkoutCard(workoutSnapshot.data!);
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    )
                  else
                    _buildNoPlanCard(
                        title: "Rest Day", message: "Enjoy your day off!"),
                  if (calendarDay.hasNutrition) ...[
                    const SizedBox(height: 16),
                    StreamBuilder<List<Nutrition>>(
                      stream: _firestoreService
                          .getNutritionsByIds(calendarDay.nutritionIds),
                      builder: (context, nutritionSnapshot) {
                        if (nutritionSnapshot.hasData) {
                          return Column(
                            children: nutritionSnapshot.data!
                                .map((nutrition) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16.0),
                                      child: _buildNutritionCard(nutrition),
                                    ))
                                .toList(),
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ]
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildWeeklyProgress() {
    return StreamBuilder<UserModel>(
      stream: _firestoreService.getUser(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return _buildWeeklyProgressCard(0, 7, 0, 21); // Placeholder
        }
        final user = userSnapshot.data!;
        final progress = user.progress;
        final completedWorkouts = progress['completedWorkouts'] ?? 0;
        final totalWorkouts = user.daysPerWeek;
        final completedMeals = progress['mealsCompleted'] ?? 0;
        final totalMeals = totalWorkouts * 3;
        return _buildWeeklyProgressCard(
            completedWorkouts, totalWorkouts, completedMeals, totalMeals);
      },
    );
  }

  // UPDATED: This widget now builds a library of all workouts from all plans
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
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText)),
              Text(DateFormat('EEEE, MMMM d').format(DateTime.now()),
                  style: const TextStyle(
                      fontSize: 16, color: AppColors.subtitleGray)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined,
                size: 28, color: AppColors.darkText),
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
                style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
          ),
      ],
    );
  }

  Widget _buildStyledContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppColors.darkText.withOpacity(0.05),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildWorkoutCard(Workout workout) {
    return _buildStyledContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.fitness_center,
                      color: AppColors.primaryGreen)),
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
                      Text('🕒 ${workout.duration}',
                          style:
                              const TextStyle(color: AppColors.subtitleGray)),
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
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600))),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 0),
              child: const Text('Workout Completed',
                  style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(Nutrition nutrition) {
    return _buildStyledContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppColors.secondaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child:
                      const Icon(Icons.apple, color: AppColors.secondaryBlue)),
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
                        style: TextStyle(color: AppColors.subtitleGray)),
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
                      builder: (context) => NutritionOverviewScreen(
                          nutritionId: nutrition.nutritionId)),
                );
              },
              child: const Text('View Details >',
                  style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600))),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 0),
              child: const Text('Nutrition Completed',
                  style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16))),
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
      String? breakfast,
      String? dinner,
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
              Text(workoutName,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText)),
            ]),
            if (breakfast != null || dinner != null) const SizedBox(height: 12),
            if (breakfast != null) ...[
              Text('Breakfast: $breakfast',
                  style: const TextStyle(
                      color: AppColors.subtitleGray, fontSize: 14)),
              const SizedBox(height: 6),
            ],
            if (dinner != null)
              Text('Dinner: $dinner',
                  style: const TextStyle(
                      color: AppColors.subtitleGray, fontSize: 14)),
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

  Widget _buildNoPlanCard(
      {String title = "No plan for today",
      String message = "Enjoy your day off!"}) {
    return _buildStyledContainer(
      child: Column(
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.subtitleGray)),
          const SizedBox(height: 16),
          const Icon(Icons.celebration_outlined,
              size: 40, color: AppColors.grey),
        ],
      ),
    );
  }
}
