import 'package:adaptifit/src/models/calendar_entry.dart';
import 'package:adaptifit/src/providers/api_service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calendar_provider.g.dart';

@Riverpod(keepAlive: true)
Future<List<CalendarEntry>> calendarEntries(CalendarEntriesRef ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final entries = await apiService.getCalendarEntries();
  return entries;
}

@Riverpod(keepAlive: true)
Future<CalendarEntry?> todayCalendarEntry(TodayCalendarEntryRef ref) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getCalendarEntry(DateTime.now());
}

@riverpod
Future<CalendarEntry?> calendarEntry(CalendarEntryRef ref, DateTime date) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getCalendarEntry(date);
}
