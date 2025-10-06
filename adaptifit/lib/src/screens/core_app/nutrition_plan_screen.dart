import 'package:adaptifit/src/constants/app_colors.dart';
import 'package:adaptifit/src/models/nutrition.dart';
import 'package:adaptifit/src/providers/api_service_provider.dart';
import 'package:adaptifit/src/providers/progress_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NutritionPlanScreen extends ConsumerStatefulWidget {
  final Nutrition nutrition;

  const NutritionPlanScreen({super.key, required this.nutrition});

  @override
  ConsumerState<NutritionPlanScreen> createState() => _NutritionPlanScreenState();
}

class _NutritionPlanScreenState extends ConsumerState<NutritionPlanScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(nutritionProgressProvider.notifier).loadProgress(widget.nutrition.meals.keys.toList()));
  }

  int get totalMeals => widget.nutrition.meals.length;
  int get totalCompletedMeals => ref.watch(nutritionProgressProvider).values.where((isCompleted) => isCompleted).length;

  Future<void> _completeMeal(String mealKey, bool isCompleted) async {
    try {
      final newCompletedMeals = ref.read(nutritionProgressProvider).entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      await ref.read(apiServiceProvider).updateCalendarEntry(
        DateTime.now(),
        {
          'completed': false, // Assuming we are not completing the whole day
          'completedMeals': newCompletedMeals
        },
      );
    } catch (e) {
      debugPrint("Error completing meal: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sync progress.')),
        );
      }
    }
  }

  Future<void> _completeAllMeals() async {
    try {
      final date = DateTime.now();
      final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      await ref.read(apiServiceProvider).completeAllNutrition(dateString);
      if (mounted) {
        ref.read(nutritionProgressProvider.notifier).completeAll();
      }
    } catch (e) {
      debugPrint("Error completing all meals: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to complete all meals.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedMeals = ref.watch(nutritionProgressProvider);
    final nutrition = widget.nutrition;
    final meals = nutrition.meals;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.screenBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Nutrition Plan',
            style: const TextStyle(color: AppColors.darkText)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(nutrition.name,
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText)),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.local_fire_department,
                  size: 18, color: AppColors.primaryGreen),
              const SizedBox(width: 6),
              Text('${nutrition.calories} kcal',
                  style: const TextStyle(color: AppColors.darkText)),
              const SizedBox(width: 16),
              const Icon(Icons.water_drop,
                  size: 18, color: AppColors.primaryGreen),
              const SizedBox(width: 6),
              Text(nutrition.dailyWater,
                  style: const TextStyle(color: AppColors.darkText)),
            ]),
            const SizedBox(height: 16),
            _buildProgressCard(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _completeAllMeals,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text('Complete All Meals', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 16),
            const Text('Meals',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: AppColors.darkText)),
            const SizedBox(height: 12),
            ...meals.entries
                .map((entry) => _buildMealCard(entry.key, entry.value))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final progress = totalMeals == 0 ? 0.0 : totalCompletedMeals / totalMeals;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              spreadRadius: 2,
              blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Progress',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Text('$totalCompletedMeals/$totalMeals meals',
                  style: const TextStyle(color: AppColors.subtitleGray)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.lightGrey2,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMealCard(String mealKey, Meal meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              spreadRadius: 2,
              blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(meal.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.darkText)),
              _buildMealCheckbox(mealKey),
            ],
          ),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.local_fire_department_outlined,
                size: 16, color: AppColors.subtitleGray),
            const SizedBox(width: 6),
            Text('${meal.calories} kcal',
                style: const TextStyle(color: AppColors.subtitleGray)),
            const SizedBox(width: 12),
            const Icon(Icons.bolt, size: 16, color: AppColors.subtitleGray),
            const SizedBox(width: 6),
            Text('${meal.protein}g protein',
                style: const TextStyle(color: AppColors.subtitleGray)),
          ]),
          const SizedBox(height: 10),
          const Text('Items:', style: TextStyle(color: AppColors.darkText)),
          const SizedBox(height: 4),
          ...meal.items.map((item) => Text('- $item',
              style: const TextStyle(color: AppColors.subtitleGray))),
        ],
      ),
    );
  }

  Widget _buildMealCheckbox(String mealKey) {
    final completedMeals = ref.watch(nutritionProgressProvider);
    final isChecked = completedMeals[mealKey] ?? false;
    return InkWell(
      onTap: () {
        final newIsChecked = !isChecked;
        ref.read(nutritionProgressProvider.notifier).updateProgress(mealKey, newIsChecked);
        _completeMeal(mealKey, newIsChecked);
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.timestampGray),
          color: isChecked ? AppColors.primaryGreen : Colors.white,
        ),
        child: isChecked
            ? const Icon(Icons.check, size: 18, color: Colors.white)
            : null,
      ),
    );
  }
}