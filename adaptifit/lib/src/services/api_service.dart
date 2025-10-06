import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/user.dart';
import '../models/plan.dart';
import '../models/workout.dart';
import '../models/nutrition.dart';
import '../models/calendar_entry.dart';

class ApiService {
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
  final _secureStorage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Part 1: Authentication
  Future<String> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      final token = responseBody['data']['token'];
      await _secureStorage.write(key: 'jwt_token', value: token);
      return token;
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final token = responseBody['data']['token'];
      await _secureStorage.write(key: 'jwt_token', value: token);
      return token;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/change-password'),
      headers: await _getHeaders(),
      body:
          jsonEncode({'oldPassword': oldPassword, 'newPassword': newPassword}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to change password: ${response.body}');
    }
  }

  Future<void> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send password reset email: ${response.body}');
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token, 'newPassword': newPassword}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to reset password: ${response.body}');
    }
  }

  // Part 2: User Data
  Future<User> getMyProfile() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/users/me'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user profile: ${response.body}');
    }
  }

  Future<User> submitOnboarding(Map<String, dynamic> onboardingAnswers) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/users/onboarding'),
      headers: await _getHeaders(),
      body: jsonEncode({'onboardingAnswers': onboardingAnswers}),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to submit onboarding answers: ${response.body}');
    }
  }

  // Part 3: Plans, Workouts, and Nutrition
  Future<List<Plan>> getMyPlans() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/plans'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> plansJson = jsonDecode(response.body);
      return plansJson.map((json) => Plan.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load plans: ${response.body}');
    }
  }

  Future<List<Workout>> getWorkoutsForPlan(String planId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/workouts/plan/$planId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> workoutsJson = jsonDecode(response.body);
      return workoutsJson.map((json) => Workout.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load workouts: ${response.body}');
    }
  }

  Future<List<Nutrition>> getNutritionsForPlan(String planId) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return [ 
      Nutrition(
        id: 'mock_id',
        name: 'Mock Nutrition',
        calories: 2000,
        meals: {},
        dailyWater: '2L',
      )
    ];
  }

  Future<Nutrition> getNutritionForPlan(String planId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/nutrition/plan/$planId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return Nutrition.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load nutrition: ${response.body}');
    }
  }

  Future<Nutrition> getNutritionById(String nutritionId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/nutrition/${nutritionId.trim()}'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return Nutrition.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load nutrition: ${response.body}');
    }
  }

  Future<void> regeneratePlan() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/plans/regenerate'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to trigger plan regeneration: ${response.body}');
    }
  }

  // Part 4: Calendar
  Future<CalendarEntry?> getCalendarEntry(DateTime date) async {
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final response = await http.get(
      Uri.parse('$_baseUrl/api/calendar/$dateString'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty) return null;
      final dynamic responseBody = jsonDecode(response.body);
      if (responseBody is Map<String, dynamic> && responseBody.containsKey('data')) {
        return CalendarEntry.fromJson(responseBody['data']);
      } else {
        // If the response is not in the expected format, maybe it's the entry itself
        return CalendarEntry.fromJson(responseBody);
      }
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load calendar entry: ${response.body}');
    }
  }

  Future<CalendarEntry> updateCalendarEntry(
      DateTime date, Map<String, dynamic> data) async {
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final response = await http.put(
      Uri.parse('$_baseUrl/api/calendar/$dateString'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return CalendarEntry.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to update calendar entry: ${response.body}');
    }
  }

  Future<CalendarEntry> completeWorkout(DateTime date, {required bool completed}) async {
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final response = await http.put(
      Uri.parse('$_baseUrl/api/calendar/$dateString/workout/complete'),
      headers: await _getHeaders(),
      body: jsonEncode({'workoutCompleted': completed}),
    );

    if (response.statusCode == 200) {
      return CalendarEntry.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to complete workout: ${response.body}');
    }
  }

  Future<CalendarEntry> completeNutrition(DateTime date, String nutritionId) async {
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final response = await http.put(
      Uri.parse('$_baseUrl/api/calendar/$dateString/nutrition/$nutritionId/complete'),
      headers: await _getHeaders(),
      body: jsonEncode({'completed': true}),
    );

    if (response.statusCode == 200) {
      return CalendarEntry.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to complete nutrition: ${response.body}');
    }
  }

  Future<void> updateWorkoutSetProgress(String workoutId, int exerciseIndex, int completedSets, DateTime date) async {
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final response = await http.put(
      Uri.parse('$_baseUrl/api/workouts/$workoutId/exercises/$exerciseIndex/sets'),
      headers: await _getHeaders(),
      body: jsonEncode({'completedSets': completedSets, 'date': dateString}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update workout progress: ${response.body}');
    }
  }



  Future<List<CalendarEntry>> getCalendarEntries() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/calendar/'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      print(response.body);
      final dynamic responseBody = jsonDecode(response.body);
      if (responseBody is Map<String, dynamic> && responseBody.containsKey('data')) {
        final List<dynamic> entriesJson = responseBody['data'];
        return entriesJson.map((json) => CalendarEntry.fromJson(json)).toList();
      } else {
        throw Exception('Unexpected response format for calendar entries');
      }
    } else {
      throw Exception('Failed to load calendar entries: ${response.body}');
    }
  }
}
