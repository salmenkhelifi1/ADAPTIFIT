// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$plansHash() => r'dd87d70f9ee09e50912a420054368501abfeb61e';

/// See also [plans].
@ProviderFor(plans)
final plansProvider = FutureProvider<List<Plan>>.internal(
  plans,
  name: r'plansProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$plansHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlansRef = FutureProviderRef<List<Plan>>;
String _$planWorkoutsHash() => r'e3d715055899eaf74a99503d5a8c3e76dfcc51b7';

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

/// See also [planWorkouts].
@ProviderFor(planWorkouts)
const planWorkoutsProvider = PlanWorkoutsFamily();

/// See also [planWorkouts].
class PlanWorkoutsFamily extends Family<AsyncValue<List<Workout>>> {
  /// See also [planWorkouts].
  const PlanWorkoutsFamily();

  /// See also [planWorkouts].
  PlanWorkoutsProvider call(
    String planId,
  ) {
    return PlanWorkoutsProvider(
      planId,
    );
  }

  @override
  PlanWorkoutsProvider getProviderOverride(
    covariant PlanWorkoutsProvider provider,
  ) {
    return call(
      provider.planId,
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
  String? get name => r'planWorkoutsProvider';
}

/// See also [planWorkouts].
class PlanWorkoutsProvider extends AutoDisposeFutureProvider<List<Workout>> {
  /// See also [planWorkouts].
  PlanWorkoutsProvider(
    String planId,
  ) : this._internal(
          (ref) => planWorkouts(
            ref as PlanWorkoutsRef,
            planId,
          ),
          from: planWorkoutsProvider,
          name: r'planWorkoutsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$planWorkoutsHash,
          dependencies: PlanWorkoutsFamily._dependencies,
          allTransitiveDependencies:
              PlanWorkoutsFamily._allTransitiveDependencies,
          planId: planId,
        );

  PlanWorkoutsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.planId,
  }) : super.internal();

  final String planId;

  @override
  Override overrideWith(
    FutureOr<List<Workout>> Function(PlanWorkoutsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PlanWorkoutsProvider._internal(
        (ref) => create(ref as PlanWorkoutsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        planId: planId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Workout>> createElement() {
    return _PlanWorkoutsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PlanWorkoutsProvider && other.planId == planId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, planId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PlanWorkoutsRef on AutoDisposeFutureProviderRef<List<Workout>> {
  /// The parameter `planId` of this provider.
  String get planId;
}

class _PlanWorkoutsProviderElement
    extends AutoDisposeFutureProviderElement<List<Workout>>
    with PlanWorkoutsRef {
  _PlanWorkoutsProviderElement(super.provider);

  @override
  String get planId => (origin as PlanWorkoutsProvider).planId;
}

String _$planNutritionHash() => r'75aad2961ef69e118fa8207f1ea68f819fdf1b08';

/// See also [planNutrition].
@ProviderFor(planNutrition)
const planNutritionProvider = PlanNutritionFamily();

/// See also [planNutrition].
class PlanNutritionFamily extends Family<AsyncValue<Nutrition?>> {
  /// See also [planNutrition].
  const PlanNutritionFamily();

  /// See also [planNutrition].
  PlanNutritionProvider call(
    String planId,
  ) {
    return PlanNutritionProvider(
      planId,
    );
  }

  @override
  PlanNutritionProvider getProviderOverride(
    covariant PlanNutritionProvider provider,
  ) {
    return call(
      provider.planId,
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
  String? get name => r'planNutritionProvider';
}

/// See also [planNutrition].
class PlanNutritionProvider extends AutoDisposeFutureProvider<Nutrition?> {
  /// See also [planNutrition].
  PlanNutritionProvider(
    String planId,
  ) : this._internal(
          (ref) => planNutrition(
            ref as PlanNutritionRef,
            planId,
          ),
          from: planNutritionProvider,
          name: r'planNutritionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$planNutritionHash,
          dependencies: PlanNutritionFamily._dependencies,
          allTransitiveDependencies:
              PlanNutritionFamily._allTransitiveDependencies,
          planId: planId,
        );

  PlanNutritionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.planId,
  }) : super.internal();

  final String planId;

  @override
  Override overrideWith(
    FutureOr<Nutrition?> Function(PlanNutritionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PlanNutritionProvider._internal(
        (ref) => create(ref as PlanNutritionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        planId: planId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Nutrition?> createElement() {
    return _PlanNutritionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PlanNutritionProvider && other.planId == planId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, planId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PlanNutritionRef on AutoDisposeFutureProviderRef<Nutrition?> {
  /// The parameter `planId` of this provider.
  String get planId;
}

class _PlanNutritionProviderElement
    extends AutoDisposeFutureProviderElement<Nutrition?> with PlanNutritionRef {
  _PlanNutritionProviderElement(super.provider);

  @override
  String get planId => (origin as PlanNutritionProvider).planId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
