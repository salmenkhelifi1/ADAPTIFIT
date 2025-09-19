import 'package:adaptifit/src/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'daily_plan_detail_screen.dart'; // Import the new detail screen

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  Map<DateTime, List<dynamic>> _events = {};

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchCalendarData();
  }

  Future<void> _fetchCalendarData() async {
    if (_currentUser == null) return;

    final calendarData = await _firestoreService.getCalendarData(_currentUser!.uid);
    final Map<DateTime, List<dynamic>> events = {};

    for (var doc in calendarData.docs) {
      try {
        final date = DateTime.parse(doc.id);
        final normalizedDate = DateTime.utc(date.year, date.month, date.day);
        if (events.containsKey(normalizedDate)) {
          events[normalizedDate]!.add(doc.data());
        } else {
          events[normalizedDate] = [doc.data()];
        }
      } catch (e) {
        print('Error parsing date from document ID: ${doc.id}');
      }
    }

    if (mounted) {
      setState(() {
        _events = events;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F4F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Calendar',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Select a date to see its workout and nutrition details.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  final normalizedDay = DateTime.utc(selectedDay.year, selectedDay.month, selectedDay.day);
                  final eventsForDay = _events[normalizedDay] ?? [];

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DailyPlanDetailScreen(date: selectedDay, events: eventsForDay),
                    ),
                  );
                },
                eventLoader: (day) {
                  final normalizedDay = DateTime.utc(day.year, day.month, day.day);
                  return _events[normalizedDay] ?? [];
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.green[200],
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFF1EB955),
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  titleTextStyle:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        right: 1,
                        bottom: 1,
                        child: _buildEventsMarker(day, events),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsMarker(DateTime day, List events) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }
}