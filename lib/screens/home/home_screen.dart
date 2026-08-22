import 'package:baby_flash_apps/ads/banner_ad.dart';
import 'package:baby_flash_apps/core/constants/app_language.dart';
import 'package:baby_flash_apps/core/utils/responsive.dart';
import 'package:baby_flash_apps/database/db_provider.dart';
import 'package:baby_flash_apps/services/music_services.dart';
import 'package:baby_flash_apps/widgets/app_background.dart';
import 'package:baby_flash_apps/widgets/home_card_basiclist.dart';
import 'package:baby_flash_apps/widgets/home_card_gridlist.dart';
import 'package:baby_flash_apps/widgets/topbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(dbProvider.notifier).loadCateCounts();
      await ref.read(dbProvider.notifier).loadQuestionMode();
      await ref.read(dbProvider.notifier).loadSoundSettings();
      if (!mounted) return;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        ref.listen(dbProvider, (prev, next) {
          if (prev?.isMusicOn == next.isMusicOn) {
            return;
          }

          if (next.isMusicOn) {
            MusicService().playMusic();
          } else {
            MusicService().stopMusic();
          }
        });

        final bool isTablet = ResponsiveUtils.isTablet(context);
        final logoWidth = ResponsiveUtils.widthPercent(
          context,
          isTablet ? 40 : 65,
        );
        final badgeWidth = ResponsiveUtils.widthPercent(
          context,
          isTablet ? 22 : 30,
        );
        return Scaffold(
          body: AppBackground(
            child: Stack(
              children: [
                Column(
                  children: [
                    const TopBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
                        child: Column(
                          spacing: 20,
                          children: [
                            SizedBox(
                              width: logoWidth,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/app_name.png',
                                    width: logoWidth,
                                    fit: BoxFit.contain,
                                  ),
                                  Transform.translate(
                                    offset: Offset(0, isTablet ? -16 : -26),
                                    child: Image.asset(
                                      AppLanguageConfig.languageBadgeAsset,
                                      width: badgeWidth,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            isTablet ? HomeCardGridlist() : HomeCardBasiclist(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Center(child: const BannerAdSection()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
