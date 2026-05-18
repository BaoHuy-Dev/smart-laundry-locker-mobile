import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/firebase/firebase_config.dart';

/// Application entry point.
///
/// Initialization order:
///   1. Flutter engine bindings
///   2. Load .env (replaces process.env.EXPO_PUBLIC_*)
///   3. Firebase (TODO: Phase 3)
///   4. Wrap with ProviderScope (Riverpod — replaces AuthProvider)
///   5. Run App
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Firebase using environment variables
  await FirebaseConfig.initialize();

  runApp(ProviderScope(child: App()));
}
