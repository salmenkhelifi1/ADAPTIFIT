import 'package:adaptifit/src/models/calendar_entry.dart';
import 'package:adaptifit/src/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:adaptifit/src/screens/core_app/daily_plan_detail_screen.dart';
import 'package:adaptifit/src/constants/app_colors.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<CalendarEntry>> _calendarEntriesFuture;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, CalendarEntry> _calendarData = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _calendarEntriesFuture = _apiService.getCalendarEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Calendar',
          style: TextStyle(
              color: AppColors.darkText,
              fontWeight: FontWeight.bold,
              fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<CalendarEntry>>(
        future: _calendarEntriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.hasData) {
            _calendarData = {
              for (var entry in snapshot.data!)
                DateFormat('yyyy-MM-dd').format(entry.date): entry
            };
            if (kDebugMode) {
              print(
                  "[Calendar Debug] Loaded Data Keys: ${_calendarData.keys.toList()}");
            }
          }
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Text(
                  'Select a date to see its workout and nutrition details.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.subtitleGray, fontSize: 16),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 2,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
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
                        color: const Color(0xFFE8F5E9), // Solid light green
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle:
                          const TextStyle(color: AppColors.darkText),
                      selectedDecoration: const BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      defaultTextStyle:
                          const TextStyle(fontWeight: FontWeight.normal),
                      weekendTextStyle:
                          const TextStyle(fontWeight: FontWeight.normal),
                      selectedTextStyle: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      outsideDaysVisible: false,
                    ),
                    headerStyle: const HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      titleTextStyle:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        final dateString =
                            DateFormat('yyyy-MM-dd').format(date);
                        final calendarDay = _calendarData[dateString];

                        if (kDebugMode) {
                          if (calendarDay != null) {
                            print(
                                "[Calendar Debug] Found Match for: $dateString");
                          }
                        }

                        if (calendarDay != null) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (calendarDay.workoutId.isNotEmpty)
                                _buildEventDot(AppColors.primaryGreen),
                              if (calendarDay.nutritionIds.isNotEmpty)
                                _buildEventDot(AppColors.secondaryBlue),
                            ],
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventDot(Color color) {
    return Container(
      width: 4,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 1.5),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}