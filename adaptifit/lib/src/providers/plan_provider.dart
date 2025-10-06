import 'package:adaptifit/src/models/nutrition.dart';
import 'package:adaptifit/src/models/plan.dart';
import 'package:adaptifit/src/models/workout.dart';
import 'package:adaptifit/src/providers/api_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final myPlansProvider = FutureProvider<List<Plan>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getMyPlans();
});

final workoutsForPlanProvider =
    FutureProvider.family<List<Workout>, String>((ref, planId) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getWorkoutsForPlan(planId);
});

final planNutritionProvider =
    FutureProvider.family<Nutrition?, String>((ref, planId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final nutrition = await apiService.getNutritionForPlan(planId);
    return nutrition;
  } catch (_) {
    return null;
  }
});
