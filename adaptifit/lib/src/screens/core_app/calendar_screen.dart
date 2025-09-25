import 'package:adaptifit/src/core/models/models.dart';
import 'package:adaptifit/src/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:adaptifit/src/screens/core_app/daily_plan_detail_screen.dart'; // Import the new detail screen

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, Calendar> _calendarData = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: StreamBuilder<UserModel>(
        stream: _firestoreService.getUser(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = userSnapshot.data;

          return StreamBuilder<List<Calendar>>(
            stream: _firestoreService.getCalendarEntries(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Check if onboarding is complete but plan is not yet generated
              if (user != null &&
                  user.onboardingAnswers.isNotEmpty &&
                  !snapshot.hasData) {
                return _buildGeneratingPlanMessage();
              }

              if (snapshot.hasData) {
                _calendarData = {
                  for (var entry in snapshot.data!)
                    DateFormat('yyyy-MM-dd').parseUtc(entry.date): entry
                };
              }
              return Padding(
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
                            color: Colors.grey.withAlpha(25),
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
                          // Navigate to the detail screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DailyPlanDetailScreen(date: selectedDay),
                            ),
                          );
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
                          titleTextStyle: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) {
                            final calendarDay = _calendarData[day];
                            return _buildDayCell(
                                day, calendarDay, Colors.black);
                          },
                          selectedBuilder: (context, day, focusedDay) {
                            final calendarDay = _calendarData[day];
                            return _buildDayCell(day, calendarDay, Colors.white,
                                isSelected: true);
                          },
                          todayBuilder: (context, day, focusedDay) {
                            final calendarDay = _calendarData[day];
                            return _buildDayCell(day, calendarDay, Colors.black,
                                isToday: true);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGeneratingPlanMessage() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Generating your personalized plan...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
            SizedBox(height: 10),
            Text(
              'This may take a few minutes. Please check back soon!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell(
      DateTime day, Calendar? calendarDay, Color textColor,
      {bool isSelected = false, bool isToday = false}) {
    Color todayColor = isToday ? const Color(0xFFD4EDDA) : Colors.transparent;

    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1EB955) : todayColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 4), // Space for dots
            Text(
              '${day.day}',
              style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isToday ? Colors.black : textColor)),
            ),
            if (calendarDay != null &&
                (calendarDay.hasWorkout || calendarDay.hasNutrition))
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (calendarDay.hasWorkout)
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (calendarDay.hasNutrition)
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              )
            else
              const SizedBox(height: 8), // Placeholder to keep alignment
          ],
        ),
      ),
    );
  }
}
