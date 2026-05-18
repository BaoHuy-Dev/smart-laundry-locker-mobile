// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$orderTrackingHash() => r'81a8c10680477abc1ec16ee4858d08a113d272f0';

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

/// See also [orderTracking].
@ProviderFor(orderTracking)
const orderTrackingProvider = OrderTrackingFamily();

/// See also [orderTracking].
class OrderTrackingFamily extends Family<AsyncValue<OrderTrackingDetail>> {
  /// See also [orderTracking].
  const OrderTrackingFamily();

  /// See also [orderTracking].
  OrderTrackingProvider call(int orderId) {
    return OrderTrackingProvider(orderId);
  }

  @override
  OrderTrackingProvider getProviderOverride(
    covariant OrderTrackingProvider provider,
  ) {
    return call(provider.orderId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'orderTrackingProvider';
}

/// See also [orderTracking].
class OrderTrackingProvider
    extends AutoDisposeFutureProvider<OrderTrackingDetail> {
  /// See also [orderTracking].
  OrderTrackingProvider(int orderId)
    : this._internal(
        (ref) => orderTracking(ref as OrderTrackingRef, orderId),
        from: orderTrackingProvider,
        name: r'orderTrackingProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$orderTrackingHash,
        dependencies: OrderTrackingFamily._dependencies,
        allTransitiveDependencies:
            OrderTrackingFamily._allTransitiveDependencies,
        orderId: orderId,
      );

  OrderTrackingProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orderId,
  }) : super.internal();

  final int orderId;

  @override
  Override overrideWith(
    FutureOr<OrderTrackingDetail> Function(OrderTrackingRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OrderTrackingProvider._internal(
        (ref) => create(ref as OrderTrackingRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orderId: orderId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<OrderTrackingDetail> createElement() {
    return _OrderTrackingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderTrackingProvider && other.orderId == orderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrderTrackingRef on AutoDisposeFutureProviderRef<OrderTrackingDetail> {
  /// The parameter `orderId` of this provider.
  int get orderId;
}

class _OrderTrackingProviderElement
    extends AutoDisposeFutureProviderElement<OrderTrackingDetail>
    with OrderTrackingRef {
  _OrderTrackingProviderElement(super.provider);

  @override
  int get orderId => (origin as OrderTrackingProvider).orderId;
}

String _$ordersNotifierHash() => r'10d72d18a03a24f7ca5e53b3aafd77a3fbd74e3a';

/// See also [OrdersNotifier].
@ProviderFor(OrdersNotifier)
final ordersNotifierProvider =
    AutoDisposeAsyncNotifierProvider<OrdersNotifier, List<Order>>.internal(
      OrdersNotifier.new,
      name: r'ordersNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ordersNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OrdersNotifier = AutoDisposeAsyncNotifier<List<Order>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
