import 'package:adaptifit/src/constants/app_colors.dart';
import 'package:adaptifit/src/providers/auth_provider.dart';
import 'package:adaptifit/src/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:adaptifit/src/models/user.dart';
import 'package:adaptifit/src/screens/auth/change_password_screen.dart';
import 'package:adaptifit/src/screens/auth/welcome_screen.dart';
import 'package:adaptifit/src/screens/onboarding/onboarding_question_screen.dart';
import 'package:adaptifit/src/screens/core_app/injury_adaptation_notes_screen.dart';
import 'package:adaptifit/src/screens/core_app/badges_streaks_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authServiceProvider.notifier).signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userValue = ref.watch(userProvider);

    return Scaffold(
      backgroundColor:
          AppColors.neutralGray, // Set background color for the whole screen
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0,
        title: const Text('Profile',
            style: TextStyle(
                color: AppColors.darkText,
                fontWeight: FontWeight.bold,
                fontSize: 28)),
        actions: [
          //   Padding(
          //     padding: const EdgeInsets.only(right: 16.0),
          //     child: CircleAvatar(
          //       backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
          //       child: const Text('A', // Placeholder for your app logo
          //           style: TextStyle(
          //               color: AppColors.primaryGreen,
          //               fontWeight: FontWeight.w900,
          //               fontSize: 18)),
          //     ),
          //   ),
          //
        ],
      ),
      body: userValue.when(
        data: (user) => SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              _buildProfileHeader(user),
              const SizedBox(height: 24),
              _buildAccountInfoCard(user),
              const SizedBox(height: 24),
              _buildNotesCard(context),
              const SizedBox(height: 24),
              _buildBadgesCard(context),
              const SizedBox(height: 32),
              _buildActionButton(
                icon: Icons.refresh,
                text: 'Rewrite Plan',
                isPrimary: true,
                onPressed: () {
                  final onboardingProviderNotifier = ref.read(onboardingProvider.notifier);
                  onboardingProviderNotifier.setAnswers(user.onboardingAnswers);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const OnboardingQuestionScreen()));
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
                          builder: (context) =>
                              const ChangePasswordScreen()));
                },
              ),
              const SizedBox(height: 16),
              _buildLogoutButton(context, ref),
              const SizedBox(height: 24),
              const Text('Adaptifit v2.1.0',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 16),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  // A standalone card for the main profile header
  Widget _buildProfileHeader(User user) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primaryGreen,
            child: Text(
              user.name.isNotEmpty
                  ? user.name.substring(0, 1).toUpperCase()
                  : '?',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText)),
              const SizedBox(height: 4),
              Text(
                'Member since ${DateFormat('MMM yyyy').format(DateTime.parse(user.createdAt))}',
                style: const TextStyle(color: AppColors.grey, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // A generic card widget to keep styling consistent
  Widget _buildInfoCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildAccountInfoCard(User user) {
    return _buildInfoCard(
      title: 'Account Information',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.neutralGray, // Inset background color
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.email_outlined, color: AppColors.darkGrey),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Email',
                    style: TextStyle(color: AppColors.grey, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: const TextStyle(
                      color: AppColors.darkText,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const InjuryAdaptationNotesScreen()));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.lightGrey2,
                    width: 2,
                    style: BorderStyle.solid),
              ),
              child: const Icon(Icons.description_outlined,
                  size: 28, color: AppColors.darkGrey),
            ),
            const SizedBox(height: 12),
            const Text('Injury / Adaptation Notes',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText)),
            const SizedBox(height: 8),
            const Text(
              'Track any injuries, modifications, or special adaptations for your workouts',
              textAlign: TextAlign.center,
              style: 
                  TextStyle(color: AppColors.grey, fontSize: 15, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const BadgesStreaksScreen()));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBadgeIconPlaceholder(Icons.emoji_events_outlined),
                const SizedBox(width: 20),
                _buildBadgeIconPlaceholder(
                    Icons.local_fire_department_outlined),
                const SizedBox(width: 20),
                _buildBadgeIconPlaceholder(Icons.calendar_today_outlined),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Badges & Streaks',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText)),
            const SizedBox(height: 8),
            const Text(
              'Earn badges and maintain streaks as you progress through your fitness journey',
              textAlign: TextAlign.center,
              style: 
                  TextStyle(color: AppColors.grey, fontSize: 15, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeIconPlaceholder(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.neutralGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.darkGrey, size: 28),
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
      required String text,
      bool isPrimary = false,
      required VoidCallback onPressed}) {
    final color = isPrimary ? AppColors.white : AppColors.primaryGreen;
    final backgroundColor =
        isPrimary ? AppColors.primaryGreen : Colors.transparent;
    final borderColor = isPrimary ? Colors.transparent : AppColors.primaryGreen;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: color,
          backgroundColor: backgroundColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: borderColor, width: 1.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(text,
                style: 
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return TextButton(
      onPressed: () => _signOut(context, ref),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout, size: 20),
          SizedBox(width: 8),
          Text('Logout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: AppColors.grey, fontSize: 14)),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }
}
