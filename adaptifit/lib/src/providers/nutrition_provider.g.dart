// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$nutritionHash() => r'a92248e1d3337959baa41eabf5179974cab4d639';

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

/// See also [nutrition].
@ProviderFor(nutrition)
const nutritionProvider = NutritionFamily();

/// See also [nutrition].
class NutritionFamily extends Family<AsyncValue<Nutrition>> {
  /// See also [nutrition].
  const NutritionFamily();

  /// See also [nutrition].
  NutritionProvider call(
    String nutritionId,
  ) {
    return NutritionProvider(
      nutritionId,
    );
  }

  @override
  NutritionProvider getProviderOverride(
    covariant NutritionProvider provider,
  ) {
    return call(
      provider.nutritionId,
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
  String? get name => r'nutritionProvider';
}

/// See also [nutrition].
class NutritionProvider extends FutureProvider<Nutrition> {
  /// See also [nutrition].
  NutritionProvider(
    String nutritionId,
  ) : this._internal(
          (ref) => nutrition(
            ref as NutritionRef,
            nutritionId,
          ),
          from: nutritionProvider,
          name: r'nutritionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$nutritionHash,
          dependencies: NutritionFamily._dependencies,
          allTransitiveDependencies: NutritionFamily._allTransitiveDependencies,
          nutritionId: nutritionId,
        );

  NutritionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.nutritionId,
  }) : super.internal();

  final String nutritionId;

  @override
  Override overrideWith(
    FutureOr<Nutrition> Function(NutritionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NutritionProvider._internal(
        (ref) => create(ref as NutritionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        nutritionId: nutritionId,
      ),
    );
  }

  @override
  FutureProviderElement<Nutrition> createElement() {
    return _NutritionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NutritionProvider && other.nutritionId == nutritionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, nutritionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NutritionRef on FutureProviderRef<Nutrition> {
  /// The parameter `nutritionId` of this provider.
  String get nutritionId;
}

class _NutritionProviderElement extends FutureProviderElement<Nutrition>
    with NutritionRef {
  _NutritionProviderElement(super.provider);

  @override
  String get nutritionId => (origin as NutritionProvider).nutritionId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
