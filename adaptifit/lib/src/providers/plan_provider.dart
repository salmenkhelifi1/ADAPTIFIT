import 'package:adaptifit/src/models/nutrition.dart';
import 'package:adaptifit/src/models/plan.dart';
import 'package:adaptifit/src/models/workout.dart';
import 'package:adaptifit/src/providers/api_service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plan_provider.g.dart';

@Riverpod(keepAlive: true)
Future<List<Plan>> plans(PlansRef ref) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getMyPlans();
}

@riverpod
Future<List<Workout>> planWorkouts(PlanWorkoutsRef ref, String planId) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getWorkoutsForPlan(planId);
}

@riverpod
Future<Nutrition?> planNutrition(PlanNutritionRef ref, String planId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final nutrition = await apiService.getNutritionForPlan(planId);
    return nutrition;
  } catch (_) {
    return null;
  }
}