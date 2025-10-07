import 'package:adaptifit/src/models/nutrition.dart';
import 'package:adaptifit/src/models/workout.dart';
import 'package:adaptifit/src/providers/calendar_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:adaptifit/src/constants/app_colors.dart';
import 'package:adaptifit/src/providers/plan_provider.dart';
import 'package:adaptifit/src/screens/core_app/nutrition_overview_screen.dart';

class DailyPlanDetailScreen extends ConsumerWidget {
  final DateTime date;

  const DailyPlanDetailScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarEntryValue = ref.watch(calendarEntryProvider(date));

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.screenBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            Text(
              DateFormat('EEEE').format(date),
              style: const TextStyle(
                color: AppColors.darkText,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(
              DateFormat('MMM d, yyyy').format(date),
              style: const TextStyle(
                color: AppColors.subtitleGray,
                fontSize: 14,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: calendarEntryValue.when(
        data: (calendarDay) {
          if (calendarDay == null) {
            return _buildNoPlanMessage();
          }

          final workoutValue = calendarDay.workoutId.isNotEmpty
              ? ref.watch(planWorkoutsProvider(calendarDay.planId))
              : null;
          final nutritionValue = calendarDay.nutritionIds.isNotEmpty
              ? ref.watch(planNutritionProvider(calendarDay.planId))
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                if (workoutValue != null)
                  workoutValue.when(
                    data: (workouts) {
                      Workout? workout;
                      for (final w in workouts) {
                        if (w.id == calendarDay.workoutId) {
                          workout = w;
                          break;
                        }
                      }
                      if (workout == null) return const SizedBox.shrink();
                      return _buildWorkoutCard(workout);
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) =>
                        const Center(child: Text("Error loading workout")),
                  ),
                if (nutritionValue != null) ...[
                  const SizedBox(height: 20),
                  _buildNutritionHeader(),
                  const SizedBox(height: 16),
                  nutritionValue.when(
                    data: (nutrition) {
                      if (nutrition == null) {
                        return const Center(
                            child: Text("Nutrition plan not found"));
                      }
                      return Column(
                        children: [
                          _buildMealsSummaryCard(nutrition),
                          const SizedBox(height: 16),
                          _buildNutritionTotalsAndCta(
                              context, calendarDay.planId, nutrition),
                        ],
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) =>
                        const Center(child: Text("Error loading nutrition")),
                  ),
                ],
                const SizedBox(height: 20),
                _buildDailyTasksCard(),
                const SizedBox(height: 16),
                _buildDailyNotesCard(),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
      ),
    );
  }

  // Removed preview banner per updated design

  Widget _buildWorkoutCard(Workout workout) {
    final exercisesCount = workout.exercises.length;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkText.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💪', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Active Recovery · ${workout.duration}',
                      style: const TextStyle(color: AppColors.subtitleGray)),
                ],
              ),
            ],
          ),
          const Divider(height: 32),
          const Text(
            'Light movement and stretching for muscle recovery',
            style: TextStyle(color: AppColors.darkText),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.timer_outlined,
                  size: 16, color: AppColors.subtitleGray),
              const SizedBox(width: 6),
              Text(workout.duration,
                  style: const TextStyle(color: AppColors.subtitleGray)),
              const SizedBox(width: 16),
              const Icon(Icons.fitness_center,
                  size: 16, color: AppColors.subtitleGray),
              const SizedBox(width: 6),
              Text('$exercisesCount exercises',
                  style: const TextStyle(color: AppColors.subtitleGray)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('View Full Workout Details',
                      style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16)),
                  SizedBox(width: 6),
                  Icon(Icons.chevron_right, color: AppColors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Removed unused _buildExerciseRow; details are summarized above per design

  // Replaced by compact meals summary + totals CTA

  Widget _buildMealsSummaryCard(Nutrition nutrition) {
    String mealName(String key) => nutrition.meals[key]?.name ?? '-';
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Today's Meals",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _buildMealRow('Breakfast:', mealName('breakfast')),
          const SizedBox(height: 8),
          _buildMealRow('Lunch:', mealName('lunch')),
          const SizedBox(height: 8),
          _buildMealRow('Dinner:', mealName('dinner')),
          const SizedBox(height: 8),
          _buildMealRow('Snacks:', mealName('snacks')),
        ],
      ),
    );
  }

  Widget _buildMealRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label,
              style: const TextStyle(color: AppColors.subtitleGray)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  color: AppColors.darkText, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildNutritionTotalsAndCta(
      BuildContext context, String planId, Nutrition nutrition) {
    int totalCalories = 0;
    int totalProtein = 0;
    for (final meal in nutrition.meals.values) {
      totalCalories += meal.calories;
      totalProtein += meal.protein;
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text('$totalCalories',
                    style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text('Calories',
                    style: TextStyle(color: AppColors.subtitleGray)),
              ],
            ),
            Column(
              children: [
                Text('${totalProtein}g',
                    style: const TextStyle(
                        color: AppColors.secondaryBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text('Protein',
                    style: TextStyle(color: AppColors.subtitleGray)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => NutritionOverviewScreen(planId: planId)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryBlue,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('View Full Nutrition Plan',
                    style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
                SizedBox(width: 6),
                Icon(Icons.chevron_right, color: AppColors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyTasksCard() {
    final bullet = Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.primaryGreen,
        shape: BoxShape.circle,
      ),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkText.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_box_outlined, color: AppColors.darkText),
              SizedBox(width: 8),
              Text('Daily Tasks',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Recommended habits for optimal results',
              style: TextStyle(color: AppColors.subtitleGray)),
          const SizedBox(height: 16),
          Row(children: [
            bullet,
            const SizedBox(width: 12),
            const Expanded(child: Text('Drink 8 glasses of water'))
          ]),
          const SizedBox(height: 12),
          Row(children: [
            bullet,
            const SizedBox(width: 12),
            const Expanded(child: Text('Take progress photos'))
          ]),
          const SizedBox(height: 12),
          Row(children: [
            bullet,
            const SizedBox(width: 12),
            const Expanded(child: Text('Log meals in app'))
          ]),
          const SizedBox(height: 12),
          Row(children: [
            bullet,
            const SizedBox(width: 12),
            const Expanded(child: Text('Stretch for 10 minutes'))
          ]),
          const SizedBox(height: 12),
          Row(children: [
            bullet,
            const SizedBox(width: 12),
            const Expanded(child: Text('Get 7-8 hours sleep'))
          ]),
        ],
      ),
    );
  }

  Widget _buildDailyNotesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.neutralGray.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily Notes', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text(
              'Remember to listen to your body and adjust intensity as needed. Focus on proper form over speed, and don\'t forget to stay hydrated throughout the day.',
              style: TextStyle(color: AppColors.darkText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkText.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.apple, color: AppColors.secondaryBlue, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nutrition Plan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Post-Workout Recovery',
                  style: TextStyle(color: AppColors.subtitleGray, fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.neutralGray.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('1,850 cal',
                style: TextStyle(color: AppColors.darkText)),
          )
        ],
      ),
    );
  }

  Widget _buildNoPlanMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            const Text('No Plan For This Day',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Enjoy your rest day!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  // Removed detailed meal card (using compact list instead)

  // Removed hydration block (replaced by tasks/notes)

  // Removed old daily summary per updated design

  // Removed old stat item widget
}
