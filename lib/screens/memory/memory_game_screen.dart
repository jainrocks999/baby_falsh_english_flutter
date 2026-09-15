import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:baby_flash_apps/ads/banner_ad.dart';
import 'package:baby_flash_apps/ads/interstitail_ad_service.dart';
import 'package:baby_flash_apps/core/utils/helper.dart';
import 'package:baby_flash_apps/core/utils/responsive.dart';
import 'package:baby_flash_apps/database/db_provider.dart';
import 'package:baby_flash_apps/router/route_paths.dart';
import 'package:baby_flash_apps/services/music_services.dart';
import 'package:baby_flash_apps/widgets/app_background.dart';
import 'package:baby_flash_apps/widgets/topbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class _MemoryCard {
  final String pairId;
  final Map<String, dynamic> item;
  bool isFlipped = false;
  bool isMatched = false;

  _MemoryCard({required this.pairId, required this.item});
}

enum MemoryDifficulty {
  easy('Easy', 2),
  medium('Medium', 3),
  hard('Hard', 6);

  final String label;
  final int pairCount;

  const MemoryDifficulty(this.label, this.pairCount);
}

class MemoryGameScreen extends ConsumerStatefulWidget {
  final String category;
  const MemoryGameScreen({super.key, required this.category});

  @override
  ConsumerState<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends ConsumerState<MemoryGameScreen> {
  MemoryDifficulty _difficulty = MemoryDifficulty.medium;

  static const List<String> _correctSounds = [
    'helpers/goodjob.mp3',
    'helpers/beautiful.mp3',
    'helpers/bravo.mp3',
    'helpers/excellent.mp3',
    'helpers/fantastic.mp3',
    'helpers/goodanswer.mp3',
    'helpers/great.mp3',
    'helpers/marvelous.mp3',
  ];
  static const List<String> _wrongSounds = [
    'helpers/oopsie.mp3',
    'helpers/tryagain.mp3',
    'helpers/uhoh.mp3',
    'helpers/youcandoit.mp3',
  ];

  final InterstitialAdService _interstitialAdService = InterstitialAdService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<int> _flippedIndexes = [];

  List<_MemoryCard>? _cachedCards;
  int _matchedPairs = 0;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _interstitialAdService.loadAd();

    Future.microtask(() async {
      await ref.read(dbProvider.notifier).fetchData(category: widget.category);
      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _interstitialAdService.showAd();
      });
    });
  }

  @override
  void dispose() {
    _interstitialAdService.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  List<_MemoryCard> _buildCards(List<Map<String, dynamic>> data) {
    final pool = List<Map<String, dynamic>>.from(data)..shuffle();
    final chosen = pool.take(min(_difficulty.pairCount, pool.length)).toList();

    final cards = <_MemoryCard>[];
    for (final item in chosen) {
      final pairId = item['title'].toString();
      cards.add(_MemoryCard(pairId: pairId, item: item));
      cards.add(_MemoryCard(pairId: pairId, item: item));
    }
    cards.shuffle();
    return cards;
  }

  String _imageFor(Map<String, dynamic> item) {
    String itemImg = item['image'];
    if (item['category'] == 'Alphabet' || item['category'] == 'Numbers') {
      itemImg = AppHelpers.getModifiedImgName(
        image: item['image'],
        langName: item['language_name'],
      );
    }
    return itemImg;
  }

  Future<void> _playSound(String path) async {
    try {
      await MusicService().runWithDuckedMusic(() async {
        await _audioPlayer.play(AssetSource(path));
        try {
          await _audioPlayer.onPlayerComplete.first.timeout(
            const Duration(seconds: 3),
          );
        } catch (_) {}
      });
    } catch (e) {
      debugPrint('Memory game audio error: $e');
    }
  }

  Future<void> _onCardTap(int index) async {
    if (_isBusy) return;
    final cards = _cachedCards!;
    final card = cards[index];
    if (card.isFlipped || card.isMatched) return;

    setState(() => card.isFlipped = true);
    _flippedIndexes.add(index);

    if (_flippedIndexes.length < 2) return;

    _isBusy = true;
    final first = cards[_flippedIndexes[0]];
    final second = cards[_flippedIndexes[1]];

    if (first.pairId == second.pairId) {
      await _playSound(_correctSounds[Random().nextInt(_correctSounds.length)]);
      if (mounted) {
        setState(() {
          first.isMatched = true;
          second.isMatched = true;
          _matchedPairs++;
        });
      }

      if (_matchedPairs == cards.length ~/ 2) {
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) _showCompletionDialog();
      }
    } else {
      await _playSound(_wrongSounds[Random().nextInt(_wrongSounds.length)]);
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          first.isFlipped = false;
          second.isFlipped = false;
        });
      }
    }

    _flippedIndexes.clear();
    _isBusy = false;
  }

  void _restart() {
    setState(() {
      _cachedCards = null;
      _matchedPairs = 0;
      _flippedIndexes.clear();
    });
  }

  void _changeDifficulty(MemoryDifficulty difficulty) {
    if (difficulty == _difficulty || _isBusy) return;
    setState(() {
      _difficulty = difficulty;
      _cachedCards = null;
      _matchedPairs = 0;
      _flippedIndexes.clear();
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(30),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xfff7cd89),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 20,
            children: [
              const Text(
                'ALL MATCHED!',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: Colors.green,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      context.go(RoutePaths.home);
                    },
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Home'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      _restart();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Play Again'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dbProvider);
    final bool isTablet = ResponsiveUtils.isTablet(context);

    if (state.isLoading || state.data.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final cards = _cachedCards ??= _buildCards(state.data);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(dbProvider.notifier).clearData();
        }
      },
      child: Scaffold(
        body: AppBackground(
          child: Stack(
            children: [
              Column(
                children: [
                  const TopBar(showBackButton: true),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: MemoryDifficulty.values.map((difficulty) {
                        final isSelected = difficulty == _difficulty;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () => _changeDifficulty(difficulty),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xff5fbca4)
                                    : Colors.white.withAlpha(220),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xff5fbca4)
                                      : Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                difficulty.label,
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber[200],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(width: 1, color: Colors.amber),
                      ),
                      child: Text(
                        'Matches: $_matchedPairs/${cards.length ~/ 2}',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontWeight: FontWeight.w700,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.width(
                          context,
                          isTablet ? 6 : 4,
                        ),
                      ),
                      child: GridView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: cards.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isTablet ? 4 : 3,
                          crossAxisSpacing: ResponsiveUtils.widthPercent(
                            context,
                            3,
                          ),
                          mainAxisSpacing: ResponsiveUtils.heightPercent(
                            context,
                            2,
                          ),
                          childAspectRatio: 0.8,
                        ),
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          final showFace = card.isFlipped || card.isMatched;

                          return GestureDetector(
                            onTap: () => _onCardTap(index),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: showFace
                                  ? Container(
                                      key: const ValueKey('face'),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          16,
                                        ),
                                        border: Border.all(
                                          color: card.isMatched
                                              ? Colors.green
                                              : Colors.grey.shade300,
                                          width: 3,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 6,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          13,
                                        ),
                                        child: Image.asset(
                                          'assets/files/${_imageFor(card.item)}',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      key: const ValueKey('back'),
                                      decoration: BoxDecoration(
                                        color: const Color(0xffb3eafd),
                                        borderRadius: BorderRadius.circular(
                                          16,
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withAlpha(150),
                                          width: 2,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 6,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.question_mark_rounded,
                                          color: Colors.black45,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Center(child: BannerAdSection()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
