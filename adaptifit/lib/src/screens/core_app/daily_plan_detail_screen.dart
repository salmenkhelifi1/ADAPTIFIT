// lib/src/screens/core_app/daily_plan_detail_screen.dart

import 'package:adaptifit/src/core/models/models.dart';
import 'package:adaptifit/src/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:adaptifit/src/constants/app_colors.dart';

class DailyPlanDetailScreen extends StatefulWidget {
  final DateTime date;

  const DailyPlanDetailScreen({super.key, required this.date});

  @override
  State<DailyPlanDetailScreen> createState() => _DailyPlanDetailScreenState();
}

class _DailyPlanDetailScreenState extends State<DailyPlanDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Stream<Calendar> _calendarDayStream;

  @override
  void initState() {
    super.initState();
    final dateString = DateFormat('yyyy-MM-dd').format(widget.date);
    _calendarDayStream = _firestoreService.getCalendarEntry(dateString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.screenBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            Text(
              DateFormat('EEEE').format(widget.date),
              style: const TextStyle(
                color: AppColors.darkText,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(
              DateFormat('MMM d, yyyy').format(widget.date),
              style: const TextStyle(
                color: AppColors.subtitleGray,
                fontSize: 14,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<Calendar>(
        stream: _calendarDayStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return _buildNoPlanMessage();
          }

          final calendarDay = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildPreviewBanner(),
                const SizedBox(height: 20),
                if (calendarDay.hasWorkout &&
                    calendarDay.workoutId != null)                  StreamBuilder<Workout>(
                    stream: _firestoreService.getWorkout(calendarDay.workoutId!),
                    builder: (context, workoutSnapshot) {
                      if (workoutSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!workoutSnapshot.hasData || workoutSnapshot.data == null) {
                        return const Text("Workout not found");
                      }
                      return _buildWorkoutCard(workoutSnapshot.data!);
                    },
                  ),
                if (calendarDay.hasNutrition) ...[
                  const SizedBox(height: 20),
                  StreamBuilder<List<Nutrition>>(
                    stream: _firestoreService
                        .getNutritionsByIds(calendarDay.nutritionIds),
                    builder: (context, nutritionSnapshot) {
                      if (nutritionSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!nutritionSnapshot.hasData ||
                          nutritionSnapshot.data!.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        children: nutritionSnapshot.data!
                            .map((nutrition) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: _buildNutritionCard(nutrition),
                                ))
                            .toList(),
                      );
                    },
                  ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreviewBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.secondaryBlue),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'This is a preview of your upcoming plan. Completion options will be available on the day of your workout.',
              style: TextStyle(color: AppColors.darkText, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(Workout workout) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkText.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💪', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  if (workout.duration != null)
                    Text('🕒 ${workout.duration}',
                        style: const TextStyle(color: AppColors.subtitleGray)),
                ],
              ),
            ],
          ),
          const Divider(height: 32),
          ...workout.exercises
              .map((exercise) => _buildExerciseRow(exercise))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildExerciseRow(Exercise exercise) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                Text('${exercise.sets} sets x ${exercise.reps}',
                    style: const TextStyle(color: AppColors.subtitleGray)),
              ],
            ),
          ),
          if (exercise.rest != null)
            Text('Rest: ${exercise.rest}',
                style: const TextStyle(color: AppColors.subtitleGray)),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(Nutrition nutrition) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkText.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🍎', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // FIX: Use 'name' instead of 'mealType'
                nutrition.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text('Personalized meal plan',
                  style: TextStyle(color: AppColors.subtitleGray)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoPlanMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            const Text('No Plan For This Day',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Enjoy your rest day!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
