import 'dart:async';
import 'dart:io';

import 'package:baby_flash_apps/core/constants/ads_unit_key.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdSection extends StatefulWidget {
  const BannerAdSection({super.key});

  @override
  State<BannerAdSection> createState() => _BannerAdSectionState();
}

class _BannerAdSectionState extends State<BannerAdSection> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  Timer? _retryTimer;
  int _retryCount = 0;

  final List<Duration> _retryDelays = [
    const Duration(seconds: 30),
    const Duration(seconds: 1),
    const Duration(seconds: 2),
    const Duration(seconds: 5),
  ];

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    if (!mounted) return;

    _retryTimer?.cancel();
    _retryTimer = null;

    final banner = BannerAd(
      adUnitId: Platform.isIOS
          ? AdsUnitKey.bannerAdIdIOS
          : AdsUnitKey.bannerAdId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }

          _retryTimer?.cancel();
          _retryTimer = null;

          _retryCount = 0;
          debugPrint('Banner ad loaded successfully');

          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },

        onAdFailedToLoad: (ad, error) {
          debugPrint(
            'Banner ad failed: '
            '${error.code} - ${error.message}',
          );
          ad.dispose();

          if (!mounted) return;

          setState(() {
            _bannerAd = null;
            _isLoaded = false;
          });

          _scheduleRetry();
        },
      ),
    );
    _bannerAd?.dispose();
    _bannerAd = banner;
    banner.load();
  }

  void _scheduleRetry() {
    if (!mounted) return;

    if (_retryCount >= _retryDelays.length) {
      debugPrint('Maximum banner ad retry attempts reached.');
      return;
    }

    final delay = _retryDelays[_retryCount];
    debugPrint('Retrying banner ad in ${delay.inSeconds} seconds...');
    _retryCount++;

    _retryTimer?.cancel();

    _retryTimer = Timer(delay, () {
      if (mounted && !_isLoaded) {
        _loadBannerAd();
      }
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _retryTimer = null;

    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
