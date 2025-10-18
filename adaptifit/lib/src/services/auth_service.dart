import 'package:adaptifit/src/models/user.dart';
import 'package:adaptifit/src/providers/api_service_provider.dart';
import 'package:adaptifit/src/providers/user_provider.dart';
import 'package:adaptifit/src/providers/calendar_provider.dart';
import 'package:adaptifit/src/providers/plan_provider.dart';
import 'package:adaptifit/src/providers/nutrition_provider.dart';
import 'package:adaptifit/src/providers/today_plan_provider.dart';
import 'package:adaptifit/src/providers/weekly_progress_provider.dart';
import 'package:adaptifit/src/services/chat_cache_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService extends ChangeNotifier {
  final Ref _ref;
  final _secureStorage = const FlutterSecureStorage();
  User? _user;

  AuthService(this._ref);

  User? get user => _user;

  Future<void> tryAutoLogin() async {
    try {
      final user = await _ref.read(apiServiceProvider).getMyProfile();
      _user = user;
      notifyListeners();
    } catch (e) {
      // No token, or token invalid
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
  }) async {
    try {
      await _ref
          .read(apiServiceProvider)
          .register(firstName, email, password, password);
      await _loginAndSetUser(email, password);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _loginAndSetUser(email, password);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> _loginAndSetUser(String email, String password) async {
    await _ref.read(apiServiceProvider).login(email, password);
    _user = await _ref.read(apiServiceProvider).getMyProfile();

    // Invalidate providers to ensure they fetch fresh data with the new token
    _ref.invalidate(userProvider);
    _ref.invalidate(calendarEntriesProvider);
    _ref.invalidate(todayCalendarEntryProvider);
    _ref.invalidate(calendarEntryProvider);
    _ref.invalidate(plansProvider);
    _ref.invalidate(planWorkoutsProvider);
    _ref.invalidate(planNutritionProvider);
    _ref.invalidate(nutritionProvider);
    _ref.invalidate(todayPlanNotifierProvider);
    _ref.invalidate(weeklyProgressProvider);

    notifyListeners();
  }

  Future<void> changePassword(
      {required String currentPassword, required String newPassword}) async {
    try {
      await _ref
          .read(apiServiceProvider)
          .changePassword(currentPassword, newPassword);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    // Clear JWT token from secure storage
    await _secureStorage.delete(key: 'jwt_token');

    // Clear user data
    _user = null;

    // Invalidate all cached providers to clear old user data
    _ref.invalidate(userProvider);
    _ref.invalidate(calendarEntriesProvider);
    _ref.invalidate(todayCalendarEntryProvider);
    _ref.invalidate(calendarEntryProvider);
    _ref.invalidate(plansProvider);
    _ref.invalidate(planWorkoutsProvider);
    _ref.invalidate(planNutritionProvider);
    _ref.invalidate(nutritionProvider);
    _ref.invalidate(todayPlanNotifierProvider);
    _ref.invalidate(weeklyProgressProvider);

    // Clear chat cache
    ChatCacheService().clearCache();

    // Notify listeners
    notifyListeners();
  }
}
