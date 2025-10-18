import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user.dart';
import 'api_service_provider.dart';

part 'user_provider.g.dart';

@Riverpod(keepAlive: true)
Future<User> user(UserRef ref) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getMyProfile();
}
