import 'package:firebase_auth/firebase_auth.dart';
import 'package:adaptifit/src/services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Stream to listen for authentication changes
  Stream<User?> get user => _auth.authStateChanges();

  // Get the currently signed-in user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign up with Email & Password
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required Map<String, dynamic>
        onboardingAnswers, // Added to accept onboarding data
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Create a new document for the user with the initial info
        await _firestoreService.createUserDocument(
          uid: user.uid,
          email: email,
          firstName: firstName,
          onboardingAnswers: onboardingAnswers, // Pass the answers to Firestore
        );
      }
      return user;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    }
  }

  // Sign in with Email & Password
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
