// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationsNotifierHash() =>
    r'f3d2803c01175dfca59e7d161a6ada05716bd4ef';

/// See also [NotificationsNotifier].
@ProviderFor(NotificationsNotifier)
final notificationsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      NotificationsNotifier,
      List<AppNotification>
    >.internal(
      NotificationsNotifier.new,
      name: r'notificationsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificationsNotifier =
    AutoDisposeAsyncNotifier<List<AppNotification>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
