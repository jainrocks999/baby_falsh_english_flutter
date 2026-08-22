import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:baby_flash_apps/ads/banner_ad.dart';
import 'package:baby_flash_apps/ads/interstitail_ad_service.dart';
import 'package:baby_flash_apps/core/utils/helper.dart';
import 'package:baby_flash_apps/core/utils/responsive.dart';
import 'package:baby_flash_apps/database/db_provider.dart';
import 'package:baby_flash_apps/services/music_services.dart';
import 'package:baby_flash_apps/widgets/app_background.dart';
import 'package:baby_flash_apps/widgets/custom_snackbar.dart';
import 'package:baby_flash_apps/widgets/topbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class ExerciseScreen extends ConsumerStatefulWidget {
  final String category;
  const ExerciseScreen({super.key, required this.category});

  @override
  ConsumerState<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends ConsumerState<ExerciseScreen> {
  final GlobalKey<ImageGridState> imgGridKey = GlobalKey();
  final InterstitialAdService _interstitialAdService = InterstitialAdService();

  final Set<int> _usedIndexes = {};
  List<Map<String, dynamic>>? cachedRandomItems;

  bool _isAdCompleted = false;

  @override
  void initState() {
    super.initState();

    _interstitialAdService.loadAd();

    Future.microtask(() async {
      await ref.read(dbProvider.notifier).fetchData(category: widget.category);
      await ref.read(dbProvider.notifier).loadSoundSettings();

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _showInterstitialBeforeActivity();
      });
    });
  }

  void _showInterstitialBeforeActivity() {
    if (_isAdCompleted) return;
    _interstitialAdService.showAd(
      onAdDismissed: () {
        if (!mounted) return;

        // setState(() {
        //   _isAdCompleted = true;
        // });
        debugPrint('Ad completed. Starting activity.');
      },
    );
  }

  void _loadNextQuestion() {
    setState(() {
      cachedRandomItems = null;
    });
  }

  @override
  void dispose() {
    _interstitialAdService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dbProvider);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.data.isEmpty) {
      return const Scaffold(
        body: Center(child: Center(child: CircularProgressIndicator())),
      );
    }

    cachedRandomItems ??= state.data.isNotEmpty
        ? AppHelpers.getRandomItems(state.data, _usedIndexes)
        : [];
    final randomItems = cachedRandomItems!;

    final langName = AppHelpers.getLanguageFolder(
      randomItems[0]['language_name'],
    );
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

                  Container(
                    // padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.width(
                        context,
                        isTablet ? 5 : 5.5,
                      ),
                      vertical: ResponsiveUtils.height(
                        context,
                        isTablet ? 1 : 1.5,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber[200],
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.width(context, isTablet ? 2 : 4),
                      ),
                      border: Border.all(width: 1, color: Colors.amber),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Fun with ${randomItems[0]['category']}',
                      style: TextStyle(
                        color: Colors.black54,
                        // fontSize: 14,
                        fontSize: ResponsiveUtils.fontSize(
                          context,
                          // isTablet ? 5 : 4.4,
                          isTablet
                              ? isLandscape
                                    ? 2.2
                                    : 5
                              : 4.5,
                        ),
                        fontFamily: 'Fredoka',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  Spacer(),
                  Container(
                    // padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.width(
                        context,
                        isTablet ? 3 : 5.5,
                      ),
                      vertical: ResponsiveUtils.height(
                        context,
                        isTablet ? 1 : 1.5,
                      ),
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
                    child: Text(
                      langName == 'english'
                          ? 'Click on ${randomItems[0]['sound'].replaceAll('.mp3', '')}?'
                          : 'Click on ${randomItems[0]['word']}?',
                      style: TextStyle(
                        color: Colors.black54,
                        // fontSize: 16,
                        fontSize: ResponsiveUtils.fontSize(
                          context,
                          // isTablet ? 5 : 4.8,
                          isTablet
                              ? isLandscape
                                    ? 2
                                    : 3
                              : 4.5,
                        ),
                        fontFamily: 'Fredoka',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: ResponsiveUtils.height(context, isTablet ? 1 : 2.5),
                  ),

                  // ImageGrid(
                  //   key: ValueKey(randomItems[0]['title']),
                  //   data: randomItems,
                  //   onCorrectAnswer: _loadNextQuestion,
                  //   isSoundOn: state.isSoundOn,
                  // ),
                  // if (_isAdCompleted)
                  ImageGrid(
                    key: ValueKey(randomItems[0]['title']),
                    data: randomItems,
                    onCorrectAnswer: _loadNextQuestion,
                    isSoundOn: state.isSoundOn,
                  ),
                  // if (!_isAdCompleted)
                  //   const Expanded(
                  //     child: Center(child: CircularProgressIndicator()),
                  //   ),
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

class ImageGrid extends StatefulWidget {
  final dynamic data;
  final VoidCallback onCorrectAnswer;
  final bool isSoundOn;
  const ImageGrid({
    super.key,
    required this.data,
    required this.onCorrectAnswer,
    required this.isSoundOn,
  });

  @override
  State<ImageGrid> createState() => ImageGridState();
}

class ImageGridState extends State<ImageGrid> {
  final PageController _controller = PageController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final StreamSubscription<PlayerState> _playerStateSub;

  int currentIndex = 0;
  bool isPlaying = false;
  late List<Map<String, dynamic>> shuffledData;
  late int correctIndex;

  int? selectedIndex;
  bool? isCorrect;
  bool isTapLocked = false;

  Future<void>? _currentTask;

  @override
  void initState() {
    super.initState();
    _configureAudioPlayer();

    shuffledData = List.from(widget.data);
    shuffledData.shuffle();

    correctIndex = shuffledData.indexWhere(
      (item) => item['title'] == widget.data[0]['title'],
    );

    _playerStateSub = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;

      if (state == PlayerState.playing) {
        setState(() => isPlaying = true);
      } else if (state == PlayerState.completed ||
          state == PlayerState.stopped ||
          state == PlayerState.paused) {
        setState(() => isPlaying = false);
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
      debugPrint("Exercise audio context error: $e");
    }
  }

  @override
  void dispose() {
    _playerStateSub.cancel();
    _audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> playItemAudio(Map<String, dynamic> item) async {
    // cancel previous logical task
    _currentTask = _playInternal(item);
    await _currentTask;
  }

  Future<void> _playInternal(Map<String, dynamic> item) async {
    await MusicService().runWithDuckedMusic(() async {
      try {
        await _audioPlayer.stop();

        final langName = AppHelpers.getLanguageFolder(item['language_name']);

        final sound = langName == 'english'
            ? item['sound']
            : item['sound']?.replaceAll(' ', '_');

        await _audioPlayer.play(AssetSource('helpers/clickon.mp3'));
        try {
          await _audioPlayer.onPlayerComplete.first.timeout(
            const Duration(seconds: 8),
          );
        } catch (_) {}
        if (!mounted) return;

        if (sound != null && sound.toString().isNotEmpty) {
          await _audioPlayer.play(AssetSource('files/$langName/$sound'));
          try {
            await _audioPlayer.onPlayerComplete.first.timeout(
              const Duration(seconds: 8),
            );
          } catch (_) {}
        }
      } catch (e) {
        debugPrint("Audio error: $e");
      }
    });
  }

  Future<void> onItemTap(int index) async {
    final List correctSounds = [
      'helpers/goodjob.mp3',
      'helpers/beautiful.mp3',
      'helpers/bravo.mp3',
      'helpers/excellent.mp3',
      'helpers/fantastic.mp3',
      'helpers/goodanswer.mp3',
      'helpers/great.mp3',
      'helpers/marvelous.mp3',
    ];
    final List wrongSounds = [
      "helpers/oopsie.mp3",
      "helpers/tryagain.mp3",
      "helpers/uhoh.mp3",
      "helpers/youcandoit.mp3",
    ];

    if (isTapLocked || isPlaying) return;

    isTapLocked = true;

    final correct = index == correctIndex;

    setState(() {
      selectedIndex = index;
      isCorrect = correct;
    });

    try {
      await MusicService().runWithDuckedMusic(() async {
        await _audioPlayer.stop();

        if (correct) {
          final sound = correctSounds[Random().nextInt(correctSounds.length)];
          await _audioPlayer.play(AssetSource(sound));
          try {
            await _audioPlayer.onPlayerComplete.first.timeout(
              const Duration(seconds: 8),
            );
          } catch (_) {}

          await Future.delayed(const Duration(milliseconds: 400));
          widget.onCorrectAnswer();
        } else {
          final sound = wrongSounds[Random().nextInt(wrongSounds.length)];

          await _audioPlayer.play(AssetSource(sound));
          try {
            await _audioPlayer.onPlayerComplete.first.timeout(
              const Duration(seconds: 8),
            );
          } catch (_) {}
        }
      });
    } catch (e) {
      debugPrint("Tap error: $e");
    } finally {
      await Future.delayed(const Duration(milliseconds: 300));
      isTapLocked = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = ResponsiveUtils.isTablet(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.widthPercent(
              context,
              isLandscape ? 15 : 3,
            ),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: shuffledData.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: ResponsiveUtils.widthPercent(context, 4),
              mainAxisSpacing: ResponsiveUtils.heightPercent(context, isTablet? 3 : 2),
              childAspectRatio: ResponsiveUtils.fontSize(
                context,
                isTablet
                    ? isLandscape
                          ? 0.22
                          : 0.20
                    : 0.30,
              ),
            ),
            itemBuilder: (context, index) {
              String itemImg = shuffledData[index]["image"];

              if (shuffledData[index]['category'] == 'Alphabet') {
                itemImg = AppHelpers.getModifiedImgName(
                  image: shuffledData[index]["image"],
                  langName: shuffledData[index]["language_name"],
                );
              }
              if (shuffledData[index]['category'] == 'Numbers') {
                itemImg = AppHelpers.getModifiedImgName(
                  image: shuffledData[index]["image"],
                  langName: shuffledData[index]["language_name"],
                );
              }

              return GestureDetector(
                onTap: () => onItemTap(index),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selectedIndex == null
                            ? Colors.grey.shade300
                            : isCorrect == true
                            ? (index == correctIndex
                                  ? Colors.green
                                  : Colors.grey.shade300)
                            : (index == selectedIndex
                                  ? Colors.red
                                  : Colors.grey.shade300),
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
                      borderRadius: BorderRadius.circular(17),
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          /// Image
                          Image.asset(
                            'assets/files/$itemImg',
                            fit: BoxFit.cover,
                            width: isTablet ? null : double.infinity,
                            height: isTablet ? null : double.infinity,
                          ),

                          /// Icons / overlay
                          if (selectedIndex != null)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isCorrect == true
                                      ? (index == correctIndex
                                            ? Colors.green.withAlpha(81)
                                            : Colors.transparent)
                                      : (index == selectedIndex
                                            ? Colors.red.withAlpha(81)
                                            : Colors.transparent),
                                ),
                                child: Center(
                                  child: isCorrect == true
                                      ? (index == correctIndex
                                            ? const Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                                size: 50,
                                              )
                                            : null)
                                      : (index == selectedIndex
                                            ? const Icon(
                                                Icons.cancel,
                                                color: Colors.red,
                                                size: 50,
                                              )
                                            : null),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // SizedBox(height: 50),
        SizedBox(height: ResponsiveUtils.height(context, isTablet ? 3 : 5.5)),
        ElevatedButton(
          onPressed: () {
            if (widget.isSoundOn) {
              playItemAudio(widget.data[0]);
            } else {
              showCustomSnackBar(
                context: context,
                title: "Sound is Off",
                subtitle:
                    " Turn on sound in settings to hear the fun sounds 🎵",
                backgroundColor: Color(0xffb3903e),
                icon: Icons.volume_off,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xffc7f0e5).withAlpha(135),
            elevation: 5,
            shadowColor: Colors.black26,
            // padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.width(context, isTablet ? 2 : 3),
              vertical: ResponsiveUtils.height(context, isTablet ? 1 : 0.5),
            ),
            shape: RoundedRectangleBorder(
              // borderRadius: BorderRadius.circular(50),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.width(context, isTablet ? 2 : 7),
              ),
              side: BorderSide(color: Color(0xff5fbca4), width: 3),
            ),
          ),

          child: Row(
            spacing: 5,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                "assets/svgs/replay_btn.svg",
                width: ResponsiveUtils.width(context, isTablet ? 10 : 17),
                height: ResponsiveUtils.width(context, isTablet ? 10 : 17),
              ),

              Text(
                'Replay',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: ResponsiveUtils.fontSize(context, isTablet ? 3 : 7),
                  fontFamily: 'Fredoka',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
