import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Splash screen replacing the RN version in app/index.tsx.
/// Plays a video and waits for the AuthNotifier to finish its initial check.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  VideoPlayerController? _controller;
  Timer? _fallbackTimer;
  bool _isVideoInitialized = false;
  bool _videoUnavailable = false;

  @override
  void initState() {
    super.initState();
    try {
      final controller = VideoPlayerController.asset(
        'assets/videos/splash.mp4',
      );
      _controller = controller;
      controller
          .initialize()
          .then((_) {
            if (!mounted) return;
            setState(() {
              _isVideoInitialized = true;
            });
            controller.setLooping(false);
            controller.play();
          })
          .catchError((_) {
            if (mounted) {
              setState(() => _videoUnavailable = true);
            }
          });

      controller.addListener(() {
        if (!controller.value.isPlaying &&
            controller.value.position >= controller.value.duration) {
          _checkAndNavigate();
        }
      });
    } catch (_) {
      _videoUnavailable = true;
    }

    // Fallback timer (like RN's 4.5s)
    _fallbackTimer = Timer(AppConstants.splashDuration, () {
      if (mounted) {
        _checkAndNavigate();
      }
    });
  }

  void _checkAndNavigate() {
    final authState = ref.read(authNotifierProvider);

    // If auth is still loading, wait. The GoRouter redirect will handle it.
    // If not loading, we explicitly trigger a router refresh to process redirects.
    if (!authState.isLoading && mounted) {
      context.go('/auth/login'); // GoRouter redirect logic will intercept this
    }
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final logoSize = (constraints.biggest.shortestSide * 0.7).clamp(
              180.0,
              constraints.maxHeight * 0.48,
            );

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: logoSize,
                      height: logoSize,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _buildSplashVisual(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppConstants.appName,
                      style: AppTypography.splashTitle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppConstants.appTagline,
                      style: AppTypography.splashTagline,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSplashVisual() {
    final controller = _controller;
    if (_isVideoInitialized && controller != null) {
      return VideoPlayer(controller);
    }

    if (_videoUnavailable) {
      return Container(
        color: AppColors.accent.withValues(alpha: 0.18),
        child: const Icon(
          Icons.local_laundry_service,
          size: 80,
          color: AppColors.primary,
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }
}
