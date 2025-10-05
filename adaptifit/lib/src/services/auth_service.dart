import 'package:adaptifit/src/models/user.dart';
import 'package:adaptifit/src/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final _secureStorage = const FlutterSecureStorage();
  User? _user;

  User? get user => _user;

  Future<void> tryAutoLogin() async {
    try {
      final user = await _apiService.getMyProfile();
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
      await _apiService.register(firstName, email, password);
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
    await _apiService.login(email, password);
    _user = await _apiService.getMyProfile();
    notifyListeners();
  }

  Future<void> changePassword(
      {required String currentPassword, required String newPassword}) async {
    try {
      await _apiService.changePassword(currentPassword, newPassword);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _secureStorage.delete(key: 'jwt_token');
    _user = null;
    notifyListeners();
  }
}