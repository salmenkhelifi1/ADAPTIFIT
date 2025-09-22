import 'package:cloud_firestore/cloud_firestore.dart';

class Calendar {
  final String calendarId;
  final String userId;
  final Timestamp date;
  final List<String> workouts;
  final String? notes;
  final String status;
  final bool completed;
  final Timestamp? reminder;

  Calendar({
    required this.calendarId,
    required this.userId,
    required this.date,
    required this.workouts,
    this.notes,
    required this.status,
    required this.completed,
    this.reminder,
  });

  factory Calendar.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Calendar(
      calendarId: doc.id,
      userId: data['userId'] ?? '',
      date: data['date'] ?? Timestamp.now(),
      workouts: List<String>.from(data['workouts'] ?? []),
      notes: data['notes'],
      status: data['status'] ?? 'scheduled',
      completed: data['completed'] ?? false,
      reminder: data['reminder'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': date,
      'workouts': workouts,
      'notes': notes,
      'status': status,
      'completed': completed,
      'reminder': reminder,
    };
  }
}
