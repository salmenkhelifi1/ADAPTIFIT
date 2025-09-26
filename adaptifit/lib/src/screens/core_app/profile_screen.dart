import 'package:adaptifit/src/constants/app_colors.dart';
import 'package:adaptifit/src/screens/core_app/badges_streaks_screen.dart';
import 'package:adaptifit/src/screens/core_app/injury_adaptation_notes_screen.dart';
import 'package:adaptifit/src/core/models/models.dart';
import 'package:adaptifit/src/screens/auth/change_password_screen.dart';
import 'package:adaptifit/src/screens/auth/welcome_screen.dart';
import 'package:adaptifit/src/services/firestore_service.dart';
import 'package:adaptifit/src/services/n8n_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:adaptifit/src/screens/core_app/rewrite_plan_screen.dart';
import 'package:adaptifit/src/core/models/plan.dart';
import 'package:adaptifit/src/screens/core_app/workout_overview_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final N8nService _n8nService = N8nService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  Stream<UserModel>? _userStream;
  Stream<List<Plan>>? _plansStream;

  @override
  void initState() {
    super.initState();
    if (_currentUser != null) {
      _userStream = _firestoreService.getUser();
      _plansStream = _firestoreService.getPlans();
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.neutralGray,
        elevation: 0,
        title: const Text('Profile',
            style: TextStyle(
                color: AppColors.darkText,
                fontWeight: FontWeight.bold,
                fontSize: 28)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: AppColors.primaryGreen,
              // You can replace this with your actual logo asset
              child: Text('A',
                  style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
            ),
          ),
        ],
      ),
      body: StreamBuilder<UserModel>(
        stream: _userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading profile: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Could not find user profile.'));
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildProfileHeader(user),
                const SizedBox(height: 24),
                _buildAccountInfoCard(user),
                const SizedBox(height: 24),
                _buildPlansCard(),
                const SizedBox(height: 24),
                _buildProgressCard(user),
                const SizedBox(height: 24),
                _buildNotesCard(),
                const SizedBox(height: 24),
                _buildBadgesCard(),
                const SizedBox(height: 32),
                _buildActionButton(
                  icon: Icons.refresh,
                  text: 'Rewrite Plan',
                  isPrimary: true,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RewritePlanScreen(
                          userId: user.id,
                          onboardingAnswers: user.onboardingAnswers,
                          n8nService: _n8nService,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  icon: Icons.lock_outline,
                  text: 'Change Password',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildLogoutButton(),
                const SizedBox(height: 24),
                const Text(
                  'Adaptifit v2.1.0',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.primaryGreen,
          child: Text(
            user.name.isNotEmpty
                ? user.name.substring(0, 1).toUpperCase()
                : '?',
            style: const TextStyle(
                color: AppColors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.name,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
                'Member since ${DateFormat('MMM yyyy').format(user.createdAt.toDate())}',
                style: const TextStyle(color: AppColors.grey, fontSize: 15)),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountInfoCard(UserModel user) {
    return _buildInfoCard(
      title: 'Account Information',
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.email_outlined, color: AppColors.darkGrey),
        ),
        title: const Text('Email', style: TextStyle(color: AppColors.grey)),
        subtitle: Text(
          user.email,
          style: const TextStyle(
              color: AppColors.darkText,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPlansCard() {
    return StreamBuilder<List<Plan>>(
      stream: _plansStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildInfoCard(
              title: 'Your Plans',
              child: const Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return _buildInfoCard(
              title: 'Your Plans', child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildInfoCard(
              title: 'Your Plans', child: const Text('No plans found.'));
        }

        final plans = snapshot.data!;
        return _buildInfoCard(
          title: 'Your Plans',
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return ExpansionTile(
                title: Text(plan.planName),
                subtitle: Text('${plan.planType} - ${plan.duration}'),
                children: [
                  StreamBuilder<List<Workout>>(
                    stream: _firestoreService.getWorkouts(plan.planId),
                    builder: (context, workoutSnapshot) {
                      if (workoutSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (workoutSnapshot.hasError) {
                        return const ListTile(
                            title: Text('Error loading workouts'));
                      }
                      if (!workoutSnapshot.hasData ||
                          workoutSnapshot.data!.isEmpty) {
                        return const ListTile(title: Text('No workouts found.'));
                      }
                      final workouts = workoutSnapshot.data!;
                      return Column(
                        children: workouts.map((workout) {
                          return ListTile(
                            title: Text(workout.name),
                            subtitle: Text(workout.day ?? ''),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WorkoutOverviewScreen(
                                    planId: plan.planId,
                                    workoutId: workout.workoutId,
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNotesCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const InjuryAdaptationNotesScreen(),
          ),
        );
      },
      child: _buildInfoCard(
        title: 'Injury / Adaptation Notes',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              Icon(Icons.notes_outlined, size: 48, color: AppColors.lightGrey2),
              const SizedBox(height: 16),
              const Text(
                'Track any injuries, modifications, or special adaptations for your workouts',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return TextButton(
      onPressed: _signOut,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout, color: AppColors.grey),
          SizedBox(width: 8),
          Text('Logout', style: TextStyle(color: AppColors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildProgressCard(UserModel user) {
    final progress = user.progress;
    final completedWorkouts = progress['completedWorkouts']?.toString() ?? '0';
    final mealsCompleted = progress['mealsCompleted']?.toString() ?? '0';
    final weeks = progress['weeks']?.toString() ?? '0';

    return _buildInfoCard(
      title: 'Your Progress',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatColumn(completedWorkouts, 'Workouts'),
            _buildStatColumn(mealsCompleted, 'Meals Completed'),
            _buildStatColumn(weeks, 'Weeks'),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BadgesStreaksScreen(),
          ),
        );
      },
      child: _buildInfoCard(
        title: 'Badges & Streaks',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBadgeIconPlaceholder(Icons.person_outline),
                  const SizedBox(width: 24),
                  _buildBadgeIconPlaceholder(Icons.track_changes_outlined),
                  const SizedBox(width: 24),
                  _buildBadgeIconPlaceholder(Icons.calendar_today_outlined),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Earn badges and maintain streaks as you progress through your fitness journey',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeIconPlaceholder(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: AppColors.mediumGrey, size: 32),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    bool isPrimary = false,
    required VoidCallback onPressed,
  }) {
    final color = isPrimary ? AppColors.white : AppColors.primaryGreen;
    final backgroundColor =
        isPrimary ? AppColors.primaryGreen : AppColors.white;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: color,
        backgroundColor: backgroundColor,
        elevation: 0,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(
            color: isPrimary ? Colors.transparent : AppColors.primaryGreen,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withAlpha(25),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

Widget _buildStatColumn(String value, String label) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        value,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.strongBlue,
        ),
      ),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 16)),
    ],
  );
}
