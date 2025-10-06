import 'package:adaptifit/src/models/nutrition.dart';
import 'package:adaptifit/src/providers/plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adaptifit/src/constants/app_colors.dart';

class NutritionOverviewScreen extends ConsumerWidget {
  final String planId;

  const NutritionOverviewScreen({Key? key, required this.planId})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutritionValue = ref.watch(planNutritionProvider(planId));

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        title: const Text('Nutrition Overview'),
      ),
      body: nutritionValue.when(
        data: (nutrition) => nutrition == null
            ? const Center(child: Text('Nutrition plan not found'))
            : SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildNutritionHeader(nutrition),
              const SizedBox(height: 16),
              _buildNutritionDetailsCard(nutrition),
              const SizedBox(height: 16),
              _buildDailySummaryCard(nutrition),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text("Error: $error")),
      ),
    );
  }

  Widget _buildNutritionHeader(Nutrition nutrition) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nutrition.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Personalized meal plan',
                style: TextStyle(color: AppColors.subtitleGray, fontSize: 14),
              ),
            ],
          ),
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
            Text('💧', style: const TextStyle(fontSize: 20)),
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

  Widget _buildDailySummaryCard(Nutrition? nutrition) {
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
              Expanded(child: _buildStatItem('0 minutes', 'Workout Duration')),
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
