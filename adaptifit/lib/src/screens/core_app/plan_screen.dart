import 'package:adaptifit/src/core/models/models.dart';
import 'package:adaptifit/src/constants/app_colors.dart';

import 'package:adaptifit/src/core/models/user.dart';
import 'package:adaptifit/src/core/models/workout.dart';
import 'package:adaptifit/src/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:adaptifit/src/screens/core_app/calendar_screen.dart'; // Import the calendar screen
import 'package:adaptifit/src/screens/core_app/workout_overview_screen.dart';
import 'package:adaptifit/src/screens/core_app/nutrition_overview_screen.dart';
import 'package:intl/intl.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final FirestoreService _firestoreService = FirestoreService();

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
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'My Plan',
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today_outlined,
                              size: 28, color: AppColors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CalendarScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                    Text(
                      DateFormat('EEEE, MMMM d').format(DateTime.now()),
                      style: const TextStyle(
                          fontSize: 16, color: AppColors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- Today's Plan Section ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Today's Plan",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Plan Overview >',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: StreamBuilder<UserModel>(
                  stream: _firestoreService.getUser(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final user = userSnapshot.data;

                    return StreamBuilder<Calendar>(
                      stream: _firestoreService.getCalendarEntry(today),
                      builder: (context, calendarSnapshot) {
                        if (calendarSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        // Check if onboarding is complete but plan is not yet generated
                        if (user != null &&
                            user.onboardingAnswers.isNotEmpty &&
                            !calendarSnapshot.hasData) {
                          return _buildGeneratingPlanCard();
                        }

                        if (!calendarSnapshot.hasData) {
                          return _buildNoPlanCard();
                        }

                        final calendarDay = calendarSnapshot.data!;

                        return Column(
                          children: [
                            if (calendarDay.hasWorkout)
                              StreamBuilder<List<Workout>>(
                                stream: _firestoreService
                                    .getWorkouts(calendarDay.planId!),
                                builder: (context, workoutSnapshot) {
                                  if (!workoutSnapshot.hasData) {
                                    return const SizedBox.shrink();
                                  }
                                  final workout = workoutSnapshot.data!
                                      .firstWhere(
                                          (w) =>
                                              w.workoutId ==
                                              calendarDay.workoutId,
                                          orElse: () => Workout(
                                              workoutId: '',
                                              userId: '',
                                              name: 'Workout not found',
                                              exercises: []));
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              WorkoutOverviewScreen(
                                                  workoutId: workout.workoutId),
                                        ),
                                      );
                                    },
                                    child: _buildWorkoutCard(workout),
                                  );
                                },
                              ),
                            const SizedBox(height: 16),
                            if (calendarDay.hasNutrition)
                              StreamBuilder<List<Nutrition>>(
                                stream: _firestoreService.getNutritionPlans(),
                                builder: (context, nutritionSnapshot) {
                                  if (!nutritionSnapshot.hasData) {
                                    return const SizedBox.shrink();
                                  }
                                  final nutrition = nutritionSnapshot.data!
                                      .firstWhere(
                                          (n) => calendarDay.nutritionIds
                                              .contains(n.nutritionId),
                                          orElse: () => Nutrition(
                                              nutritionId: '',
                                              userId: '',
                                              mealType: 'Not Found',
                                              items: [],
                                              totalCalories: 0,
                                              totalProtein: 0,
                                              totalCarbs: 0,
                                              totalFat: 0));
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              NutritionOverviewScreen(
                                                  nutritionId:
                                                      nutrition.nutritionId),
                                        ),
                                      );
                                    },
                                    child: _buildNutritionCard(nutrition),
                                  );
                                },
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // --- Weekly Progress Section ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: StreamBuilder<UserModel>(
                  stream: _firestoreService.getUser(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return _buildWeeklyProgressCard(
                          0, 7, 19, 21); // Show dummy data while loading
                    }
                    final user = userSnapshot.data!;
                    final completedWorkouts =
                        user.progress['completedWorkouts'] ?? 0;
                    final totalWorkouts = user.daysPerWeek;
                    final completedMeals = user.progress['completedMeals'] ?? 0;
                    final totalMeals = totalWorkouts * 3;

                    return _buildWeeklyProgressCard(completedWorkouts,
                        totalWorkouts, completedMeals, totalMeals);
                  },
                ),
              ),
              const SizedBox(height: 24),

              // --- Upcoming Plans Section ---
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Upcoming Plans",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                itemBuilder: (context, index) {
                  final nextDay = DateTime.now().add(Duration(days: index + 1));
                  final nextDayString =
                      DateFormat('yyyy-MM-dd').format(nextDay);
                  return StreamBuilder<Calendar>(
                    stream: _firestoreService.getCalendarEntry(nextDayString),
                    builder: (context, calendarSnapshot) {
                      if (!calendarSnapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildNoPlanCard(
                            title:
                                'No plan for ${DateFormat('EEEE').format(nextDay)}',
                            message:
                                'Your personalized plan for this day is being generated.',
                          ),
                        );
                      }
                      final calendarDay = calendarSnapshot.data!;
                      return StreamBuilder<List<Workout>>(
                        stream:
                            _firestoreService.getWorkouts(calendarDay.planId!),
                        builder: (context, workoutSnapshot) {
                          final workout = workoutSnapshot.data?.firstWhere(
                              (w) => w.workoutId == calendarDay.workoutId,
                              orElse: () => Workout(
                                  workoutId: '',
                                  userId: '',
                                  name: 'Rest Day',
                                  exercises: []));
                          return StreamBuilder<List<Nutrition>>(
                            stream: _firestoreService.getNutritionPlans(),
                            builder: (context, nutritionSnapshot) {
                              final nutrition = nutritionSnapshot.data
                                  ?.firstWhere(
                                      (n) => calendarDay.nutritionIds
                                          .contains(n.nutritionId),
                                      orElse: () => Nutrition(
                                          nutritionId: '',
                                          userId: '',
                                          mealType: 'No Nutrition',
                                          items: [],
                                          totalCalories: 0,
                                          totalProtein: 0,
                                          totalCarbs: 0,
                                          totalFat: 0));
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: _buildUpcomingPlanCard(
                                  dayAndDate:
                                      DateFormat('E, MMM d').format(nextDay),
                                  emoji: '💪',
                                  workout: workout?.name ?? '...',
                                  breakfast:
                                      nutrition?.items.first.name ?? '...',
                                  dinner: nutrition?.items.last.name ?? '...',
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoPlanCard({
    String title = "No plan for today",
    String message =
        "Your personalized plan is being generated. Please check back in a few minutes.",
  }) {
    return _buildStyledContainer(
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.subtitleGray),
          ),
          const SizedBox(height: 16),
          const Icon(
            Icons.hourglass_empty,
            size: 40,
            color: AppColors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratingPlanCard() {
    return _buildStyledContainer(
      child: Column(
        children: const [
          Text(
            "Generating Your Plan...",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Please wait while we create your personalized fitness and nutrition plan. This may take a few minutes.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.subtitleGray),
          ),
          SizedBox(height: 16),
          CircularProgressIndicator(),
        ],
      ),
    );
  }

  // A generic card builder to match the design's container style
  Widget _buildStyledContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withAlpha(20),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
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
                  color: AppColors.primaryGreen.withAlpha(38),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.fitness_center,
                    color: AppColors.primaryGreen),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '🕒 45 minutes',
                    style: TextStyle(color: AppColors.subtitleGray),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'View Details >',
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Workout Completed',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
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
                  color: AppColors.primaryBlue.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.apple, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nutrition.mealType,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Balanced nutrition plan',
                    style: TextStyle(color: AppColors.subtitleGray),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'View Details >',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Nutrition Completed',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
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
          const Row(
            children: [
              Icon(Icons.trending_up, color: AppColors.darkText),
              SizedBox(width: 8),
              Text(
                'Weekly Progress',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$completedWorkouts/$totalWorkouts',
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen),
                  ),
                  const SizedBox(height: 4),
                  const Text('Workouts',
                      style: TextStyle(color: AppColors.subtitleGray)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 120,
                    child: LinearProgressIndicator(
                      value: totalWorkouts == 0
                          ? 0
                          : completedWorkouts / totalWorkouts,
                      backgroundColor: AppColors.lightGrey2,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryGreen),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$completedMeals/$totalMeals',
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue),
                  ),
                  const SizedBox(height: 4),
                  const Text('Meals',
                      style: TextStyle(color: AppColors.subtitleGray)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 120,
                    child: LinearProgressIndicator(
                      value: totalMeals == 0 ? 0 : completedMeals / totalMeals,
                      backgroundColor: AppColors.lightGrey2,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryBlue),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingPlanCard({
    required String dayAndDate,
    required String emoji,
    required String workout,
    required String breakfast,
    required String dinner,
  }) {
    return _buildStyledContainer(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayAndDate,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          workout,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Breakfast: $breakfast',
                        style: const TextStyle(color: AppColors.subtitleGray)),
                    const SizedBox(height: 4),
                    Text('Dinner: $dinner',
                        style: const TextStyle(color: AppColors.subtitleGray)),
                  ],
                ),
              ),
              Text(
                'View Details >',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
