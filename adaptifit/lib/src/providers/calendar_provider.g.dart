// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$calendarEntriesHash() => r'61fc03e58894d18a2f83b61922547603e1169d98';

/// See also [calendarEntries].
@ProviderFor(calendarEntries)
final calendarEntriesProvider = FutureProvider<List<CalendarEntry>>.internal(
  calendarEntries,
  name: r'calendarEntriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarEntriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CalendarEntriesRef = FutureProviderRef<List<CalendarEntry>>;
String _$todayCalendarEntryHash() =>
    r'82faf7f362d283f07c9ebf4c2c3c3bbbcedc5668';

/// See also [todayCalendarEntry].
@ProviderFor(todayCalendarEntry)
final todayCalendarEntryProvider = FutureProvider<CalendarEntry?>.internal(
  todayCalendarEntry,
  name: r'todayCalendarEntryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayCalendarEntryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayCalendarEntryRef = FutureProviderRef<CalendarEntry?>;
String _$calendarEntryHash() => r'f863fc0095b793259c62e8188bc73c70dc7fd04e';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [calendarEntry].
@ProviderFor(calendarEntry)
const calendarEntryProvider = CalendarEntryFamily();

/// See also [calendarEntry].
class CalendarEntryFamily extends Family<AsyncValue<CalendarEntry?>> {
  /// See also [calendarEntry].
  const CalendarEntryFamily();

  /// See also [calendarEntry].
  CalendarEntryProvider call(
    DateTime date,
  ) {
    return CalendarEntryProvider(
      date,
    );
  }

  @override
  CalendarEntryProvider getProviderOverride(
    covariant CalendarEntryProvider provider,
  ) {
    return call(
      provider.date,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'calendarEntryProvider';
}

/// See also [calendarEntry].
class CalendarEntryProvider extends AutoDisposeFutureProvider<CalendarEntry?> {
  /// See also [calendarEntry].
  CalendarEntryProvider(
    DateTime date,
  ) : this._internal(
          (ref) => calendarEntry(
            ref as CalendarEntryRef,
            date,
          ),
          from: calendarEntryProvider,
          name: r'calendarEntryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$calendarEntryHash,
          dependencies: CalendarEntryFamily._dependencies,
          allTransitiveDependencies:
              CalendarEntryFamily._allTransitiveDependencies,
          date: date,
        );

  CalendarEntryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final DateTime date;

  @override
  Override overrideWith(
    FutureOr<CalendarEntry?> Function(CalendarEntryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CalendarEntryProvider._internal(
        (ref) => create(ref as CalendarEntryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<CalendarEntry?> createElement() {
    return _CalendarEntryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarEntryProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CalendarEntryRef on AutoDisposeFutureProviderRef<CalendarEntry?> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _CalendarEntryProviderElement
    extends AutoDisposeFutureProviderElement<CalendarEntry?>
    with CalendarEntryRef {
  _CalendarEntryProviderElement(super.provider);

  @override
  DateTime get date => (origin as CalendarEntryProvider).date;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
