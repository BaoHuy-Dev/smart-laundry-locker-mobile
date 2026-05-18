import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

/// Root application widget — replaces `app/_layout.tsx`.
///
/// In RN, the root layout wrapped CustomAlertProvider > AuthProvider > Stack.
/// In Flutter, ProviderScope (Riverpod) wraps from main.dart,
/// and GoRouter replaces the Stack navigator.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = createAppRouter(ref);
    return MaterialApp.router(
      title: 'Lock.R Locker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
