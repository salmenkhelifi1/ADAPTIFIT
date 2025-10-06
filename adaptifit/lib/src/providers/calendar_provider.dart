import 'package:adaptifit/src/models/calendar_entry.dart';
import 'package:adaptifit/src/providers/api_service_provider.dart';
import 'package:adaptifit/src/providers/nutrition_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final calendarEntriesProvider = FutureProvider<List<CalendarEntry>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getCalendarEntries();
});

final calendarEntryProvider = FutureProvider.family<CalendarEntry?, DateTime>((ref, date) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getCalendarEntry(date);
});

final todayCalendarEntryProvider = FutureProvider<CalendarEntry?>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getCalendarEntry(DateTime.now());
});