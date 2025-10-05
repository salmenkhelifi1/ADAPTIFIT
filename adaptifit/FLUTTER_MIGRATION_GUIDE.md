
# Flutter App Migration Guide: From Firebase to Adaptifit Backend API

Hello! This guide provides comprehensive instructions for migrating the Adaptifit Flutter app from its current Firebase backend to the new, centralized Express.js API.

**Primary Goal:** Replace all Firebase-dependent code (Authentication, Firestore, and Firebase Functions) with calls to the new API, while keeping the UI and user experience as consistent as possible.

---

## **Core Principles**

1.  **Centralized API Service:** Create a single `ApiService.dart` file (or multiple focused services like `AuthService`, `PlanService`, etc.) to manage all HTTP requests to the backend. This service will be responsible for handling authentication tokens and parsing JSON data.
2.  **Authentication Flow:** The app will now use JWT (JSON Web Tokens) for authentication. After a user logs in, a token is issued. This token must be stored securely on the device (e.g., using `flutter_secure_storage`) and sent in the `Authorization` header for all protected API calls.
3.  **Data Fetching:** Firebase's real-time streams (`.snapshots()`) will be replaced by standard `Future`-based API calls. This means the UI will not update automatically in real-time when database content changes. The app must adopt a manual refresh pattern (e.g., "pull-to-refresh" on lists or re-fetching data in `initState`).

---

## **Part 1: Authentication (`/api/auth`)**

This section replaces `firebase_auth`.

### **1.1. Registering a New User**

*   **Endpoint:** `POST /api/auth/register`
*   **Replaces:** `FirebaseAuth.instance.createUserWithEmailAndPassword()`

**Implementation:**

```dart
// In your AuthService or ApiService
Future<String> register(String name, String email, String password) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/api/auth/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'name': name, 'email': email, 'password': password}),
  );

  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    // The token is in responseBody['data']['token']
    final token = responseBody['data']['token'];
    // **ACTION:** Store this token securely
    await secureStorage.write(key: 'jwt_token', value: token);
    return token;
  } else {
    throw Exception('Failed to register');
  }
}
```

### **1.2. Logging In**

*   **Endpoint:** `POST /api/auth/login`
*   **Replaces:** `FirebaseAuth.instance.signInWithEmailAndPassword()`

**Implementation:**

```dart
// In your AuthService or ApiService
Future<String> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/api/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );

  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    final token = responseBody['data']['token'];
    // **ACTION:** Store this token securely
    await secureStorage.write(key: 'jwt_token', value: token);
    return token;
  } else {
    throw Exception('Failed to login');
  }
}
```

### **1.3. Changing Password**

*   **Endpoint:** `POST /api/auth/change-password`
*   **Replaces:** `User.updatePassword()`

**Implementation:**

```dart
// In your AuthService or ApiService
Future<void> changePassword(String oldPassword, String newPassword) async {
  final token = await secureStorage.read(key: 'jwt_token');
  final response = await http.post(
    Uri.parse('$_baseUrl/api/auth/change-password'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'oldPassword': oldPassword, 'newPassword': newPassword}),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to change password');
  }
}
```

---

## **Part 2: User Data (`/api/users`)**

This section replaces reading and writing user documents in Firestore.

### **2.1. Getting User Profile**

*   **Endpoint:** `GET /api/users/me`
*   **Replaces:** `FirebaseFirestore.instance.collection('users').doc(userId).get()`

**Implementation:**

```dart
// In your ApiService
Future<User> getMyProfile() async {
  final token = await secureStorage.read(key: 'jwt_token');
  final response = await http.get(
    Uri.parse('$_baseUrl/api/users/me'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load user profile');
  }
}
```

### **2.2. Submitting Onboarding Answers**

*   **Endpoint:** `PUT /api/users/onboarding`
*   **Replaces:** `FirebaseFirestore.instance.collection('users').doc(userId).update({'onboardingAnswers': ...})`

**Implementation:**

```dart
// In your ApiService
Future<User> submitOnboarding(Map<String, dynamic> onboardingAnswers) async {
  final token = await secureStorage.read(key: 'jwt_token');
  final response = await http.put(
    Uri.parse('$_baseUrl/api/users/onboarding'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'onboardingAnswers': onboardingAnswers}),
  );

  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to submit onboarding answers');
  }
}
```

---

## **Part 3: Plans, Workouts, and Nutrition**

This section replaces reading from Firestore collections like `plans`, `workouts`, and `nutrition`.

### **3.1. Fetching User Plans**

*   **Endpoint:** `GET /api/plans`
*   **Replaces:** `FirebaseFirestore.instance.collection('plans').where('userId', isEqualTo: userId).get()`

**Implementation:**

```dart
// In your ApiService
Future<List<Plan>> getMyPlans() async {
  final token = await secureStorage.read(key: 'jwt_token');
  final response = await http.get(
    Uri.parse('$_baseUrl/api/plans'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final List<dynamic> plansJson = jsonDecode(response.body);
    return plansJson.map((json) => Plan.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load plans');
  }
}
```

### **3.2. Fetching Workouts for a Plan**

*   **Endpoint:** `GET /api/workouts/plan/:planId`
*   **Replaces:** `FirebaseFirestore.instance.collection('plans').doc(planId).collection('workouts').get()`

**Implementation:**

```dart
// In your ApiService
Future<List<Workout>> getWorkoutsForPlan(String planId) async {
  final token = await secureStorage.read(key: 'jwt_token');
  final response = await http.get(
    Uri.parse('$_baseUrl/api/workouts/plan/$planId'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final List<dynamic> workoutsJson = jsonDecode(response.body);
    return workoutsJson.map((json) => Workout.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load workouts');
  }
}
```

### **3.3. Fetching Nutrition for a Plan**

*   **Endpoint:** `GET /api/nutrition/plan/:planId`
*   **Replaces:** `FirebaseFirestore.instance.collection('plans').doc(planId).collection('nutrition').get()`

**Implementation:**

```dart
// In your ApiService
Future<Nutrition> getNutritionForPlan(String planId) async {
  final token = await secureStorage.read(key: 'jwt_token');
  final response = await http.get(
    Uri.parse('$_baseUrl/api/nutrition/plan/$planId'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    return Nutrition.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load nutrition');
  }
}
```

### **3.4. Regenerating a Plan**

*   **Endpoint:** `POST /api/plans/regenerate`
*   **Replaces:** Likely a call to a Firebase Cloud Function.

**Implementation:**

```dart
// In your ApiService
Future<void> regeneratePlan() async {
  final token = await secureStorage.read(key: 'jwt_token');
  final response = await http.post(
    Uri.parse('$_baseUrl/api/plans/regenerate'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode != 200) {
    // The webhook might take time. The response here might just be an acknowledgement.
    // Clarify with backend dev if we need to handle a long-polling response.
    throw Exception('Failed to trigger plan regeneration');
  }
  // **Note:** This likely triggers a background job. The UI should show a loading state
  // and then refresh the plan data after a short delay or via a notification.
}
```

---

## **Part 4: Calendar (`/api/calendar`)**

### **4.1. Getting a Calendar Entry**

*   **Endpoint:** `GET /api/calendar/:date` (e.g., `/api/calendar/2025-10-04`)
*   **Replaces:** `FirebaseFirestore.instance.collection('calendar').doc(dateString).get()`

**Implementation:**

```dart
// In your ApiService
Future<CalendarEntry?> getCalendarEntry(DateTime date) async {
  final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  final token = await secureStorage.read(key: 'jwt_token');
  final response = await http.get(
    Uri.parse('$_baseUrl/api/calendar/$dateString'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    // Handle case where an entry might not exist for a date
    if (response.body.isEmpty) return null;
    return CalendarEntry.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load calendar entry');
  }
}
```

### **4.2. Updating a Calendar Entry**

*   **Endpoint:** `PUT /api/calendar/:date`
*   **Replaces:** `FirebaseFirestore.instance.collection('calendar').doc(dateString).update({'completed': ...})`

**Implementation:**

```dart
// In your ApiService
Future<CalendarEntry> updateCalendarEntry(DateTime date, {required bool completed}) async {
  final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  final token = await secureStorage.read(key: 'jwt_token');
  final response = await http.put(
    Uri.parse('$_baseUrl/api/calendar/$dateString'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'completed': completed}),
  );

  if (response.statusCode == 200) {
    return CalendarEntry.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to update calendar entry');
  }
}
```

---

## **Part 5: Chat (`/api/chat`)**

This is covered in detail in the previous instructions. See `Instructions for Flutter Chat Implementation`.

---

