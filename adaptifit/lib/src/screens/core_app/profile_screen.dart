import 'package:adaptifit/src/core/models/user_model.dart';
import 'package:adaptifit/src/screens/auth/welcome_screen.dart';
import 'package:adaptifit/src/services/firestore_service.dart';
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
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  Future<UserModel?>? _userFuture;

  @override
  void initState() {
    super.initState();
    if (_currentUser != null) {
      _userFuture =
          _firestoreService.getUser(_currentUser!.uid).then((snapshot) {
        if (snapshot.exists) {
          return UserModel.fromFirestore(snapshot);
        }
        return null;
      });
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (Route<dynamic> route) => false,
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
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF1EB955),
              radius: 20,
              child: Text(
                _currentUser?.email?.substring(0, 1).toUpperCase() ?? '?',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<UserModel?>(
        future: _userFuture,
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
          if (!snapshot.hasData || snapshot.data == null) {
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
                _buildProgressCard(), // This still uses placeholder data
                const SizedBox(height: 24),
                _buildNotesCard(user),
                const SizedBox(height: 24),
                _buildOnboardingAnswersCard(user),
                const SizedBox(height: 24),
                _buildBadgesCard(),
                const SizedBox(height: 32),
                _buildActionButton(
                    icon: Icons.refresh, text: 'Rewrite Plan', isPrimary: true),
                const SizedBox(height: 16),
                _buildActionButton(
                    icon: Icons.lock_outline, text: 'Change Password'),
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

  // --- Unchanged UI Widgets with placeholder data ---

  Widget _buildProgressCard() {
    return _buildInfoCard(
      title: 'Your Progress',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatColumn('0', 'Workouts'),
            _buildStatColumn('0', 'Weeks'),
            _buildStatColumn('0', 'Goals Met'),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesCard() {
    return _buildInfoCard(
      title: 'Badges & Streaks',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_pin_circle_outlined,
                    color: Colors.grey[400], size: 30),
                const SizedBox(width: 16),
                Icon(Icons.local_fire_department_outlined,
                    color: Colors.grey[400], size: 30),
                const SizedBox(width: 16),
                Icon(Icons.calendar_month_outlined,
                    color: Colors.grey[400], size: 30),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Earn badges and maintain streaks as you progress through your fitness journey',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      {required IconData icon, required String text, bool isPrimary = false}) {
    final color = isPrimary ? Colors.white : const Color(0xFF1EB955);
    final backgroundColor = isPrimary ? const Color(0xFF1EB955) : Colors.white;

    return ElevatedButton(
      onPressed: () {},
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
