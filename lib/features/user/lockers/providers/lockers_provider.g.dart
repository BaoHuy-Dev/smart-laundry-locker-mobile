// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lockers_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$lockerBoxesHash() => r'507c3e8071f9657382e157712e846cd8c8377c46';

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

/// See also [lockerBoxes].
@ProviderFor(lockerBoxes)
const lockerBoxesProvider = LockerBoxesFamily();

/// See also [lockerBoxes].
class LockerBoxesFamily extends Family<AsyncValue<List<Box>>> {
  /// See also [lockerBoxes].
  const LockerBoxesFamily();

  /// See also [lockerBoxes].
  LockerBoxesProvider call(int lockerId) {
    return LockerBoxesProvider(lockerId);
  }

  @override
  LockerBoxesProvider getProviderOverride(
    covariant LockerBoxesProvider provider,
  ) {
    return call(provider.lockerId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'lockerBoxesProvider';
}

/// See also [lockerBoxes].
class LockerBoxesProvider extends AutoDisposeFutureProvider<List<Box>> {
  /// See also [lockerBoxes].
  LockerBoxesProvider(int lockerId)
    : this._internal(
        (ref) => lockerBoxes(ref as LockerBoxesRef, lockerId),
        from: lockerBoxesProvider,
        name: r'lockerBoxesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$lockerBoxesHash,
        dependencies: LockerBoxesFamily._dependencies,
        allTransitiveDependencies: LockerBoxesFamily._allTransitiveDependencies,
        lockerId: lockerId,
      );

  LockerBoxesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.lockerId,
  }) : super.internal();

  final int lockerId;

  @override
  Override overrideWith(
    FutureOr<List<Box>> Function(LockerBoxesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LockerBoxesProvider._internal(
        (ref) => create(ref as LockerBoxesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        lockerId: lockerId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Box>> createElement() {
    return _LockerBoxesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LockerBoxesProvider && other.lockerId == lockerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, lockerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LockerBoxesRef on AutoDisposeFutureProviderRef<List<Box>> {
  /// The parameter `lockerId` of this provider.
  int get lockerId;
}

class _LockerBoxesProviderElement
    extends AutoDisposeFutureProviderElement<List<Box>>
    with LockerBoxesRef {
  _LockerBoxesProviderElement(super.provider);

  @override
  int get lockerId => (origin as LockerBoxesProvider).lockerId;
}

String _$lockersNotifierHash() => r'9718cc1ba3c0f1931b60cdde3eaaa0e557a6c576';

/// See also [LockersNotifier].
@ProviderFor(LockersNotifier)
final lockersNotifierProvider =
    AutoDisposeAsyncNotifierProvider<LockersNotifier, List<Locker>>.internal(
      LockersNotifier.new,
      name: r'lockersNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$lockersNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LockersNotifier = AutoDisposeAsyncNotifier<List<Locker>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
