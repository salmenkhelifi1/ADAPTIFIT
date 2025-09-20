import 'package:flutter/material.dart';
import '/src/screens/core_app/calendar_screen.dart'; // Import the calendar screen
import '/src/screens/core_app/workout_overview_screen.dart';
import '/src/screens/core_app/nutrition_overview_screen.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Using a lighter background for the main screen as per the design
    const screenBackgroundColor = Color(0xFFF0F4F8);

    return Scaffold(
      backgroundColor: screenBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Plan',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today_outlined, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CalendarScreen()),
                      );
                    },
                  ),
                ],
              ),
              const Text(
                'Monday, December 25',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 20),

              // --- Today's Plan Section ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's Plan",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Plan Overview >',
                    style: TextStyle(
                      color: Colors.green[600],
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WorkoutOverviewScreen(workoutId: 'dummy_id'),
                    ),
                  );
                },
                child: _buildWorkoutCard(),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NutritionOverviewScreen(nutritionId: 'dummy_id'),
                    ),
                  );
                },
                child: _buildNutritionCard(),
              ),
              const SizedBox(height: 24),

              // --- Weekly Progress Section ---
              _buildWeeklyProgressCard(),
              const SizedBox(height: 24),

              // --- Upcoming Plans Section ---
              const Text(
                "Upcoming Plans",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildUpcomingPlanCard(
                dayAndDate: 'Tue, Dec 26',
                emoji: '💪',
                workout: 'Lower Body Strength',
                breakfast: 'Greek Yogurt Bowl',
                dinner: 'Grilled Salmon & Quinoa',
              ),
              const SizedBox(height: 16),
              _buildUpcomingPlanCard(
                dayAndDate: 'Wed, Dec 27',
                emoji: '🏃',
                workout: 'Cardio & Core',
                breakfast: 'Overnight Oats',
                dinner: 'Chicken Stir-fry',
              ),
              const SizedBox(height: 16),
              _buildUpcomingPlanCard(
                dayAndDate: 'Thu, Dec 28',
                emoji: '🧘',
                workout: 'Active Recovery',
                breakfast: 'Smoothie Bowl',
                dinner: 'Veggie Buddha Bowl',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // A generic card builder to match the design's container style
  Widget _buildStyledContainer({required Widget child}) {
    const cardBackgroundColor = Colors.white;
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildWorkoutCard() {
    const primaryGreen = Color(0xFF1EB955);
    return _buildStyledContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.fitness_center, color: primaryGreen),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upper Body Strength',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '🕒 45 minutes',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'View Details >',
            style: TextStyle(
              color: primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Workout Completed',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard() {
    const primaryBlue = Colors.blue;
    return _buildStyledContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.apple, color: primaryBlue),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'High Protein Focus',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Balanced nutrition plan',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'View Details >',
            style: TextStyle(
              color: primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1EB955),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Nutrition Completed',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgressCard() {
    return _buildStyledContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up, color: Colors.black87),
              SizedBox(width: 8),
              Text(
                'Weekly Progress',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '5/7',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1EB955)),
                  ),
                  const SizedBox(height: 4),
                  const Text('Workouts',
                      style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 120,
                    child: LinearProgressIndicator(
                      value: 5 / 7,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF1EB955)),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '19/21',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                  const SizedBox(height: 4),
                  const Text('Meals', style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 120,
                    child: LinearProgressIndicator(
                      value: 19 / 21,
                      backgroundColor: Colors.grey.shade300,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.blue),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingPlanCard({
    required String dayAndDate,
    required String emoji,
    required String workout,
    required String breakfast,
    required String dinner,
  }) {
    return _buildStyledContainer(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayAndDate,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          workout,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Breakfast: $breakfast',
                        style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text('Dinner: $dinner',
                        style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              Text(
                'View Details >',
                style: TextStyle(
                  color: Colors.green[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
