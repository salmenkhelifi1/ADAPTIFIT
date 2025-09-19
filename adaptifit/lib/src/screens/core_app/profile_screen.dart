import 'package:adaptifit/src/core/models/plan_model.dart';
import 'package:adaptifit/src/core/models/user_model.dart';
import 'package:adaptifit/src/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/src/screens/core_app/calendar_screen.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  Future<PlanModel?>? _planFuture;

  @override
  void initState() {
    super.initState();
    if (_currentUser != null) {
      _planFuture = _fetchActivePlan();
    }
  }

  Future<PlanModel?> _fetchActivePlan() async {
    final userDoc = await _firestoreService.getUser(_currentUser!.uid);
    if (!userDoc.exists) return null;

    final user = UserModel.fromFirestore(userDoc);
    if (user.activePlanId == null) return null;

    final planDoc =
        await _firestoreService.getPlan(user.uid, user.activePlanId!);
    if (!planDoc.exists) return null;

    return PlanModel.fromFirestore(planDoc);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: FutureBuilder<PlanModel?>(
          future: _planFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return _buildEmptyState(); // Show a nice message if no plan
            }

            final plan = snapshot.data!;
            final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
            final todaysCalendarEntry = plan.planData['calendar']?[today];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildTodaysPlanSection(plan, todaysCalendarEntry),
                  const SizedBox(height: 24),
                  _buildWeeklyProgressCard(plan),
                  const SizedBox(height: 24),
                  _buildUpcomingPlansSection(plan),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('My Plan',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.calendar_today_outlined, size: 28),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CalendarScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTodaysPlanSection(
      PlanModel plan, Map<String, dynamic>? calendarEntry) {
    // Find today's workout and nutrition from the planData
    final workout = plan.planData['workouts']?.firstWhere(
        (w) => w['workoutId'] == calendarEntry?['workoutId'],
        orElse: () => null);
    // You can extend this to find nutrition data similarly

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Today's Plan",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('Plan Overview >',
                style: TextStyle(
                    color: Colors.green[600],
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
          ],
        ),
        const SizedBox(height: 10),
        if (workout != null)
          _buildWorkoutCard(workout)
        else
          _buildRestDayCard("No workout scheduled for today."),
        const SizedBox(height: 16),
        // Add nutrition card here if it exists for today
        _buildRestDayCard("Nutrition plan for today."),
      ],
    );
  }

  Widget _buildWeeklyProgressCard(PlanModel plan) {
    // Logic to calculate progress would go here
    return _buildStyledContainer(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Icon(Icons.trending_up, color: Colors.black87),
        SizedBox(width: 8),
        Text('Weekly Progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
      ]),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        // Placeholder data
        _buildProgressItem('0/7', 'Workouts', 0.0, Colors.green),
        _buildProgressItem('0/21', 'Meals', 0.0, Colors.blue),
      ])
    ]));
  }

  Widget _buildUpcomingPlansSection(PlanModel plan) {
    List<Widget> upcomingWidgets = [];
    final today = DateTime.now();
    for (int i = 1; i <= 3; i++) {
      final upcomingDate = today.add(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(upcomingDate);
      final calendarEntry = plan.planData['calendar']?[dateKey];

      if (calendarEntry != null) {
        final workout = plan.planData['workouts']?.firstWhere(
            (w) => w['workoutId'] == calendarEntry['workoutId'],
            orElse: () => null);
        if (workout != null) {
          upcomingWidgets.add(_buildUpcomingPlanCard(
            day: DateFormat('EEE, MMM d').format(upcomingDate),
            workout: workout['type'] ?? 'Workout',
            // You can add meal details here if available
          ));
          upcomingWidgets.add(const SizedBox(height: 16));
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Upcoming Plans",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...upcomingWidgets,
      ],
    );
  }

  // --- UI Helper Widgets ---

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Active Plan',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Your personalized plan will appear here once it\'s generated.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(Map<String, dynamic> workout) {
    return _buildStyledContainer(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.fitness_center, color: Colors.green)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(workout['type'] ?? 'Workout',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(
              '🕒 ${workout['exercises']?.length ?? 0} exercises', // Placeholder for time
              style: const TextStyle(color: Colors.black54))
        ])
      ]),
      const SizedBox(height: 16),
      const Text('View Details >',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
      const SizedBox(height: 16),
      ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 0),
          child: const Text('Workout Completed',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)))
    ]));
  }

  Widget _buildRestDayCard(String message) {
    return _buildStyledContainer(
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.bedtime_outlined, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingPlanCard({
    required String day,
    required String workout,
  }) {
    return _buildStyledContainer(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(day,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 16),
        Row(children: [
          const Text('💪', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(workout,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))
        ])
      ])),
      Text('View Details >',
          style:
              TextStyle(color: Colors.green[600], fontWeight: FontWeight.w600))
    ]));
  }

  Widget _buildProgressItem(
      String value, String label, double progress, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value,
          style: TextStyle(
              fontSize: 32, fontWeight: FontWeight.bold, color: color)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.black54)),
      const SizedBox(height: 8),
      SizedBox(
          width: 120,
          child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3)))
    ]);
  }

  Widget _buildStyledContainer({required Widget child}) {
    return Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ]),
        child: child);
  }
}
