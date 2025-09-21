import 'package:adaptifit/src/core/models/calendar_day_model.dart';
import 'package:adaptifit/src/core/models/nutrition_model.dart';
import 'package:adaptifit/src/core/models/workout_model.dart';
import 'package:adaptifit/src/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyPlanDetailScreen extends StatefulWidget {
  final DateTime date;

  const DailyPlanDetailScreen({super.key, required this.date});

  @override
  State<DailyPlanDetailScreen> createState() => _DailyPlanDetailScreenState();
}

class _DailyPlanDetailScreenState extends State<DailyPlanDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Stream<CalendarDayModel> _calendarDayStream;

  @override
  void initState() {
    super.initState();
    final dateString = DateFormat('yyyy-MM-dd').format(widget.date);
    _calendarDayStream = _firestoreService.getCalendarEntry(dateString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F0F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Daily Plan Detail',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<CalendarDayModel>(
        stream: _calendarDayStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(
              child: _buildNoPlanMessage(),
            );
          }

          final calendarDay = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  DateFormat('EEEE').format(widget.date), // e.g., "Wednesday"
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMMM d, yyyy')
                      .format(widget.date), // e.g., "December 4, 2024"
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                if (calendarDay.hasWorkout)
                  StreamBuilder<List<WorkoutModel>>(
                    stream: _firestoreService.getWorkouts(calendarDay.planId),
                    builder: (context, workoutSnapshot) {
                      if (!workoutSnapshot.hasData) {
                        return const SizedBox.shrink();
                      }
                      final workout = workoutSnapshot.data!.firstWhere(
                          (w) => w.id == calendarDay.workoutId, orElse: () => WorkoutModel(id: '', name: 'Workout not found', exercises: []));
                      return _buildWorkoutPlanCard(workout);
                    },
                  ),
                const SizedBox(height: 20),
                if (calendarDay.hasNutrition)
                  StreamBuilder<List<NutritionModel>>(
                    stream: _firestoreService.getNutritionPlans(),
                    builder: (context, nutritionSnapshot) {
                      if (!nutritionSnapshot.hasData) {
                        return const SizedBox.shrink();
                      }
                      final nutrition = nutritionSnapshot.data!.firstWhere(
                          (n) => calendarDay.nutritionIds.contains(n.nutritionId), orElse: () => NutritionModel(nutritionId: '', mealPlanName: 'Not Found', day: '', meals: [], calories: 0, protein: 0, carbs: 0, fat: 0));
                      return _buildNutritionPlanCard(nutrition);
                    },
                  ),
                const SizedBox(height: 20),
                _buildDailyTasksCard(),
                const SizedBox(height: 20),
                _buildDailyNotesCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoPlanMessage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
        const SizedBox(height: 20),
        const Text(
          'No plan for this day',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          'Enjoy your rest day or explore other options!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildStyledCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildWorkoutPlanCard(WorkoutModel workout) {
    return _buildStyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.fitness_center, color: Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name,
                      style:
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Full Body HIIT · 45 minutes',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'High-intensity interval training for full body',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.timer_outlined, color: Colors.black54, size: 20),
              SizedBox(width: 8),
              Text('45 minutes', style: TextStyle(color: Colors.black54)),
              SizedBox(width: 24),
              Icon(Icons.format_list_numbered, color: Colors.black54, size: 20),
              SizedBox(width: 8),
              Text('8 exercises', style: TextStyle(color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1EB955),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'View Full Workout Details',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionPlanCard(NutritionModel nutrition) {
    return _buildStyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.apple, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nutrition.mealPlanName,
                      style:
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Low Carb Focus · 2,100 cal',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Reduced carbohydrate intake for fat burning',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Meals",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (nutrition.meals.isNotEmpty)
                  ...nutrition.meals.map((meal) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(meal.split(':')[0] + ':', style: const TextStyle(color: Colors.black54)),
                        Text(meal.split(':')[1]),
                      ],
                    ),
                  )),
                if (nutrition.meals.isEmpty)
                  const Text('No meals planned for today.', style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text('${nutrition.calories}',
                      style:
                          const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Text('Calories', style: TextStyle(color: Colors.black54)),
                ],
              ),
              Column(
                children: [
                  Text('${nutrition.protein}g',
                      style:
                          const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Text('Protein', style: TextStyle(color: Colors.black54)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'View Full Nutrition Plan',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTasksCard() {
    return _buildStyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.black87),
              SizedBox(width: 8),
              Text(
                'Daily Tasks',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Recommended habits for optimal results',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          _buildTaskItem('Drink 8 glasses of water'),
          _buildTaskItem('Take progress photos'),
          _buildTaskItem('Log meals in app'),
          _buildTaskItem('Stretch for 10 minutes'),
          _buildTaskItem('Get 7-8 hours sleep'),
        ],
      ),
    );
  }

  Widget _buildTaskItem(String task) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          const Icon(Icons.circle, color: Colors.green, size: 10),
          const SizedBox(width: 12),
          Expanded(child: Text(task, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildDailyNotesCard() {
    return _buildStyledCard(
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Notes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'Remember to listen to your body and adjust intensity as needed. Focus on proper form over speed, and don\'t forget to stay hydrated throughout the day.',
            style: TextStyle(color: Colors.black54, fontSize: 16, height: 1.5),
          )
        ],
      ),
    );
  }
}
