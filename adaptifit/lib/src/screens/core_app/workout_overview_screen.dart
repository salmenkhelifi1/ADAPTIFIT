import 'package:adaptifit/src/core/models/workout.dart';
import 'package:adaptifit/src/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:adaptifit/src/constants/app_colors.dart'; // Assuming you have this

class WorkoutOverviewScreen extends StatefulWidget {
  final String workoutId;

  const WorkoutOverviewScreen({
    Key? key,
    required this.workoutId,
  }) : super(key: key);

  @override
  _WorkoutOverviewScreenState createState() => _WorkoutOverviewScreenState();
}

class _WorkoutOverviewScreenState extends State<WorkoutOverviewScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    debugPrint("WorkoutOverviewScreen initState, workoutId: ${widget.workoutId}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: StreamBuilder<Workout?>(
          stream: _firestoreService.getWorkout(widget.workoutId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('Workout not found.'));
            }

            final workout = snapshot.data!;

            // The main scrollable view
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildInfoBanner(),
                    const SizedBox(height: 16),
                    _buildWorkoutCard(workout),
                    const SizedBox(height: 16),
                    _buildNutritionHeader(),
                    const SizedBox(height: 16),
                    _buildNutritionDetailsCard(),
                    const SizedBox(height: 16),
                    _buildDailySummaryCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Reusable and Helper Widgets ---

  // Consistent card styling
  Widget _buildStyledContainer(
      {required Widget child, Color color = AppColors.white}) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: child,
    );
  }

  // Header with back button and title
  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 8),
        // TODO: Pass the real day and date to this screen
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tuesday', // Placeholder
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            Text(
              'Tue, Dec 26', // Placeholder
              style: TextStyle(fontSize: 16, color: AppColors.subtitleGray),
            ),
          ],
        ),
      ],
    );
  }

  // Informational banner
  Widget _buildInfoBanner() {
    return _buildStyledContainer(
      color: AppColors.secondaryBlue.withOpacity(0.1),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.secondaryBlue),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'This is a preview of your upcoming plan. Completion options will be available on the day of your workout.',
              style: TextStyle(color: AppColors.secondaryBlue, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Card displaying the workout and its exercises
  Widget _buildWorkoutCard(Workout workout) {
    return _buildStyledContainer(
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined,
                  color: AppColors.primaryGreen, size: 28), // Example Icon
              const SizedBox(width: 12),
              const Text('💪', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (workout.duration != null)
                      Text(
                        '🕒 ${workout.duration}',
                        style: const TextStyle(
                            color: AppColors.subtitleGray, fontSize: 14),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Using Column instead of ListView for simplicity within SingleChildScrollView
          Column(
            children: workout.exercises.asMap().entries.map((entry) {
              final index = entry.key;
              final exercise = entry.value;
              return Column(
                children: [
                  if (index > 0)
                    const Divider(color: AppColors.lightGrey2, height: 24),
                  _buildExerciseItem(exercise),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // A single exercise row inside the workout card
  Widget _buildExerciseItem(Exercise exercise) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${exercise.sets} sets x ${exercise.reps} reps',
              style: const TextStyle(
                color: AppColors.subtitleGray,
                fontSize: 14,
              ),
            ),
          ],
        ),
        if (exercise.rest != null)
          Text(
            'Rest: ${exercise.rest}',
            style: const TextStyle(
              color: AppColors.subtitleGray,
              fontSize: 14,
            ),
          ),
      ],
    );
  }

  // Card that introduces the nutrition plan
  Widget _buildNutritionHeader() {
    return _buildStyledContainer(
      child: const Row(
        children: [
          Icon(Icons.apple, color: AppColors.secondaryBlue, size: 28),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'High Protein Focus', // Placeholder
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Personalized meal plan', // Placeholder
                style: TextStyle(color: AppColors.subtitleGray, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- All Nutrition Widgets (using placeholder data) ---
  Widget _buildNutritionDetailsCard() {
    // TODO: Fetch your nutrition plan data here and pass it to these widgets
    return _buildStyledContainer(
      child: Column(
        children: [
          _buildMealCard(
            icon: '🍽️',
            title: 'Breakfast',
            mealName: 'Greek Yogurt Bowl',
            items: [
              '1 cup Greek yogurt',
              '1/2 cup mixed berries',
              '2 tbsp granola',
              '1 tsp honey'
            ],
            calories: 320,
            protein: 25,
          ),
          const Divider(height: 32),
          _buildMealCard(
            icon: '🥗',
            title: 'Lunch',
            mealName: 'Mediterranean Power Bowl',
            items: [
              '2 cups mixed greens',
              '4 oz grilled chicken',
              '1/4 cup quinoa',
              '2 tbsp hummus',
              '1/4 cup feta cheese'
            ],
            calories: 420,
            protein: 32,
          ),
          const Divider(height: 32),
          _buildMealCard(
            icon: '🐟',
            title: 'Dinner',
            mealName: 'Grilled Salmon & Quinoa',
            items: [
              '5 oz salmon fillet',
              '1 cup quinoa',
              '1 cup steamed broccoli',
              '1 tbsp lemon sauce'
            ],
            calories: 485,
            protein: 35,
          ),
          const Divider(height: 32),
          _buildMealCard(
            icon: '🥜',
            title: 'Snacks',
            mealName: 'Post-Workout Snack',
            items: [
              '1 scoop protein powder',
              '1 banana',
              '1 cup almond milk',
              '1 tbsp almond butter'
            ],
            calories: 280,
            protein: 25,
          ),
          const Divider(height: 32),
          _buildHydrationCard(),
        ],
      ),
    );
  }

  // Reusable card for a single meal
  Widget _buildMealCard({
    required String icon,
    required String title,
    required String mealName,
    required List<String> items,
    required int calories,
    required int protein,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mealName,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...items.map((item) => Text('· $item',
                  style: const TextStyle(color: AppColors.subtitleGray))),
              const SizedBox(height: 8),
              Text(
                '${calories} cal · ${protein}g protein',
                style: TextStyle(
                    color: AppColors.darkText.withOpacity(0.7),
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        )
      ],
    );
  }

  // Hydration specific card
  Widget _buildHydrationCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('💧', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text(
              'Hydration',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daily Hydration Goals',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...[
                '8-10 glasses of water',
                '1 cup green tea',
                'Electrolyte drink post-workout'
              ].map((item) => Text('· $item',
                  style: const TextStyle(color: AppColors.subtitleGray))),
              const SizedBox(height: 8),
              Text(
                'Target: 2.5L daily',
                style: TextStyle(
                    color: AppColors.darkText.withOpacity(0.7),
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        )
      ],
    );
  }

  // Daily Summary section at the bottom
  Widget _buildDailySummaryCard() {
    // TODO: Pass real summary data here
    return _buildStyledContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatItem('1,505', 'Total Calories')),
              const SizedBox(width: 12),
              Expanded(child: _buildStatItem('114g', 'Total Protein')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatItem('50 minutes', 'Workout Duration')),
              const SizedBox(width: 12),
              Expanded(child: _buildStatItem('2.5L', 'Hydration Goal')),
            ],
          ),
        ],
      ),
    );
  }

  // A single stat box for the summary
  Widget _buildStatItem(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppColors.subtitleGray, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
