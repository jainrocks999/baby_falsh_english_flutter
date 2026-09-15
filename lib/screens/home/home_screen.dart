import 'package:baby_flash_apps/core/constants/app_language.dart';
import 'package:baby_flash_apps/core/constants/category.dart';
import 'package:baby_flash_apps/core/utils/helper.dart';
import 'package:baby_flash_apps/core/utils/responsive.dart';
import 'package:baby_flash_apps/database/db_provider.dart';
import 'package:baby_flash_apps/model/home_card.dart';
import 'package:baby_flash_apps/router/route_paths.dart';
import 'package:baby_flash_apps/services/music_services.dart';
import 'package:baby_flash_apps/widgets/app_background.dart';
import 'package:baby_flash_apps/widgets/category_grid.dart';
import 'package:baby_flash_apps/widgets/kids_bottom_nav_bar.dart';
import 'package:baby_flash_apps/widgets/topbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(dbProvider.notifier).loadCateCounts();
      await ref.read(dbProvider.notifier).loadSoundSettings();
      if (!mounted) return;
    });
  }

  void _onNavTap(int index) {
    if (index == 2) {
      AppHelpers.showSettingModal(context);
      return;
    }
    setState(() => _tabIndex = index);
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
          isTablet ? 32 : 52,
        );
        final badgeWidth = ResponsiveUtils.widthPercent(
          context,
          isTablet ? 16 : 22,
        );

        return Scaffold(
          body: AppBackground(
            child: Column(
              children: [
                const TopBar(showSettingsButton: false),
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
                        offset: Offset(0, isTablet ? -5 : -8),
                        child: Image.asset(
                          AppLanguageConfig.languageBadgeAsset,
                          width: badgeWidth,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: IndexedStack(
                    index: _tabIndex,
                    children: const [_HomeTabContent(), _GamesTabContent()],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: KidsBottomNavBar(
            currentIndex: _tabIndex,
            onTap: _onNavTap,
          ),
        );
      },
    );
  }
}

class _HomeTabContent extends ConsumerWidget {
  const _HomeTabContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dbProvider);
    final cards = AppLanguageConfig.hideAlphabetCategory
        ? homeCardList.where((item) => item.category != 'Alphabet').toList()
        : homeCardList;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: CategoryGrid(
        items: cards,
        categoryCounts: state.categoryCounts,
        onTap: (item, index) => context.push(
          RoutePaths.detail,
          extra: {'category': item.category, 'index': index},
        ),
        secondaryIcon: Icons.quiz_rounded,
        onSecondaryTap: (item, index) => context.push(
          RoutePaths.exercise,
          extra: {'category': item.category},
        ),
      ),
    );
  }
}

/// A single game/journey shown as a top tab inside the Games tab.
/// To add a new game later, add one more entry to the list built in
/// [_GamesTabContentState._sections] — no other structural change needed.
class _GameSection {
  final String label;
  final IconData icon;
  final void Function(BuildContext context, HomeCardData item, int index)
  onTap;

  const _GameSection({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

class _GamesTabContent extends ConsumerStatefulWidget {
  const _GamesTabContent();

  @override
  ConsumerState<_GamesTabContent> createState() => _GamesTabContentState();
}

class _GamesTabContentState extends ConsumerState<_GamesTabContent>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  late final List<_GameSection> _sections = [
    _GameSection(
      label: 'Quiz',
      icon: Icons.quiz_rounded,
      onTap: (context, item, index) => context.push(
        RoutePaths.exercise,
        extra: {'category': item.category},
      ),
    ),
    _GameSection(
      label: 'Memory Match',
      icon: Icons.extension_rounded,
      onTap: (context, item, index) =>
          context.push(RoutePaths.memoryGame, extra: item.category),
    ),
    // Add a new _GameSection here to introduce another game/journey.
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _sections.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dbProvider);
    final cards = AppLanguageConfig.hideAlphabetCategory
        ? homeCardList.where((item) => item.category != 'Alphabet').toList()
        : homeCardList;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(220),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xff5fbca4),
                borderRadius: BorderRadius.circular(26),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black54,
              labelStyle: const TextStyle(
                fontFamily: 'Fredoka',
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              tabs: _sections
                  .map((s) => Tab(icon: Icon(s.icon, size: 20), text: s.label))
                  .toList(),
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _sections.map((section) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: CategoryGrid(
                  items: cards,
                  categoryCounts: state.categoryCounts,
                  onTap: (item, index) => section.onTap(context, item, index),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
