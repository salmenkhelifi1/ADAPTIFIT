
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/api_service.dart';

part 'api_service_provider.g.dart';

@riverpod
ApiService apiService(ApiServiceRef ref) {
  return ApiService();
}
