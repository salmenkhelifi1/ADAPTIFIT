import 'package:adaptifit/src/utils/message_utils.dart';
import 'package:adaptifit/src/screens/core_app/badges_streaks_screen.dart';
import 'package:adaptifit/src/screens/core_app/injury_adaptation_notes_screen.dart';
import 'package:adaptifit/src/core/models/user_model.dart';
import 'package:adaptifit/src/screens/auth/change_password_screen.dart';
import 'package:adaptifit/src/screens/auth/welcome_screen.dart';
import 'package:adaptifit/src/services/firestore_service.dart';
import 'package:adaptifit/src/services/n8n_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:adaptifit/src/screens/core_app/rewrite_plan_screen.dart';

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

  @override
  void initState() {
    super.initState();
    if (_currentUser != null) {
      _userStream = _firestoreService.getUser();
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
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF0F4F8),
        elevation: 0,
        title: const Text('Profile',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 28)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Color(0xFF1EB955),
              // You can replace this with your actual logo asset
              child: Text('A',
                  style: TextStyle(
                      color: Colors.white,
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
          backgroundColor: const Color(0xFF1EB955),
          child: Text(
            user.name.isNotEmpty
                ? user.name.substring(0, 1).toUpperCase()
                : '?',
            style: const TextStyle(
                color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
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
                style: const TextStyle(color: Colors.grey, fontSize: 15)),
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
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.email_outlined, color: Colors.grey[700]),
        ),
        title: const Text('Email', style: TextStyle(color: Colors.grey)),
        subtitle: Text(
          user.email,
          style: const TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
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
              Icon(Icons.notes_outlined, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text(
                'Track any injuries, modifications, or special adaptations for your workouts',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
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
          Icon(Icons.logout, color: Colors.grey),
          SizedBox(width: 8),
          Text('Logout', style: TextStyle(color: Colors.grey, fontSize: 16)),
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
                style: TextStyle(color: Colors.grey, fontSize: 16),
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
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: Colors.grey[400], size: 32),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    bool isPrimary = false,
    required VoidCallback onPressed,
  }) {
    final color = isPrimary ? Colors.white : const Color(0xFF1EB955);
    final backgroundColor = isPrimary ? const Color(0xFF1EB955) : Colors.white;

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
            color: isPrimary ? Colors.transparent : const Color(0xFF1EB955),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
          color: Color(0xFF0D47A1), // A nice, strong blue
        ),
      ),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
    ],
  );
}
