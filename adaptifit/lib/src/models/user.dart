class User {
  final String id;
  final String name;
  final String email;
  final bool onboardingCompleted;
  final Map<String, dynamic> onboardingAnswers;
  final String createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.onboardingCompleted,
    required this.onboardingAnswers,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final userData = json['data'] ?? json;
    return User(
      id: userData['_id'],
      name: userData['name'] ?? '',
      email: userData['email'] ?? '',
      onboardingCompleted: userData['onboardingCompleted'] ?? false,
      onboardingAnswers: Map<String, dynamic>.from(userData['onboardingAnswers'] ?? {}),
      createdAt: userData['createdAt'] ?? DateTime.now().toIso8601String(),
    );
  }
}
