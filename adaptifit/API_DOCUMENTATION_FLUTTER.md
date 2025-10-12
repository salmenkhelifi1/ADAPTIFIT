# ADAPTIFIT Backend API Documentation

This document provides a complete reference for all the API endpoints available in the Adaptifit backend.

## Base URL

All API endpoints are prefixed with `/api`

## Authentication

Most endpoints require JWT authentication. Include the token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

Some endpoints require API Key authentication for n8n webhooks:

```
x-api-key: <your-api-key>
```

---

## Authentication Routes (`/api/auth`)

### `POST /api/auth/register`

Registers a new user and returns a JWT token.

**Authentication:** None

**Request Body:**

```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "confirmPassword": "password123"
}
```

**Response (Success):**

```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Response (Error):**

```json
{
  "errors": [
    {
      "msg": "User already exists",
      "param": "email",
      "location": "body"
    }
  ]
}
```

---

### `POST /api/auth/login`

Authenticates an existing user and returns a JWT token.

**Authentication:** None

**Request Body:**

```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response (Success):**

```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Response (Error):**

```json
{
  "msg": "Invalid credentials"
}
```

---

### `POST /api/auth/change-password`

Allows a logged-in user to change their password.

**Authentication:** JWT Token required

**Request Body:**

```json
{
  "oldPassword": "oldpassword123",
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

---

### `POST /api/auth/forgot-password`

Requests a password reset token for a user.

**Authentication:** None

**Request Body:**

```json
{
  "email": "john@example.com"
}
```

**Response (Success):**

```json
{
  "success": true,
  "message": "If an account with this email exists, a password reset link has been sent."
}
```

---

### `POST /api/auth/reset-password`

Resets a user's password using a valid reset token.

**Authentication:** None

**Request Body:**

```json
{
  "token": "reset-token-from-email",
  "newPassword": "newpassword123"
}
```

**Response (Success):**

```json
{
  "success": true,
  "message": "Password has been reset successfully."
}
```

**Response (Error):**

```json
{
  "success": false,
  "message": "Invalid or expired password reset token."
}
```

---

## User Routes (`/api/users`)

### `GET /api/users/me`

Gets the profile of the currently logged-in user.

**Authentication:** JWT Token required

**Response:**

```json
{
  "_id": "60d5f1f77e3a1f001f8e3b8b",
  "name": "John Doe",
  "email": "john@example.com",
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
  },
  "onboardingCompleted": true,
  "progress": {
    "completedWorkouts": 15,
    "currentStreak": 5,
    "longestStreak": 10,
    "lastWorkoutDate": "2024-12-03T00:00:00.000Z",
    "badges": ["first-workout"]
  },
  "createdAt": "2024-10-16T10:00:00.000Z",
  "updatedAt": "2024-12-03T10:30:00.000Z"
}
```

---

### `PUT /api/users/onboarding`

Updates the user's onboarding answers and sets `onboardingCompleted` to `true`.

**Authentication:** JWT Token required

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

```json
{
  "success": true,
  "message": "Onboarding answers updated successfully!",
  "data": {
    "_id": "60d5f1f77e3a1f001f8e3b8b",
    "name": "John Doe",
    "email": "john@example.com",
    "onboardingAnswers": { /* Updated onboarding answers */ },
    "onboardingCompleted": true,
    "createdAt": "2024-10-16T10:00:00.000Z",
    "updatedAt": "2024-12-03T10:30:00.000Z"
  }
}
```

---

### `GET /api/users/full-profile`

Gets all comprehensive data for the logged-in user, including profile, onboarding answers, calendar entries, chat history, plans, workouts, and nutrition information.

**Authentication:** JWT Token required

**Response:**

```json
{
    "success": true,
    "data": {
        "user": { /* User profile object */ },
        "calendarEntries": [ /* Array of calendar entry objects */ ],
        "chatHistory": [ /* Array of chat message objects */ ],
        "plans": [ /* Array of plan objects */ ],
        "workouts": [ /* Array of workout objects */ ],
        "nutritionEntries": [ /* Array of nutrition entry objects */ ]
    }
}
```

---

## Plan Routes (`/api/plans`)

### `POST /api/plans`

Creates a new workout plan. Intended for use by n8n webhook.

**Authentication:** API Key (`x-api-key`) required

**Request Body:**

```json
{
  "userId": "60d5f1f77e3a1f001f8e3b8b",
  "planName": "Strength Training Basics",
  "duration": 12,
  "difficulty": "Beginner",
  "startDate": "2024-01-01T00:00:00.000Z",
  "endDate": "2024-03-25T00:00:00.000Z"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "_id": "60d5f1f77e3a1f001f8e3b8c",
    "userId": "60d5f1f77e3a1f001f8e3b8b",
    "planName": "Strength Training Basics",
    "duration": 12,
    "difficulty": "Beginner",
    "startDate": "2024-01-01T00:00:00.000Z",
    "endDate": "2024-03-25T00:00:00.000Z",
    "createdAt": "2024-12-03T10:00:00.000Z",
    "updatedAt": "2024-12-03T10:00:00.000Z"
  }
}
```

---

### `GET /api/plans`

Gets all plans for the logged-in user.

**Authentication:** JWT Token required

**Response:**

```json
[
  {
    "_id": "60d5f1f77e3a1f001f8e3b8c",
    "userId": "60d5f1f77e3a1f001f8e3b8b",
    "planName": "Strength Training Basics",
    "duration": 12,
    "difficulty": "Beginner",
    "startDate": "2024-01-01T00:00:00.000Z",
    "endDate": "2024-03-25T00:00:00.000Z",
    "createdAt": "2024-12-03T10:00:00.000Z",
    "updatedAt": "2024-12-03T10:00:00.000Z"
  }
]
```

---

### `POST /api/plans/regenerate`

Triggers the n8n webhook to regenerate a plan for the user based on their saved onboarding answers.

**Authentication:** JWT Token required

**Response:**

```json
{ /* Response from n8n webhook */ }
```

---

## Workout Routes (`/api/workouts`)

### `POST /api/workouts`

Creates a new workout. Intended for use by n8n webhook.

**Authentication:** API Key (`x-api-key`) required

**Request Body:**

```json
{
  "planId": "60d5f1f77e3a1f001f8e3b8c",
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

```json
{
  "success": true,
  "data": {
    "_id": "60d5f1f77e3a1f001f8e3b8d",
    "planId": "60d5f1f77e3a1f001f8e3b8c",
    "name": "Full Body Workout A",
    "day": "Monday",
    "duration": "60 minutes",
    "targetMuscles": ["Chest", "Back", "Legs"],
    "exercises": [ /* Array of exercise objects */ ],
    "createdAt": "2024-12-03T10:00:00.000Z",
    "updatedAt": "2024-12-03T10:00:00.000Z"
  }
}
```

---

### `GET /api/workouts/plan/:planId`

Gets all workouts associated with a specific plan.

**Authentication:** JWT Token required

**URL Parameters:**

* `planId`: The ID of the plan

**Response:**

```json
[
  {
    "_id": "60d5f1f77e3a1f001f8e3b8d",
    "planId": "60d5f1f77e3a1f001f8e3b8c",
    "name": "Full Body Workout A",
    "day": "Monday",
    "duration": "60 minutes",
    "targetMuscles": ["Chest", "Back", "Legs"],
    "exercises": [ /* Array of exercise objects */ ]
  }
]
```

---

### `GET /api/workouts/:id`

Gets a workout by its ID.

**Authentication:** JWT Token required

**URL Parameters:**

* `id`: The ID of the workout

**Response:**

```json
{
  "_id": "60d5f1f77e3a1f001f8e3b8d",
  "planId": "60d5f1f77e3a1f001f8e3b8c",
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
    }
  ]
}
```

---

### `POST /api/workouts/:workoutId/complete`

Marks a workout as complete and updates user progress (completed workouts, current streak, longest streak, last workout date, and badges).

**Authentication:** JWT Token required

**URL Parameters:**

* `workoutId`: The ID of the workout to mark as complete

**Response:**

```json
{
  "success": true,
  "data": {
    "completedWorkouts": 10,
    "currentStreak": 3,
    "longestStreak": 5,
    "lastWorkoutDate": "2024-12-03T00:00:00.000Z",
    "badges": ["first-workout"]
  }
}
```

---

### `PUT /api/workouts/:workoutId/exercises/:exerciseIndex/sets`

Records per-exercise set progress for the active workout.

**Authentication:** JWT Token required

**URL Parameters:**

* `workoutId`: The ID of the workout
* `exerciseIndex`: The 0-based index of the exercise in the workout's exercises array

**Request Body:**

```json
{
  "completedSets": 2,
  "date": "2024-12-03"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "_id": "60d5f1f77e3a1f001f8e3b8e",
    "userId": "60d5f1f77e3a1f001f8e3b8b",
    "date": "2024-12-03",
    "workoutId": "60d5f1f77e3a1f001f8e3b8d",
    "exercises": [
      {
        "index": 0,
        "completedSets": 2
      }
    ]
  }
}
```

---

## Nutrition Routes (`/api/nutrition`)

### `POST /api/nutrition`

Creates a new nutrition plan. Intended for use by n8n webhook.

**Authentication:** API Key (`x-api-key`) required

**Request Body:**

```json
{
  "planId": "60d5f1f77e3a1f001f8e3b8c",
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

```json
{
  "success": true,
  "data": {
    "_id": "60d5f1f77e3a1f001f8e3b8f",
    "planId": "60d5f1f77e3a1f001f8e3b8c",
    "name": "High Protein Diet",
    "dailyCalories": 2500,
    "dailyWater": "3L",
    "macros": { /* Macros object */ },
    "meals": { /* Meals object */ },
    "createdAt": "2024-12-03T10:00:00.000Z",
    "updatedAt": "2024-12-03T10:00:00.000Z"
  }
}
```

---

### `GET /api/nutrition/plan/:planId`

Gets the nutrition plan for a specific plan.

**Authentication:** JWT Token required

**URL Parameters:**

* `planId`: The ID of the plan

**Response:**

```json
{
  "_id": "60d5f1f77e3a1f001f8e3b8f",
  "planId": "60d5f1f77e3a1f001f8e3b8c",
  "name": "High Protein Diet",
  "dailyCalories": 2500,
  "dailyWater": "3L",
  "macros": { /* Macros object */ },
  "meals": { /* Meals object */ }
}
```

---

### `GET /api/nutrition/:id`

Gets a nutrition plan by its ID.

**Authentication:** JWT Token required

**URL Parameters:**

* `id`: The ID of the nutrition plan

**Response:**

```json
{
  "_id": "60d5f1f77e3a1f001f8e3b8f",
  "planId": "60d5f1f77e3a1f001f8e3b8c",
  "name": "High Protein Diet",
  "dailyCalories": 2500,
  "dailyWater": "3L",
  "macros": { /* Macros object */ },
  "meals": { /* Meals object */ }
}
```

---

## Calendar Routes (`/api/calendar`)

The Calendar model tracks daily entries for users and includes the following fields:

* `userId`: Reference to the User
* `date`: Date in YYYY-MM-DD format
* `planId`: Reference to the Plan
* `workoutId`: Reference to the Workout
* `nutritionIds`: Array of Nutrition plan references
* `completed`: Boolean for overall day completion
* `workoutCompleted`: Boolean for workout completion (legacy)
* `completedNutritionIds`: Array of completed nutrition plan IDs
* `completedMeals`: Array of completed meal names (e.g., ["breakfast", "lunch"])
* `completedExercises`: Array of completed exercise indices as strings (e.g., ["0", "1", "2"])

### `POST /api/calendar`

Creates a new calendar entry. Intended for use by n8n webhook.

**Authentication:** API Key (`x-api-key`) required

**Request Body:**

```json
{
  "userId": "60d5f1f77e3a1f001f8e3b8b",
  "date": "2024-12-03",
  "planId": "60d5f1f77e3a1f001f8e3b8c",
  "workoutId": "60d5f1f77e3a1f001f8e3b8d",
  "nutritionIds": ["60d5f1f77e3a1f001f8e3b8f"],
  "completed": false
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "_id": "60d5f1f77e3a1f001f8e3b90",
    "userId": "60d5f1f77e3a1f001f8e3b8b",
    "date": "2024-12-03",
    "planId": "60d5f1f77e3a1f001f8e3b8c",
    "workoutId": "60d5f1f77e3a1f001f8e3b8d",
    "nutritionIds": ["60d5f1f77e3a1f001f8e3b8f"],
    "completed": false,
    "workoutCompleted": false,
    "completedNutritionIds": [],
    "completedMeals": [],
    "completedExercises": [],
    "createdAt": "2024-12-03T10:00:00.000Z",
    "updatedAt": "2024-12-03T10:00:00.000Z"
  }
}
```

---

### `GET /api/calendar`

Gets all calendar entries for the logged-in user.

**Authentication:** JWT Token required

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "_id": "60d5f1f77e3a1f001f8e3b90",
      "userId": "60d5f1f77e3a1f001f8e3b8b",
      "date": "2024-12-03",
      "planId": "60d5f1f77e3a1f001f8e3b8c",
      "workoutId": "60d5f1f77e3a1f001f8e3b8d",
      "nutritionIds": ["60d5f1f77e3a1f001f8e3b8f"],
      "completed": false,
      "workoutCompleted": false,
      "completedNutritionIds": [],
      "completedMeals": [],
      "completedExercises": []
    }
  ]
}
```

---

### `GET /api/calendar/:date`

Gets the calendar entry for a specific date (format: YYYY-MM-DD).

**Authentication:** JWT Token required

**URL Parameters:**

* `date`: The date of the entry to retrieve

**Response:**

```json
{
  "success": true,
  "data": {
    "_id": "60d5f1f77e3a1f001f8e3b90",
    "userId": "60d5f1f77e3a1f001f8e3b8b",
    "date": "2024-12-03",
    "planId": "60d5f1f77e3a1f001f8e3b8c",
    "workoutId": "60d5f1f77e3a1f001f8e3b8d",
    "nutritionIds": ["60d5f1f77e3a1f001f8e3b8f"],
    "completed": false,
    "workoutCompleted": false,
    "completedNutritionIds": [],
    "completedMeals": [],
    "completedExercises": []
  }
}
```

---

### `PUT /api/calendar/:date`

Marks a calendar entry for a specific date as complete or incomplete, and updates the list of completed meals and exercises.

**Authentication:** JWT Token required

**URL Parameters:**

* `date`: The date of the entry to update

**Request Body:**

```json
{
  "completed": true,
  "completedMeals": ["breakfast", "lunch"],
  "completedExercises": ["0", "1", "2"]
}
```

**Note:** All fields are optional. You can update any combination of `completed`, `completedMeals`, and `completedExercises`.

**Response:**

```json
{
  "success": true,
  "data": {
    "_id": "60d5f1f77e3a1f001f8e3b90",
    "userId": "60d5f1f77e3a1f001f8e3b8b",
    "date": "2024-12-03",
    "planId": "60d5f1f77e3a1f001f8e3b8c",
    "workoutId": "60d5f1f77e3a1f001f8e3b8d",
    "nutritionIds": ["60d5f1f77e3a1f001f8e3b8f"],
    "completed": true,
    "workoutCompleted": false,
    "completedNutritionIds": [],
    "completedMeals": ["breakfast", "lunch"],
    "completedExercises": ["0", "1", "2"]
  }
}
```

---

### `PUT /api/calendar/:date/nutrition/:nutritionId/complete`

Toggles completion for a specific nutrition plan assigned on the given date.

**Authentication:** JWT Token required

**URL Parameters:**

* `date`: The date of the nutrition plan (format: YYYY-MM-DD)
* `nutritionId`: The ID of the nutrition plan

**Request Body:**

```json
{
  "completed": true
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "_id": "60d5f1f77e3a1f001f8e3b90",
    "userId": "60d5f1f77e3a1f001f8e3b8b",
    "date": "2024-12-03",
    "completedNutritionIds": ["60d5f1f77e3a1f001f8e3b8f"],
    "completedMeals": [],
    "completedExercises": []
  }
}
```

---

### `PUT /api/calendar/:date/workout/complete`

Marks the workout for a given date as completed or uncompleted, and updates the list of completed exercises.

**Authentication:** JWT Token required

**URL Parameters:**

* `date`: The date of the workout to update (format: YYYY-MM-DD)

**Request Body:**

```json
{
  "workoutCompleted": true,
  "completedExercises": ["0", "1", "2"]
}
```

**Note:** Both fields are optional. You can update either `workoutCompleted` (boolean) or `completedExercises` (array of exercise indices as strings), or both.

**Response:**

```json
{
  "success": true,
  "data": {
    "_id": "60d5f1f77e3a1f001f8e3b90",
    "userId": "60d5f1f77e3a1f001f8e3b8b",
    "date": "2024-12-03",
    "workoutCompleted": true,
    "completedExercises": ["0", "1", "2"]
  }
}
```

---

### `PUT /api/calendar/:date/workout/exercise/:exerciseIndex/complete`

Toggles completion for a specific exercise in the workout for the given date.

**Authentication:** JWT Token required

**URL Parameters:**

* `date`: The date of the workout (format: YYYY-MM-DD)
* `exerciseIndex`: The 0-based index of the exercise in the workout's exercises array

**Request Body:**

```json
{
  "completed": true
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "_id": "60d5f1f77e3a1f001f8e3b90",
    "userId": "60d5f1f77e3a1f001f8e3b8b",
    "date": "2024-12-03",
    "completedExercises": ["0", "1"]
  }
}
```

**Response (Error - No Workout):**

```json
{
  "msg": "No workout assigned for this date"
}
```

---

## Progress Tracking Routes (`/api/progress`)

These endpoints enable the in-app tracking system (checkboxes for workout sets, mark-done for meals, and overall day/workout completion).

### `GET /api/progress/workout/:date`

Retrieves the workout progress for a specific date, including completed sets for each exercise.

**Authentication:** JWT Token required

**URL Parameters:**

* `date`: The date of the workout progress to retrieve (format: YYYY-MM-DD)

**Response (Success):**

```json
{
  "success": true,
  "data": {
    "_id": "60d5f1f77e3a1f001f8e3b91",
    "userId": "60d5f1f77e3a1f001f8e3b8b",
    "date": "2024-12-03",
    "workoutId": "60d5f1f77e3a1f001f8e3b8d",
    "exercises": [
      {
        "index": 0,
        "completedSets": 2
      },
      {
        "index": 1,
        "completedSets": 3
      }
    ]
  }
}
```

**Response (Error - Not Found):**

```json
{
  "success": false,
  "message": "Workout progress for date 2024-12-04 not found."
}
```

---

### `PUT /api/progress/workout/:workoutId/exercises/:exerciseIndex/sets`

Records per-exercise set progress for the active workout. This powers the set-checkboxes UI.

**Authentication:** JWT Token required

**URL Parameters:**

* `workoutId`: The ID of the workout
* `exerciseIndex`: The 0-based index of the exercise in the workout's exercises array

**Request Body:**

```json
{
  "completedSets": 2,
  "date": "2024-12-03"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "_id": "60d5f1f77e3a1f001f8e3b91",
    "userId": "60d5f1f77e3a1f001f8e3b8b",
    "date": "2024-12-03",
    "workoutId": "60d5f1f77e3a1f001f8e3b8d",
    "exercises": [
      {
        "index": 0,
        "completedSets": 2
      }
    ]
  }
}
```

---

### `GET /api/progress/weekly/:startDate`

Retrieves weekly workout progress data for a 7-day period starting from the specified date. Returns only progress sets data without exercise details.

**Authentication:** JWT Token required

**URL Parameters:**

* `startDate`: The start date of the week (format: YYYY-MM-DD)

**Response (Success):**

```json
{
  "success": true,
  "data": {
    "startDate": "2024-12-01",
    "endDate": "2024-12-07",
    "weekData": [
      {
        "date": "2024-12-01",
        "hasWorkout": true,
        "totalCompletedSets": 15,
        "totalPlannedSets": 20,
        "workoutCompleted": true,
        "completedExercises": ["0", "1", "2"]
      },
      {
        "date": "2024-12-02",
        "hasWorkout": false,
        "totalCompletedSets": 0,
        "totalPlannedSets": 0,
        "workoutCompleted": false,
        "completedExercises": []
      }
    ]
  }
}
```

**Response (Error - Invalid Date Format):**

```json
{
  "success": false,
  "message": "Invalid date format. Please use YYYY-MM-DD format."
}
```

**Note:** This endpoint provides a summary view of weekly progress focusing on sets completion rather than individual exercise details. Each day in the week includes:

* `hasWorkout`: Whether a workout is scheduled for that day
* `totalCompletedSets`: Total sets completed across all exercises
* `totalPlannedSets`: Total sets planned for the workout
* `workoutCompleted`: Boolean indicating if the workout is marked as complete
* `completedExercises`: Array of completed exercise indices

---

### `POST /api/progress/workout/:date/complete-all`

Marks all sets for all exercises in a workout on a specific date as complete. This also updates the `completedExercises` array in the calendar entry to include all exercise indices.

**Authentication:** JWT Token required

**URL Parameters:**

* `date`: The date of the workout to mark as complete (format: YYYY-MM-DD)

**Response (Success):**

```json
{
  "success": true,
  "message": "Workout progress for 2024-12-03 updated successfully."
}
```

**Note:** This endpoint updates both the `WorkoutProgress` collection (for set tracking) and the `Calendar` entry's `completedExercises` array (for exercise completion tracking).

---

### `POST /api/progress/nutrition/:date/complete-all`

Marks all meals for a nutrition plan on a specific date as complete.

**Authentication:** JWT Token required

**URL Parameters:**

* `date`: The date of the nutrition plan to mark as complete (format: YYYY-MM-DD)

**Response (Success):**

```json
{
  "success": true,
  "message": "Nutrition progress for 2024-12-03 updated successfully."
}
```

---

## Chat Routes (`/api/chat`)

### `POST /api/chat`

Posts a message from the user, triggers a webhook to get an AI response, and saves both messages to the database.

**Authentication:** JWT Token required

**Request Body:**

```json
{
  "text": "What should I eat before a workout?"
}
```

**Webhook Payload (sent to `process.env.ASK_COACH_WEBHOOK_URL`):**

```json
{
  "userId": "60d5f1f77e3a1f001f8e3b8b",
  "prompt": "What should I eat before a workout?",
  "token": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response (Success):**

```json
{
  "success": true,
  "data": {
    "_id": "60d5f1f77e3a1f001f8e3b92",
    "userId": "60d5f1f77e3a1f001f8e3b8b",
    "text": "For a pre-workout meal, focus on carbohydrates and a moderate amount of protein.",
    "sender": "ai",
    "timestamp": "2024-12-03T10:00:00.000Z"
  }
}
```

---

### `GET /api/chat`

Gets the entire chat history for the logged-in user.

**Authentication:** JWT Token required

**Response:**

```json
[
  {
    "_id": "60d5f1f77e3a1f001f8e3b92",
    "userId": "60d5f1f77e3a1f001f8e3b8b",
    "text": "What should I eat before a workout?",
    "sender": "user",
    "timestamp": "2024-12-03T10:00:00.000Z"
  },
  {
    "_id": "60d5f1f77e3a1f001f8e3b93",
    "userId": "60d5f1f77e3a1f001f8e3b8b",
    "text": "For a pre-workout meal, focus on carbohydrates and a moderate amount of protein.",
    "sender": "ai",
    "timestamp": "2024-12-03T10:01:00.000Z"
  }
]
```

---

## Data Models

### User Model

```javascript
{
  _id: ObjectId,
  name: String,
  email: String,
  password: String (hashed),
  onboardingAnswers: Object,
  onboardingCompleted: Boolean,
  progress: {
    completedWorkouts: Number,
    currentStreak: Number,
    longestStreak: Number,
    lastWorkoutDate: Date,
    badges: [String]
  },
  passwordResetToken: String,
  passwordResetExpires: Date,
  createdAt: Date,
  updatedAt: Date
}
```

### Plan Model

```javascript
{
  _id: ObjectId,
  userId: ObjectId (ref: 'User'),
  planName: String,
  duration: Number,
  difficulty: String,
  startDate: Date,
  endDate: Date,
  createdAt: Date,
  updatedAt: Date
}
```

### Workout Model

```javascript
{
  _id: ObjectId,
  planId: ObjectId (ref: 'Plan'),
  name: String,
  day: String,
  duration: String,
  targetMuscles: [String],
  exercises: [{
    name: String,
    sets: Number,
    reps: String,
    rest: String,
    instructions: String
  }],
  createdAt: Date,
  updatedAt: Date
}
```

### Nutrition Model

```javascript
{
  _id: ObjectId,
  planId: ObjectId (ref: 'Plan'),
  name: String,
  dailyCalories: Number,
  dailyWater: String,
  macros: {
    carbs: String,
    fats: String,
    protein: String
  },
  meals: {
    breakfast: Object,
    lunch: Object,
    dinner: Object,
    snacks: Object
  },
  createdAt: Date,
  updatedAt: Date
}
```

### Calendar Model

```javascript
{
  _id: ObjectId,
  userId: ObjectId (ref: 'User'),
  date: String, // YYYY-MM-DD format
  planId: ObjectId (ref: 'Plan'),
  workoutId: ObjectId (ref: 'Workout'),
  nutritionIds: [ObjectId (ref: 'Nutrition')],
  completed: Boolean,
  workoutCompleted: Boolean,
  completedNutritionIds: [ObjectId (ref: 'Nutrition')],
  completedMeals: [String],
  completedExercises: [String],
  createdAt: Date,
  updatedAt: Date
}
```

### WorkoutProgress Model

```javascript
{
  _id: ObjectId,
  userId: ObjectId (ref: 'User'),
  date: String, // YYYY-MM-DD format
  workoutId: ObjectId (ref: 'Workout'),
  exercises: [{
    index: Number,
    completedSets: Number
  }],
  createdAt: Date,
  updatedAt: Date
}
```

### ChatMessage Model

```javascript
{
  _id: ObjectId,
  userId: ObjectId (ref: 'User'),
  text: String,
  sender: String, // 'user' or 'ai'
  timestamp: Date
}
```

---

## Error Responses

All endpoints may return the following error responses:

### 400 Bad Request

```json
{
  "errors": [
    {
      "msg": "Error message",
      "param": "fieldName",
      "location": "body"
    }
  ]
}
```

### 401 Unauthorized

```json
{
  "msg": "No token, authorization denied"
}
```

### 404 Not Found

```json
{
  "success": false,
  "msg": "Resource not found"
}
```

### 500 Internal Server Error

```json
{
  "msg": "Server Error"
}
```

---

## Frontend Integration Notes

### Authentication Flow

1. User registers/logs in via `/api/auth/register` or `/api/auth/login`
2. Store the JWT token from the response
3. Include the token in all subsequent requests: `Authorization: Bearer <token>`

### Data Fetching Strategy

1. Use `/api/users/full-profile` to get all user data at app startup
2. Use specific endpoints for real-time updates (calendar, progress, chat)
3. Use weekly progress endpoint for dashboard/charts

### Real-time Updates

* Calendar entries: Use PUT endpoints to update completion status

* Workout progress: Use progress endpoints for set tracking
* Chat: Use POST/GET endpoints for messaging

### Error Handling

* Always check for `success` field in responses

* Handle 401 errors by redirecting to login
* Display user-friendly error messages from `msg` or `message` fields
