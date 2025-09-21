import 'package:adaptifit/src/core/models/user_model.dart';
import 'package:adaptifit/src/screens/auth/change_password_screen.dart';
import 'package:adaptifit/src/screens/auth/welcome_screen.dart';
import 'package:adaptifit/src/screens/core_app/settings_screen.dart';
import 'package:adaptifit/src/services/firestore_service.dart';
import 'package:adaptifit/src/services/n8n_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _showRewritePlanConfirmationDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rewrite Plan?'),
          content: const Text(
              'Are you sure you want to rewrite your plan? This will generate a new plan based on your onboarding answers.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Rewrite'),
              onPressed: () {
                _n8nService.triggerPlanGeneration(
                  userId: user.id,
                  onboardingAnswers: user.onboardingAnswers,
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Your plan is being regenerated. This may take a few minutes.'),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Profile',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
          CircleAvatar(
            backgroundColor: const Color(0xFF1EB955),
            radius: 20,
            child: Text(
              _currentUser?.email?.substring(0, 1).toUpperCase() ?? '?',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
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
                _buildNotesCard(user),
                const SizedBox(height: 24),
                _buildOnboardingAnswersCard(user),
                const SizedBox(height: 24),
                _buildBadgesCard(user),
                const SizedBox(height: 32),
                _buildActionButton(
                  icon: Icons.refresh,
                  text: 'Rewrite Plan',
                  isPrimary: true,
                  onPressed: () => _showRewritePlanConfirmationDialog(user),
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  icon: Icons.lock_outline,
                  text: 'Change Password',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildLogoutButton(),
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
          radius: 30,
          backgroundColor: const Color(0xFF1EB955),
          child: Text(
            user.name.isNotEmpty
                ? user.name.substring(0, 1).toUpperCase()
                : '?',
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
                'Member since ${DateFormat('MMM yyyy').format(user.createdAt.toDate())}',
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountInfoCard(UserModel user) {
    return _buildInfoCard(
      title: 'Account Information',
      child: ListTile(
        leading: const Icon(Icons.email_outlined, color: Colors.grey),
        title: const Text('Email'),
        subtitle: Text(
          user.email,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildNotesCard(UserModel user) {
    final injuries = user.onboardingCompleted
        ? user.onboardingAnswers['injuries'] ?? 'No injuries reported.'
        : 'Onboarding not complete.';

    return _buildInfoCard(
      title: 'Injury / Adaptation Notes',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.notes_outlined, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              injuries,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingAnswersCard(UserModel user) {
    final answers = user.onboardingAnswers;

    if (!user.onboardingCompleted || answers.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Widget> answerWidgets = [];
    answers.forEach((key, value) {
      if (key == 'injuries') return;

      String displayKey = key;
      String displayValue = value.toString();

      displayKey = key.replaceAllMapped(RegExp(r'(?<=[a-z])[A-Z]'), (match) => ' ${match.group(0)}');
      displayKey = displayKey[0].toUpperCase() + displayKey.substring(1);

      if (value is List) {
        displayValue = value.join(', ');
      }

      answerWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$displayKey: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text(displayValue),
              ),
            ],
          ),
        ),
      );
    });

    return _buildInfoCard(
      title: 'Onboarding Summary',
      child: Column(
        children: answerWidgets,
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
    final currentStreak = progress['currentStreak']?.toString() ?? '0';
    final longestStreak = progress['longestStreak']?.toString() ?? '0';

    return _buildInfoCard(
      title: 'Your Progress',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatColumn(completedWorkouts, 'Workouts'),
            _buildStatColumn(currentStreak, 'Current Streak'),
            _buildStatColumn(longestStreak, 'Longest Streak'),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesCard(UserModel user) {
    final badges = List<String>.from(user.progress['badges'] ?? []);

    return _buildInfoCard(
      title: 'Badges & Streaks',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (badges.isEmpty)
              const Text(
                'Earn badges by completing workouts and maintaining streaks!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              )
            else
              Wrap(
                spacing: 16.0,
                runSpacing: 16.0,
                alignment: WrapAlignment.center,
                children: badges.map((badge) => _buildBadgeIcon(badge)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeIcon(String badgeName) {
    IconData iconData;
    switch (badgeName) {
      case 'first_workout':
        iconData = Icons.fitness_center;
        break;
      case '10_workouts':
        iconData = Icons.star;
        break;
      case '5_day_streak':
        iconData = Icons.local_fire_department;
        break;
      default:
        iconData = Icons.emoji_events;
    }
    return Icon(iconData, color: const Color(0xFF1EB955), size: 30);
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
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1EB955),
        ),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.grey)),
    ],
  );
}
