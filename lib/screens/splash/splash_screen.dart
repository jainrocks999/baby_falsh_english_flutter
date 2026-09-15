import 'package:baby_flash_apps/core/constants/app_colors.dart';
import 'package:baby_flash_apps/core/constants/app_language.dart';
import 'package:baby_flash_apps/router/route_paths.dart';
import 'package:baby_flash_apps/services/app_update_services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _displayDuration = Duration(milliseconds: 2200);

  late final AnimationController _controller;
  late final Animation<double> _iconScale;
  late final Animation<double> _iconOpacity;
  late final Animation<Offset> _badgeSlide;
  late final Animation<double> _badgeOpacity;

  final AppUpdateServices _appUpdateServices = AppUpdateServices();

  bool _isAnimationCompleted = false;
  bool _isUpdateChecked = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: _displayDuration)
      ..forward().whenComplete(() {
        if (!mounted) return;
        setState(() => _isAnimationCompleted = true);
        _checkNavigation();
      });

    _iconOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.35, curve: Curves.easeIn),
      ),
    );
    _iconScale = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _badgeOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.85, curve: Curves.easeIn),
      ),
    );
    _badgeSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.45, 0.85, curve: Curves.easeOutBack),
          ),
        );

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

  void _checkNavigation() {
    if (!_isAnimationCompleted || !_isUpdateChecked) {
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
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _iconOpacity,
                child: ScaleTransition(
                  scale: _iconScale,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _badgeOpacity,
                child: SlideTransition(
                  position: _badgeSlide,
                  child: Image.asset(
                    AppLanguageConfig.languageBadgeAsset,
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
