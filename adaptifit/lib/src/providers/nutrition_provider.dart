
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/nutrition.dart';
import '../services/api_service.dart';
import 'api_service_provider.dart';

part 'nutrition_provider.g.dart';

@Riverpod(keepAlive: true)
Future<Nutrition> nutrition(NutritionRef ref, String nutritionId) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getNutritionById(nutritionId);
}
