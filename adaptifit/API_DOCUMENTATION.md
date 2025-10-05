
# ADAPTIFIT Backend API Documentation

This document provides a complete reference for all the API endpoints available in the Adaptifit backend.

## Authentication Routes (`routes/auth.js`)

### `POST /api/auth/register`

Registers a new user and returns a JWT token.

**Authentication:** None.

**Request Body:**

```json
{
  "name": "Test User",
  "email": "test@example.com",
  "password": "password123"
}
```

**Response (Success):**

```json
{
  "success": true,
  "data": {
    "token": "YOUR_JWT_TOKEN"
  }
}
```

<br>

### `POST /api/auth/login`

Authenticates an existing user and returns a JWT token.

**Authentication:** None.

**Request Body:**

```json
{
  "email": "test@example.com",
  "password": "password123"
}
```

**Response (Success):**

```json
{
  "success": true,
  "data": {
    "token": "YOUR_JWT_TOKEN"
  }
}
```

<br>

### `POST /api/auth/change-password`

Allows a logged-in user to change their password.

**Authentication:** JWT Token required.

**Request Body:**

```json
{
  "oldPassword": "password123",
  "newPassword": "newpassword456"
}
```

**Response (Success):**

```json
{
  "success": true,
  "data": {
    "msg": "Password updated successfully"
  }
}
```

-----

## User Routes (`routes/users.js`)

### `GET /api/users/me`

Gets the profile of the currently logged-in user.

**Authentication:** JWT Token required.

**Response:**

Returns the user object (without the password).

<br>

### `PUT /api/users/onboarding`

Updates the user's onboarding answers and sets `onboardingCompleted` to `true`.

**Authentication:** JWT Token required.

**Request Body:**

```json
{
  "onboardingAnswers": {
    "fitnessGoal": ["Build muscle"],
    "experienceLevel": "Intermediate",
    "injuries": "None",
    "workoutFrequency": "4 days",
    "planDuration": "30",
    "activityLevel": "Moderately Active",
    "diet": {
      "style": "Balanced",
      "macros": "2500 kcal",
      "custom": ""
    },
    "timePerSession": "60",
    "gymAccess": "Gym",
    "workoutSplit": "Upper/Lower"
  }
}
```

**Response:**

Returns the updated user object.

-----

## Plan Routes (`routes/plans.js`)

### `POST /api/plans`

Creates a new workout plan. Intended for use by an n8n webhook.

**Authentication:** API Key (`x-api-key`) required.

**Request Body:**

```json
{
  "userId": "{{userId}}",
  "planName": "Strength Training Basics",
  "duration": 12,
  "difficulty": "Beginner",
  "startDate": "2024-01-01T00:00:00.000Z",
  "endDate": "2024-03-25T00:00:00.000Z"
}
```

**Response:**

Returns the newly created plan object.

<br>

### `GET /api/plans`

Gets all plans for the logged-in user.

**Authentication:** JWT Token required.

**Response:**

Returns an array of plan objects.

<br>

### `POST /api/plans/regenerate`

Triggers the n8n webhook to regenerate a plan for the user based on their saved onboarding answers.

**Authentication:** JWT Token required.

**Response:**

Returns the response from the n8n webhook.

-----

## Workout Routes (`routes/workouts.js`)

### `POST /api/workouts`

Creates a new workout. Intended for use by an n8n webhook.

**Authentication:** API Key (`x-api-key`) required.

**Request Body:**

```json
{
  "planId": "{{planId}}",
  "name": "Full Body Workout A",
  "day": "Monday",
  "duration": "60 minutes",
  "targetMuscles": ["Chest", "Back", "Legs"],
  "exercises": [
    {
      "name": "Squats",
      "sets": 3,
      "reps": "8-12",
      "rest": "60s",
      "instructions": "Keep your back straight and go as low as you can."
    },
    {
      "name": "Bench Press",
      "sets": 3,
      "reps": "8-12",
      "rest": "60s",
      "instructions": "Lower the bar to your chest and push back up."
    }
  ]
}
```

**Response:**

Returns the newly created workout object.

<br>

### `GET /api/workouts/plan/:planId`

Gets all workouts associated with a specific plan.

**Authentication:** JWT Token required.

**URL Parameters:**

  * `planId`: The ID of the plan.

**Response:**

Returns an array of workout objects.

-----

## Nutrition Routes (`routes/nutrition.js`)

### `POST /api/nutrition`

Creates a new nutrition plan. Intended for use by an n8n webhook.

**Authentication:** API Key (`x-api-key`) required.

**Request Body:**

```json
{
  "planId": "{{planId}}",
  "name": "High Protein Diet",
  "dailyCalories": 2500,
  "dailyWater": "3L",
  "macros": {
    "carbs": "250g",
    "fats": "80g",
    "protein": "200g"
  },
  "meals": {
    "breakfast": {
      "name": "Oats and Eggs",
      "items": ["1 cup oats", "4 whole eggs"],
      "calories": 600,
      "protein": 40
    },
    "lunch": {
      "name": "Chicken and Rice",
      "items": ["200g chicken breast", "1 cup brown rice"],
      "calories": 700,
      "protein": 60
    },
    "dinner": {
      "name": "Salmon and Veggies",
      "items": ["200g salmon", "1 cup mixed vegetables"],
      "calories": 600,
      "protein": 50
    },
    "snacks": {
      "name": "Protein Shake",
      "items": ["1 scoop whey protein"],
      "calories": 150,
      "protein": 25
    }
  }
}
```

**Response:**

Returns the newly created nutrition plan object.

<br>

### `GET /api/nutrition/plan/:planId`

Gets the nutrition plan for a specific plan.

**Authentication:** JWT Token required.

**URL Parameters:**

  * `planId`: The ID of the plan.

**Response:**

Returns the nutrition plan object.

-----

## Calendar Routes (`routes/calendar.js`)

### `POST /api/calendar`

Creates a new calendar entry. Intended for use by an n8n webhook.

**Authentication:** API Key (`x-api-key`) required.

**Request Body:**

```json
{
  "userId": "{{userId}}",
  "date": "2024-01-01",
  "planId": "{{planId}}",
  "workoutId": "{{workoutId}}",
  "nutritionIds": ["{{nutritionId}}"]
}
```

**Response:**

Returns the newly created calendar entry object.

<br>

### `GET /api/calendar/:date`

Gets the calendar entry for a specific date (format: YYYY-MM-DD).

**Authentication:** JWT Token required.

**URL Parameters:**

  * `date`: The date of the entry to retrieve.

**Response:**

Returns the calendar entry object for the specified date.

<br>

### `PUT /api/calendar/:date`

Marks a calendar entry for a specific date as complete or incomplete.

**Authentication:** JWT Token required.

**URL Parameters:**

  * `date`: The date of the entry to update.

**Request Body:**

```json
{
  "completed": true
}
```

**Response:**

Returns the updated calendar entry object.

-----

## Chat Routes (`routes/chat.js`)

### `POST /api/chat`

Posts a message from the user, triggers a webhook to get an AI response, and saves both messages to the database.

**Authentication:** JWT Token required.

**Request Body:**

```json
{
  "text": "What should I eat before a workout?"
}
```

**Response (Success):**

```json
{
  "success": true,
  "data": {
    "userId": "60d5f1f77e3a1f001f8e3b8b",
    "text": "For a pre-workout meal, focus on carbohydrates and a moderate amount of protein.",
    "sender": "ai",
    "_id": "60d5f20c7e3a1f001f8e3b8d",
    "timestamp": "2024-10-04T10:00:00.000Z"
  }
}
```

<br>

### `GET /api/chat`

Gets the entire chat history for the logged-in user.

**Authentication:** JWT Token required.

**Response:**

Returns an array of all chat message objects for the user, sorted by timestamp.



_____
Instructions for Flutter Chat Implementation
Hello! We have updated the backend with a new API for the "Ask the Coach" chat feature. This new system ensures all chat messages are saved in our main database, providing a persistent chat history for users. Please replace the existing Firebase and direct n8n webhook implementation with the following API-driven approach.

API Overview
The new chat functionality is handled by two endpoints:

GET /api/chat

Purpose: Fetches the entire chat history for the logged-in user.
When to use: Call this once when the user opens the chat screen to load all previous messages.
POST /api/chat

Purpose: Sends a new user message and gets the AI's reply.
When to use: Call this every time the user sends a message.
Request Body: { "text": "The user's message" }
Response: The backend handles saving both the user and AI messages and returns only the new AI message object.
Authentication: All requests to these endpoints must include the user's JWT token in the header: Authorization: Bearer <YOUR_JWT_TOKEN>

Data Model: Chat Message
All chat messages, both from the user and the AI, will have this structure:

{
  "_id": "messageId",
  "userId": "userId",
  "text": "The message content.",
  "sender": "user", // or "ai"
  "timestamp": "2024-10-04T10:00:00.000Z"
}
Flutter Implementation Guide
Here’s how to integrate this into the Flutter app.

Step 1: Create a ChatApiService
Create a new service to handle the API calls. This will replace the askAiCoach logic in your old N8nService.

import 'dart:convert';
import 'package:http/http.dart' as http;

// Define your ChatMessage model
class ChatMessage {
  final String id;
  final String text;
  final String sender;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'],
      text: json['text'],
      sender: json['sender'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class ChatApiService {
  final String _baseUrl = 'YOUR_API_BASE_URL'; // e.g., https://api.adaptifit.app
  final String _token; // Your JWT token

  ChatApiService(this._token);

  // 1. Fetches the full chat history
  Future<List<ChatMessage>> getChatHistory() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/chat'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> messagesJson = jsonDecode(response.body);
      return messagesJson.map((json) => ChatMessage.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chat history');
    }
  }

  // 2. Sends a message and gets the AI's reply
  Future<ChatMessage> sendMessage(String text) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/chat'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      // The new AI message is in the 'data' field
      return ChatMessage.fromJson(responseBody['data']);
    } else {
      throw Exception('Failed to send message');
    }
  }
}
Step 2: Update Your Chat Screen UI
In your chat screen widget (e.g., ChatScreen.dart), use this new service.

State: Maintain a list of ChatMessage objects: List<ChatMessage> messages = [];
Load History: When the screen initializes (initState), call chatApiService.getChatHistory() to populate the messages list.
Send Message:
When the user taps the send button:
Create a temporary user ChatMessage object and add it to your messages list to update the UI instantly.
Call chatApiService.sendMessage(text).
When you get the response (which is the AI's ChatMessage), add that object to the messages list and update the UI.
Example UI Logic:

// Inside your ChatScreen's state class

late final ChatApiService _chatApiService;
List<ChatMessage> _messages = [];
bool _isLoading = true;

void initState() {
  super.initState();
  // Assume you get the token from your auth provider
  final String userToken = // ... get user token ...
  _chatApiService = ChatApiService(userToken);
  _loadHistory();
}

void _loadHistory() async {
  try {
    final history = await _chatApiService.getChatHistory();
    setState(() {
      _messages = history;
      _isLoading = false;
    });
  } catch (e) {
    // Handle error
  }
}

void _handleSendPressed(String text) async {
  // 1. Add user message to UI immediately
  final userMessage = ChatMessage(
    id: DateTime.now().toString(), // Temporary ID
    text: text,
    sender: 'user',
    timestamp: DateTime.now(),
  );
  setState(() {
    _messages.add(userMessage);
  });

  // 2. Send to backend and get AI reply
  try {
    final aiMessage = await _chatApiService.sendMessage(text);
    setState(() {
      _messages.add(aiMessage);
    });
  } catch (e) {
    // Handle error, maybe show an error message in the chat
  }
}
Step 3: Remove Old Code
You can now delete the askAiCoach method from N8nService.
Remove any code that directly interacts with a Firebase/Firestore collection for chat messages. The new ChatApiService is the single source of truth.
This approach ensures a responsive UI, a persistent chat history, and a clean separation of concerns.

0 context items
