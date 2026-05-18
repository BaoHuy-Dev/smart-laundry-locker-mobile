import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/user.dart';
import '../../../core/network/auth_interceptor.dart';
import '../../../core/network/token_storage.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/user_service.dart';

part 'auth_provider.g.dart';

/// State class holding current authentication and user info.
/// Matches the `AuthState` interface in RN's AuthContext.tsx.
class AuthState {
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;
  final UserRole? role;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = true,
    this.role,
  });

  AuthState copyWith({
    User? user,
    bool? isAuthenticated,
    bool? isLoading,
    UserRole? role,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      role: role ?? this.role,
    );
  }
}

/// Riverpod AsyncNotifier providing auth state and methods.
/// Replaces `AuthContext` and `useAuth()` hook from React Native.
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<AuthState> build() async {
    // Register the force logout callback for the HTTP interceptor
    AuthInterceptor.onForceLogout = logout;

    // Check existing tokens on app start
    return await _checkAuth();
  }

  Future<AuthState> _checkAuth() async {
    try {
      final accessToken = await TokenStorage.getAccessToken();

      if (accessToken != null && accessToken.isNotEmpty) {
        final mockUser = await _fetchProfileOrFallback();
        return AuthState(
          user: mockUser,
          isAuthenticated: true,
          isLoading: false,
          role: mockUser.role,
        );
      }
    } catch (e) {
      // Ignored
    }

    // No valid token or check failed
    await TokenStorage.clearTokens();
    return const AuthState(
      user: null,
      isAuthenticated: false,
      isLoading: false,
      role: null,
    );
  }

  /// Login and save tokens
  Future<void> login(AuthTokens tokens) async {
    state = const AsyncValue.loading();
    try {
      await TokenStorage.setTokens(tokens.accessToken, tokens.refreshToken);

      final mockUser = await _fetchProfileOrFallback();

      state = AsyncValue.data(
        AuthState(
          user: mockUser,
          isAuthenticated: true,
          isLoading: false,
          role: mockUser.role,
        ),
      );
    } catch (e, stack) {
      await TokenStorage.clearTokens();
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Complete logout
  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await AuthService.logout(refreshToken);
      }
    } catch (e) {
      // Ignore API errors on logout
    } finally {
      await TokenStorage.clearTokens();
      state = const AsyncValue.data(
        AuthState(
          user: null,
          isAuthenticated: false,
          isLoading: false,
          role: null,
        ),
      );
    }
  }

  /// Refresh user profile data from server
  Future<void> refreshUser() async {
    try {
      final response = await UserService.getProfile();
      final user = response.data;
      state = AsyncValue.data(
        state.requireValue.copyWith(user: user, role: user.role),
      );
    } catch (e) {
      // Ignore refresh failures; existing session state remains usable.
    }
  }

  Future<User> _fetchProfileOrFallback() async {
    try {
      return (await UserService.getProfile()).data;
    } catch (_) {
      return const User(
        id: 0,
        firstName: 'User',
        lastName: '',
        email: '',
        phoneNumber: '',
        role: UserRole.user,
      );
    }
  }
}
