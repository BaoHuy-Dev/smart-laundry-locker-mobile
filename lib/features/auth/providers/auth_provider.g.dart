// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authNotifierHash() => r'08a7100da3b481737c1292992b83247450b86744';

/// Riverpod AsyncNotifier providing auth state and methods.
/// Replaces `AuthContext` and `useAuth()` hook from React Native.
///
/// Copied from [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>.internal(
      AuthNotifier.new,
      name: r'authNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthNotifier = AsyncNotifier<AuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
