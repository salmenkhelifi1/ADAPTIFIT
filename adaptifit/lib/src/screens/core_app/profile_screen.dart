import 'package:flutter/material.dart';
import '/src/screens/auth/sign_in_screen.dart'; // Import the sign-in screen for logout navigation

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF0F4F8,
      ), // Light background color from design
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Color(0xFF1EB955),
              radius: 20,
              child: Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildAccountInfoCard(),
            const SizedBox(height: 24),
            _buildProgressCard(),
            const SizedBox(height: 24),
            _buildNotesCard(),
            const SizedBox(height: 24),
            _buildBadgesCard(),
            const SizedBox(height: 32),
            _buildActionButton(
              context: context,
              icon: Icons.refresh,
              text: 'Rewrite Plan',
              isPrimary: true,
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              context: context,
              icon: Icons.lock_outline,
              text: 'Change Password',
            ),
            const SizedBox(height: 16),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return const Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Color(0xFF1EB955),
          child: Text(
            'A',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alex Johnson',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Member since Jan 2024',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountInfoCard() {
    return _buildInfoCard(
      title: 'Account Information',
      child: const ListTile(
        leading: Icon(Icons.email_outlined, color: Colors.grey),
        title: Text('Email'),
        subtitle: Text(
          'alex.johnson@email.com',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return _buildInfoCard(
      title: 'Your Progress',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatColumn('156', 'Workouts'),
            _buildStatColumn('23', 'Weeks'),
            _buildStatColumn('12', 'Goals Met'),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return _buildInfoCard(
      title: 'Injury / Adaptation Notes',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.notes_outlined, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 8),
            const Text(
              'Track any injuries, modifications, or special adaptations for your workouts',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
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
                Icon(
                  Icons.person_pin_circle_outlined,
                  color: Colors.grey[400],
                  size: 30,
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.local_fire_department_outlined,
                  color: Colors.grey[400],
                  size: 30,
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.grey[400],
                  size: 30,
                ),
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

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String text,
    bool isPrimary = false,
  }) {
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

  Widget _buildLogoutButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        // This will clear the navigation stack and go to the SignInScreen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SignInScreen()),
          (Route<dynamic> route) => false,
        );
      },
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
