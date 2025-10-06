import 'package:adaptifit/src/models/nutrition.dart';
import 'package:adaptifit/src/models/workout.dart';
import 'package:adaptifit/src/providers/plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adaptifit/src/constants/app_colors.dart';

class WorkoutOverviewScreen extends ConsumerWidget {
  final Workout workout;

  const WorkoutOverviewScreen({
    Key? key,
    required this.workout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutritionValue = ref.watch(planNutritionProvider(workout.planId));

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(context, workout),
                const SizedBox(height: 24),
                _buildInfoBanner(),
                const SizedBox(height: 16),
                _buildWorkoutCard(workout),
                const SizedBox(height: 16),
                _buildNutritionHeader(),
                const SizedBox(height: 16),
                nutritionValue.when(
                  data: (nutrition) => _buildNutritionDetailsCard(nutrition),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
                const SizedBox(height: 16),
                _buildDailySummaryCard(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyledContainer(
      {required Widget child, Color color = AppColors.white}) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildHeader(BuildContext context, Workout workout) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workout.day,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const Text(
              '', // No date info in workout object
              style: TextStyle(fontSize: 16, color: AppColors.subtitleGray),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return _buildStyledContainer(
      color: AppColors.secondaryBlue.withOpacity(0.1),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.secondaryBlue),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'This is a preview of your upcoming plan. Completion options will be available on the day of your workout.',
              style: TextStyle(color: AppColors.secondaryBlue, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(Workout workout) {
    return _buildStyledContainer(
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined,
                  color: AppColors.primaryGreen, size: 28), // Example Icon
              const SizedBox(width: 12),
              const Text('💪', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '🕒 ${workout.duration}',
                      style: const TextStyle(
                          color: AppColors.subtitleGray, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: workout.exercises.asMap().entries.map((entry) {
              final index = entry.key;
              final exercise = entry.value;
              return Column(
                children: [
                  if (index > 0)
                    const Divider(color: AppColors.lightGrey2, height: 24),
                  _buildExerciseItem(exercise),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(Exercise exercise) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${exercise.sets} sets x ${exercise.reps} reps',
              style: const TextStyle(
                color: AppColors.subtitleGray,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Text(
          'Rest: ${exercise.rest}',
          style: const TextStyle(
            color: AppColors.subtitleGray,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionHeader() {
    return _buildStyledContainer(
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

  Widget _buildNutritionDetailsCard(Nutrition? nutrition) {
    if (nutrition == null) {
      return const Center(child: Text('Nutrition plan not found.'));
    }

    final breakfast = nutrition.meals['breakfast'];
    final lunch = nutrition.meals['lunch'];
    final dinner = nutrition.meals['dinner'];
    final snacks = nutrition.meals['snacks'];

    return _buildStyledContainer(
      child: Column(
        children: [
          _buildMealCard(
            icon: '🍽️',
            title: 'Breakfast',
            mealName: breakfast?.name ?? 'Breakfast',
            items: breakfast?.items ?? const [],
            calories: breakfast?.calories ?? 0,
            protein: breakfast?.protein ?? 0,
          ),
          const Divider(height: 32),
          _buildMealCard(
            icon: '🥗',
            title: 'Lunch',
            mealName: lunch?.name ?? 'Lunch',
            items: lunch?.items ?? const [],
            calories: lunch?.calories ?? 0,
            protein: lunch?.protein ?? 0,
          ),
          const Divider(height: 32),
          _buildMealCard(
            icon: '🐟',
            title: 'Dinner',
            mealName: dinner?.name ?? 'Dinner',
            items: dinner?.items ?? const [],
            calories: dinner?.calories ?? 0,
            protein: dinner?.protein ?? 0,
          ),
          const Divider(height: 32),
          _buildMealCard(
            icon: '🥜',
            title: 'Snacks',
            mealName: snacks?.name ?? 'Snacks',
            items: snacks?.items ?? const [],
            calories: snacks?.calories ?? 0,
            protein: snacks?.protein ?? 0,
          ),
          const Divider(height: 32),
          _buildHydrationCard(nutrition.dailyWater),
        ],
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

  Widget _buildDailySummaryCard() {
    // TODO: Pass real summary data here
    return _buildStyledContainer(
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
              Expanded(child: _buildStatItem('1,505', 'Total Calories')),
              const SizedBox(width: 12),
              Expanded(child: _buildStatItem('114g', 'Total Protein')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatItem('50 minutes', 'Workout Duration')),
              const SizedBox(width: 12),
              Expanded(child: _buildStatItem('2.5L', 'Hydration Goal')),
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
