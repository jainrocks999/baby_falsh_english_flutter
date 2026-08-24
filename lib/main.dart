import 'package:baby_flash_apps/database/db_provider.dart';
import 'package:baby_flash_apps/router/app_router.dart';
import 'package:baby_flash_apps/services/music_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final RequestConfiguration requestConfiguration = RequestConfiguration(
    maxAdContentRating: MaxAdContentRating.g,
    ageRestrictedTreatment: AgeRestrictedTreatment.child,
  );

  await MobileAds.instance.updateRequestConfiguration(
    requestConfiguration,
  );

  await MobileAds.instance.initialize();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    MusicService().stopMusic();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        MusicService().stopMusic();
        break;
      case AppLifecycleState.resumed:
        if (ref.read(dbProvider).isMusicOn) {
          MusicService().playMusic();
        }
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Baby Flash Italian',
      routerConfig: appRouter,
    );
  }
}
