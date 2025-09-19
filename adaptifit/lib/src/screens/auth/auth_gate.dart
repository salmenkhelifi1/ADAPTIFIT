import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:adaptifit/src/screens/auth/welcome_screen.dart';
import 'package:adaptifit/src/screens/core_app/main_scaffold.dart';
import 'package:adaptifit/src/screens/onboarding/onboarding_question_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While the connection is waiting, show a loading indicator.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If the snapshot has data, it means a user is logged in.
        if (snapshot.hasData) {
          // User is logged in, now check if onboarding is completed.
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              }
              if (userSnapshot.hasError) {
                return const Scaffold(
                    body: Center(child: Text('Error fetching user data.')));
              }
              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                // This case should ideally not happen if user is created correctly on sign up
                return const Scaffold(
                    body: Center(child: Text('User document not found.')));
              }

              final userData = userSnapshot.data!.data() as Map<String, dynamic>;
              if (userData['onboardingCompleted'] == true) {
                return const MainScaffold();
              } else {
                return const OnboardingQuestionScreen();
              }
            },
          );
        }

        // Otherwise, no user is logged in.
        return const WelcomeScreen();
      },
    );
  }
}
