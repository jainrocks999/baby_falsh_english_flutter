import 'package:baby_flash_apps/router/route_paths.dart';
import 'package:baby_flash_apps/services/app_update_services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  final AppUpdateServices _appUpdateServices = AppUpdateServices();

  bool _isVideoCompleted = false;
  bool _isUpdateChecked = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _initializeSplashVideo();

    _checkForAppUpdate();
  }

  Future<void> _checkForAppUpdate() async {
    try {
      final updateAvailable = await _appUpdateServices.checkForUpdate();

      debugPrint('Update available: $updateAvailable');

      if (updateAvailable) {
        final updateStarted = await _appUpdateServices.startImmediateUpdate();

        debugPrint(
          'Update flow completed. '
          'Update started: $updateStarted',
        );
      }
    } catch (e) {
      debugPrint('Update flow error: $e');
    }

    if (!mounted) return;

    setState(() {
      _isUpdateChecked = true;
    });

    _checkNavigation();
  }

  void _initializeSplashVideo() {
    _controller = VideoPlayerController.asset('assets/videos/splash(2).mp4')
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller.play();
      });
    _controller.addListener(() {
      if (_controller.value.isCompleted && mounted) {
        setState(() {
          _isVideoCompleted = true;
        });
        _checkNavigation();
      }
    });
  }

  void _checkNavigation() {
    if (!_isVideoCompleted || !_isUpdateChecked) {
      return;
    }
    if (_isNavigating) {
      return;
    }
    _isNavigating = true;
    context.go(RoutePaths.home);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: _controller.value.isInitialized
            ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
