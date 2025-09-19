import 'package:adaptifit/src/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  Future<Map<String, dynamic>?>? _detailsFuture;

  @override
  void initState() {
    super.initState();
    if (_currentUser != null) {
      _detailsFuture = _fetchPlanDetailsForDate();
    }
  }

  Future<Map<String, dynamic>?> _fetchPlanDetailsForDate() async {
    final dateKey = DateFormat('yyyy-MM-dd').format(widget.date);
    final calendarDoc =
        await _firestoreService.getCalendarEntry(_currentUser!.uid, dateKey);

    if (!calendarDoc.exists) return null;

    final calendarData = calendarDoc.data() as Map<String, dynamic>;
    final workoutId = calendarData['workoutId'];
    // You can also get nutritionId here

    final userDoc = await _firestoreService.getUser(_currentUser!.uid);
    final activePlanId = userDoc.get('activePlanId');

    if (activePlanId == null || workoutId == null) return null;

    final workoutDoc = await _firestoreService.getWorkout(
        _currentUser!.uid, activePlanId, workoutId);

    if (!workoutDoc.exists) return null;

    return {
      'workout': workoutDoc.data(),
      'nutrition': null, // Placeholder for nutrition data
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F4F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Daily Plan Detail',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return _buildEmptyState();
          }

          final workout = snapshot.data!['workout'];
          // final nutrition = snapshot.data!['nutrition'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(DateFormat('EEEE').format(widget.date),
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(DateFormat('MMMM d, yyyy').format(widget.date),
                    style:
                        const TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 24),
                if (workout != null) _buildWorkoutPlanCard(workout),
                const SizedBox(height: 20),
                // Add nutrition card here
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

  Widget _buildEmptyState() {
    return const Center(
        child: Text("No plan details found for this day.",
            style: TextStyle(color: Colors.grey, fontSize: 16)));
  }

  Widget _buildWorkoutPlanCard(Map<String, dynamic> workout) {
    final exercises = workout['exercises'] as List?;
    return _buildStyledCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.fitness_center, color: Colors.green)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Workout Plan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(workout['type'] ?? 'Workout',
              style: const TextStyle(color: Colors.black54))
        ]))
      ]),
      const SizedBox(height: 16),
      Row(children: [
        const Icon(Icons.timer_outlined, color: Colors.black54, size: 20),
        const SizedBox(width: 8),
        const Text('45 minutes',
            style:
                TextStyle(color: Colors.black54)), // Placeholder for duration
        const SizedBox(width: 24),
        const Icon(Icons.format_list_numbered, color: Colors.black54, size: 20),
        const SizedBox(width: 8),
        Text('${exercises?.length ?? 0} exercises',
            style: const TextStyle(color: Colors.black54))
      ]),
      const SizedBox(height: 20),
      ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1EB955),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 0),
          child:
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('View Full Workout Details',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16)
          ]))
    ]));
  }

  // --- Unchanged Helper Widgets ---
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
                  blurRadius: 10)
            ]),
        child: child);
  }

  Widget _buildDailyTasksCard() {
    return _buildStyledCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Icon(Icons.check_circle_outline, color: Colors.black87),
        SizedBox(width: 8),
        Text('Daily Tasks',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
      ]),
      const SizedBox(height: 4),
      const Text('Recommended habits for optimal results',
          style: TextStyle(color: Colors.black54)),
      const SizedBox(height: 12),
      _buildTaskItem('Drink 8 glasses of water'),
      _buildTaskItem('Take progress photos'),
      _buildTaskItem('Log meals in app'),
      _buildTaskItem('Stretch for 10 minutes'),
      _buildTaskItem('Get 7-8 hours sleep')
    ]));
  }

  Widget _buildTaskItem(String task) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(children: [
          const Icon(Icons.circle, color: Colors.green, size: 10),
          const SizedBox(width: 12),
          Expanded(child: Text(task, style: const TextStyle(fontSize: 16)))
        ]));
  }

  Widget _buildDailyNotesCard() {
    return _buildStyledCard(
        child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text('Daily Notes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text(
              'Remember to listen to your body and adjust intensity as needed. Focus on proper form over speed, and don\'t forget to stay hydrated throughout the day.',
              style:
                  TextStyle(color: Colors.black54, fontSize: 16, height: 1.5))
        ]));
  }
}
