import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:baby_flash_apps/ads/banner_ad.dart';
import 'package:baby_flash_apps/ads/interstitail_ad_service.dart';
import 'package:baby_flash_apps/core/constants/app_language.dart';
import 'package:baby_flash_apps/core/utils/helper.dart';
import 'package:baby_flash_apps/core/utils/responsive.dart';
import 'package:baby_flash_apps/database/db_provider.dart';
import 'package:baby_flash_apps/services/music_services.dart';
import 'package:baby_flash_apps/widgets/app_background.dart';
import 'package:baby_flash_apps/widgets/custom_snackbar.dart';
import 'package:baby_flash_apps/widgets/icon_elevated_btn.dart';
import 'package:baby_flash_apps/widgets/topbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlaygroundScreen extends ConsumerStatefulWidget {
  final String category;
  final int cateIndex;
  const PlaygroundScreen({
    super.key,
    required this.category,
    required this.cateIndex,
  });

  @override
  ConsumerState<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

class _PlaygroundScreenState extends ConsumerState<PlaygroundScreen> {
  final GlobalKey<ImageSliderState> sliderKey = GlobalKey();

  final InterstitialAdService _interstitialAdService = InterstitialAdService();

  // int _completedCards = 0;

  @override
  void initState() {
    super.initState();

    _interstitialAdService.loadAd();

    Future.microtask(() async {
      await ref.read(dbProvider.notifier).fetchData(category: widget.category);
      await ref.read(dbProvider.notifier).loadSoundSettings();
    });
  }

  @override
  void dispose() {
    _interstitialAdService.dispose();
    super.dispose();
  }

  Future<void> _handleNextCard() async {
    final sliderState = sliderKey.currentState;

    if (sliderState == null) return;
    final currentCard = sliderState.currentIndex + 1;
    final isLastCard =
        sliderState.currentIndex >= sliderState.widget.data.length - 1;

    if (isLastCard) {
      final result = await AppHelpers.showAfterCompleteActivityModal(
        context,
        widget.cateIndex,
      );
      if (result == 0) {
        sliderState.resetToFirstPage();
      }
      result;
    }
    if (currentCard % 10 == 0) {
      _interstitialAdService.showAd(
        // onAdDismissed: () {
        //   if (!mounted) return;
        //   sliderState.nextPage();
        // },
      );
      sliderState.nextPage();
    } else {
      sliderState.nextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dbProvider);
    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final bool isTablet = ResponsiveUtils.isTablet(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
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
                  SizedBox(
                    height: ResponsiveUtils.height(context, isTablet ? 0 : 1),
                  ),
                  ImageSlider(
                    key: sliderKey,
                    data: state.data,
                    isShowLangTxt: state.isShowLangTxt,
                    isSoundOn: state.isSoundOn,
                    isSwpieOn: state.isSwpieOn,
                  ),
                  Spacer(),
                  Row(
                    spacing: 15,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconElevatedBtn(
                        size: ResponsiveUtils.width(
                          context,
                          isTablet
                              ? isLandscape
                                    ? 9
                                    : 14
                              : 20,
                        ),
                        assetPath: 'assets/svgs/left_btn.svg',
                        onPressed: () {
                          sliderKey.currentState?.previousPage();
                        },
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable:
                            sliderKey.currentState?.isPlayingNotifier ??
                            ValueNotifier(false),
                        builder: (context, isPlaying, child) {
                          return IconElevatedBtn(
                            assetPath:
                                'assets/svgs/${isPlaying ? 'stop_btn' : 'replay_btn'}.svg',
                            onPressed: () async {
                              if (state.isSoundOn) {
                                final stateRef = sliderKey.currentState;

                                if (stateRef != null) {
                                  if (isPlaying) {
                                    await stateRef.stopAudio();
                                  } else {
                                    await stateRef.playItemAudio(
                                      stateRef.widget.data[stateRef
                                          .currentIndex],
                                    );
                                  }
                                }
                              } else {
                                showCustomSnackBar(
                                  context: context,
                                  title: "Sound is Off",
                                  subtitle:
                                      "Turn on sound in settings to hear the fun sounds 🎵",
                                  backgroundColor: const Color(0xffb3903e),
                                  icon: Icons.volume_off,
                                );
                              }
                            },
                            size: ResponsiveUtils.width(
                              context,
                              isTablet
                                  ? isLandscape
                                        ? 14
                                        : 20
                                  : 28,
                            ),
                          );
                        },
                      ),
                      IconElevatedBtn(
                        size: ResponsiveUtils.width(
                          context,
                          isTablet
                              ? isLandscape
                                    ? 9
                                    : 14
                              : 20,
                        ),
                        assetPath: 'assets/svgs/right_btn.svg',
                        onPressed: _handleNextCard,
                      ),
                    ],
                  ),
                  Spacer(),
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
      ),
    );
  }
}

class ImageSlider extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final bool isShowLangTxt;
  final bool isSoundOn;
  final bool isSwpieOn;
  const ImageSlider({
    super.key,
    required this.data,
    required this.isShowLangTxt,
    required this.isSoundOn,
    required this.isSwpieOn,
  });

  @override
  State<ImageSlider> createState() => ImageSliderState();
}

class ImageSliderState extends State<ImageSlider> {
  final PageController _controller = PageController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final StreamSubscription<PlayerState> _playerStateSub;

  int currentIndex = 0;
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);

  int _playToken = 0;

  @override
  void initState() {
    super.initState();
    _configureAudioPlayer();
    _playerStateSub = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;

      if (state == PlayerState.playing) {
        isPlayingNotifier.value = true;
      } else if (state == PlayerState.completed ||
          state == PlayerState.stopped ||
          state == PlayerState.paused) {
        isPlayingNotifier.value = false;
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.data.isNotEmpty) {
        if (widget.isSoundOn) {
          playItemAudio(widget.data[0]);
        }
      }
    });
  }

  Future<void> _configureAudioPlayer() async {
    try {
      await _audioPlayer.setAudioContext(MusicService.effectsAudioContext);
      await _audioPlayer.setVolume(MusicService.effectsVolume);
    } catch (e) {
      debugPrint("Playground audio context error: $e");
    }
  }

  @override
  void didUpdateWidget(covariant ImageSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _playToken++;
      _audioPlayer.stop();

      setState(() {
        currentIndex = 0;
      });
      if (widget.data.isNotEmpty && widget.isSoundOn) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          playItemAudio(widget.data[0]);
        });
      }
    }
  }

  @override
  void dispose() {
    isPlayingNotifier.dispose();
    _playerStateSub.cancel();
    _audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    isPlayingNotifier.value = false;
  }

  Future<void> playItemAudio(Map<String, dynamic> item) async {
    _playToken++;
    final token = _playToken;

    await _audioPlayer.stop();
    _playInternal(item, token);
  }

  Future<void> _playInternal(Map<String, dynamic> item, int token) async {
    await MusicService().runWithDuckedMusic(() async {
      try {
        if (token != _playToken) return;

        final langName = AppLanguageConfig.soundFolder;
        final actualSound = AppHelpers.normalizeSoundFile(item['actualsound']);
        final sound = AppHelpers.normalizeSoundFile(item['sound']);

        if (actualSound != null) {
          try {
            if (token != _playToken) return;
            await _playFirstAvailable(langName, actualSound, token);
          } catch (e) {
            debugPrint("ActualSound error: $e");
          }
          if (token != _playToken) {
            await _audioPlayer.stop();
            return;
          }
        }

        if (!mounted || token != _playToken) return;

        if (sound != null) {
          try {
            await _playFirstAvailable(langName, sound, token);
          } catch (e) {
            debugPrint("Sound error: $e");
          }
          if (token != _playToken) {
            await _audioPlayer.stop();
            return;
          }
        }
      } catch (e) {
        debugPrint("Audio error: $e");
      }
    });
  }

  Future<void> _playFirstAvailable(
    String folder,
    String fileName,
    int token,
  ) async {
    for (final path in AppHelpers.soundAssetPaths(folder, fileName)) {
      if (token != _playToken) return;
      try {
        await _audioPlayer.play(AssetSource(path));
        await _audioPlayer.onPlayerComplete.first.timeout(
          const Duration(seconds: 8),
        );
        return;
      } catch (e) {
        debugPrint("Sound skip $path: $e");
      }
    }
  }

  void nextPage() async {
    if (currentIndex < widget.data.length - 1) {
      _playToken++;
      await _audioPlayer.stop();

      _controller.animateToPage(
        currentIndex + 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() async {
    if (currentIndex > 0) {
      _playToken++;
      await _audioPlayer.stop();

      _controller.animateToPage(
        currentIndex - 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  void resetToFirstPage() {
    setState(() {
      currentIndex = 0;
    });

    _controller.jumpToPage(0);

    if (widget.data.isNotEmpty && widget.isSoundOn) {
      playItemAudio(widget.data[0]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = ResponsiveUtils.isTablet(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Column(
      spacing: ResponsiveUtils.height(context, isTablet ? 1.5 : 4),
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.width(context, isTablet ? 5 : 5.5),
            vertical: ResponsiveUtils.height(context, isTablet ? 1 : 1.5),
          ),
          decoration: BoxDecoration(
            color: Colors.amber[200],
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.width(context, isTablet ? 2 : 4),
            ),
            border: Border.all(
              width: ResponsiveUtils.width(context, 0.8),
              color: Colors.amber,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            '${currentIndex + 1}/${widget.data.length}',
            style: TextStyle(
              color: Colors.black54,
              fontSize: ResponsiveUtils.fontSize(
                context,
                isTablet
                    ? isLandscape
                          ? 2.2
                          : 5
                    : 5.5,
              ),
              fontFamily: 'Fredoka',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        widget.isShowLangTxt && widget.data.isNotEmpty
            ? Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.width(
                    context,
                    isTablet ? 3 : 5.5,
                  ),
                  vertical: ResponsiveUtils.height(context, isTablet ? 1 : 1.5),
                ),
                decoration: BoxDecoration(
                  color: Color(0xffb3eafd),
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.width(context, isTablet ? 2 : 4),
                  ),
                  border: Border.all(
                    width: 2,
                    color: Colors.white.withAlpha(150),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),

                child: widget.data.isNotEmpty
                    ? Text(
                        '${widget.data[currentIndex]['word'] ?? widget.data[currentIndex]['sound'].replaceAll('.mp3', '')}?',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: ResponsiveUtils.fontSize(
                            context,
                            isTablet
                                ? isLandscape
                                      ? 2
                                      : 3
                                : 4.5,
                          ),
                          fontFamily: 'Fredoka',
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              )
            : SizedBox(height: 57),

        SizedBox(
          height: ResponsiveUtils.height(
            context,
            isTablet
                ? isLandscape
                      ? 40
                      : 42
                : 40,
          ),
          width: ResponsiveUtils.width(
            context,
            isTablet
                ? isLandscape
                      ? 40
                      : 75
                : 88,
          ),
          child: GestureDetector(
            onHorizontalDragStart: (_) {
              if (!widget.isSwpieOn) {
                showCustomSnackBar(
                  context: context,
                  title: "Swipe Disabled",
                  subtitle: "Turn on swipe from settings to move images",
                  backgroundColor: Color(0xffb3903e),
                  icon: Icons.swipe,
                );
              }
            },
            child: AbsorbPointer(
              absorbing: !widget.isSwpieOn,
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.data.length,
                physics: widget.isSwpieOn
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => currentIndex = index);
                  final item = widget.data[index];
                  if (widget.isSoundOn) {
                    playItemAudio(item);
                  }
                },
                itemBuilder: (context, index) {
                  String itemImg = widget.data[index]["image"];

                  if (widget.data[index]['category'] == 'Alphabet') {
                    itemImg = AppHelpers.getModifiedImgName(
                      image: widget.data[index]["image"],
                      langName: widget.data[index]["language_name"],
                    );
                  }
                  if (widget.data[index]['category'] == 'Numbers' &&
                      AppHelpers.getLanguageFolder(
                            widget.data[index]["language_name"],
                          ) ==
                          'japanies') {
                    itemImg = AppHelpers.getModifiedImgName(
                      image: widget.data[index]["image"],
                      langName: widget.data[index]["language_name"],
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet
                          ? isLandscape
                                ? 30
                                : 55
                          : 20,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/files/$itemImg',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
