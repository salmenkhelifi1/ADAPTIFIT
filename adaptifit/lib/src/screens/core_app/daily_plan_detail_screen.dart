
import 'package:adaptifit/src/models/calendar_entry.dart';
import 'package:adaptifit/src/models/nutrition.dart';
import 'package:adaptifit/src/models/workout.dart';
import 'package:adaptifit/src/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:adaptifit/src/constants/app_colors.dart';

class _PlanDetails {
  final Workout? workout;
  final Nutrition? nutrition;

  _PlanDetails({this.workout, this.nutrition});
}

class DailyPlanDetailScreen extends StatefulWidget {
  final DateTime date;

  const DailyPlanDetailScreen({super.key, required this.date});

  @override
  State<DailyPlanDetailScreen> createState() => _DailyPlanDetailScreenState();
}

class _DailyPlanDetailScreenState extends State<DailyPlanDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<_PlanDetails> _planDetailsFuture;

  @override
  void initState() {
    super.initState();
    _planDetailsFuture = _loadPlanDetails();
  }

  Future<_PlanDetails> _loadPlanDetails() async {
    final calendarDay = await _apiService.getCalendarEntry(widget.date);
    if (calendarDay == null) {
      return _PlanDetails();
    }

    final workoutFuture = calendarDay.workoutId.isNotEmpty
        ? _apiService.getWorkoutsForPlan(calendarDay.planId)
        : Future.value(null);

    final nutritionFuture = calendarDay.nutritionIds.isNotEmpty
        ? _apiService.getNutritionForPlan(calendarDay.planId)
        : Future.value(null);

    final results = await Future.wait([workoutFuture, nutritionFuture]);

    final workouts = results[0] as List<Workout>?;
    final nutrition = results[1] as Nutrition?;

    final workout = workouts?.firstWhere((w) => w.id == calendarDay.workoutId);

    return _PlanDetails(workout: workout, nutrition: nutrition);
  }

  @override
  Widget build(BuildContext context) {
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
              DateFormat('EEEE').format(widget.date),
              style: const TextStyle(
                color: AppColors.darkText,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(
              DateFormat('MMM d, yyyy').format(widget.date),
              style: const TextStyle(
                color: AppColors.subtitleGray,
                fontSize: 14,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<_PlanDetails>(
        future: _planDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || (snapshot.data!.workout == null && snapshot.data!.nutrition == null)) {
            return _buildNoPlanMessage();
          }

          final planDetails = snapshot.data!;
          final workout = planDetails.workout;
          final nutrition = planDetails.nutrition;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildPreviewBanner(),
                const SizedBox(height: 20),
                if (workout != null)
                  _buildWorkoutCard(workout),
                if (nutrition != null) ...[
                  const SizedBox(height: 20),
                  _buildNutritionHeader(),
                  const SizedBox(height: 16),
                  _buildNutritionDetailsCard(nutrition),
                  const SizedBox(height: 16),
                  _buildDailySummaryCard(workout, nutrition),
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreviewBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.secondaryBlue),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'This is a preview of your upcoming plan. Completion options will be available on the day of your workout.',
              style: TextStyle(color: AppColors.darkText, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(Workout workout) {
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
                  Text('🕒 ${workout.duration}',
                      style: const TextStyle(color: AppColors.subtitleGray)),
                ],
              ),
            ],
          ),
          const Divider(height: 32),
          ...workout.exercises
              .map((exercise) => _buildExerciseRow(exercise))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildExerciseRow(Exercise exercise) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                Text('${exercise.sets} sets x ${exercise.reps}',
                    style: const TextStyle(color: AppColors.subtitleGray)),
              ],
            ),
          ),
          Text('Rest: ${exercise.rest}',
              style: const TextStyle(color: AppColors.subtitleGray)),
        ],
      ),
    );
  }

  Widget _buildNutritionDetailsCard(Nutrition nutrition) {
    return Container(
      padding: const EdgeInsets.all(20.0),
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
        children: [
          _buildMealCard(
            icon: '🍽️',
            title: 'Breakfast',
            mealName: nutrition.meals['breakfast']!.name,
            items: nutrition.meals['breakfast']!.items,
            calories: nutrition.meals['breakfast']!.calories,
            protein: nutrition.meals['breakfast']!.protein,
          ),
          const Divider(height: 32),
          _buildMealCard(
            icon: '🥗',
            title: 'Lunch',
            mealName: nutrition.meals['lunch']!.name,
            items: nutrition.meals['lunch']!.items,
            calories: nutrition.meals['lunch']!.calories,
            protein: nutrition.meals['lunch']!.protein,
          ),
          const Divider(height: 32),
          _buildMealCard(
            icon: '🐟',
            title: 'Dinner',
            mealName: nutrition.meals['dinner']!.name,
            items: nutrition.meals['dinner']!.items,
            calories: nutrition.meals['dinner']!.calories,
            protein: nutrition.meals['dinner']!.protein,
          ),
          const Divider(height: 32),
          _buildMealCard(
            icon: '🥜',
            title: 'Snacks',
            mealName: nutrition.meals['snacks']!.name,
            items: nutrition.meals['snacks']!.items,
            calories: nutrition.meals['snacks']!.calories,
            protein: nutrition.meals['snacks']!.protein,
          ),
          const Divider(height: 32),
          _buildHydrationCard(nutrition.dailyWater),
        ],
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
      child: const Row(
        children: [
          Icon(Icons.apple, color: AppColors.secondaryBlue, size: 28),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'High Protein Focus', // Placeholder
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Personalized meal plan', // Placeholder
                style: TextStyle(color: AppColors.subtitleGray, fontSize: 14),
              ),
            ],
          ),
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

  Widget _buildMealCard({
    required String icon,
    required String title,
    required String mealName,
    required List<String> items,
    required int calories,
    required int protein,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mealName,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...items.map((item) => Text('· $item',
                  style: const TextStyle(color: AppColors.subtitleGray))),
              const SizedBox(height: 8),
              Text(
                '${calories} cal · ${protein}g protein',
                style: TextStyle(
                    color: AppColors.darkText.withOpacity(0.7),
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildHydrationCard(String dailyWater) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('💧', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text(
              'Hydration',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daily Hydration Goals',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...[
                '8-10 glasses of water',
                '1 cup green tea',
                'Electrolyte drink post-workout'
              ].map((item) => Text('· $item',
                  style: const TextStyle(color: AppColors.subtitleGray))),
              const SizedBox(height: 8),
              Text(
                'Target: $dailyWater daily',
                style: TextStyle(
                    color: AppColors.darkText.withOpacity(0.7),
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDailySummaryCard(Workout? workout, Nutrition? nutrition) {
    int totalCalories = 0;
    int totalProtein = 0;
    if (nutrition != null) {
      for (var meal in nutrition.meals.values) {
        totalCalories += meal.calories;
        totalProtein += meal.protein;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20.0),
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
          const Text(
            'Daily Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatItem('$totalCalories', 'Total Calories')),
              const SizedBox(width: 12),
              Expanded(child: _buildStatItem('${totalProtein}g', 'Total Protein')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatItem(workout?.duration ?? '0 minutes', 'Workout Duration')),
              const SizedBox(width: 12),
              Expanded(child: _buildStatItem(nutrition?.dailyWater ?? '0L', 'Hydration Goal')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppColors.subtitleGray, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
