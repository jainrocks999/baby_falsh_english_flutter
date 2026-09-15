import 'dart:io';

import 'package:baby_flash_apps/core/constants/ads_unit_key.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdService {
  InterstitialAd? _interstitialAd;

  bool _isLoading = false;

  VoidCallback? _pendingCallback;

  /// Shared across every screen's [InterstitialAdService] instance so ads
  /// are throttled app-wide instead of once per screen.
  static int _opportunityCount = 0;
  static DateTime? _lastShownAt;

  static const int _showEveryNOpportunities = 3;
  static const Duration _minGapBetweenAds = Duration(seconds: 45);

  bool get _isWithinCooldown {
    final lastShownAt = _lastShownAt;
    if (lastShownAt == null) return false;
    return DateTime.now().difference(lastShownAt) < _minGapBetweenAds;
  }

  void loadAd() {
    if (_isLoading || _interstitialAd != null) {
      return;
    }
    _isLoading = true;

    InterstitialAd.load(
      adUnitId: Platform.isIOS?
       AdsUnitKey.interstitalAdIdIOS
      : AdsUnitKey.interstitalAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoading = false;
          _interstitialAd = ad;
          // debugPrint('Interstitial ad loaded');
  
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) =>
                debugPrint('Interstitial ad showed'),
            onAdDismissedFullScreenContent: (ad) {
              // debugPrint('Interstitial ad dismissed');
              ad.dispose();
              _interstitialAd = null;

              final callback = _pendingCallback;
              _pendingCallback = null;

              loadAd();
              callback?.call();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('Interstitial failed to show: $error');

              ad.dispose();
              _interstitialAd = null;

              final callback = _pendingCallback;
              _pendingCallback = null;

              loadAd();

              callback?.call();
            },
          );

          if (_pendingCallback != null) {
            final callback = _pendingCallback;
            _pendingCallback = null;

            _showLoadedAd(callback);
          }
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          _interstitialAd = null;
          debugPrint('Interstitial failed to load: $error');

          final callback = _pendingCallback;
          _pendingCallback = null;

          callback?.call();
        },
      ),
    );
  }

  void showAd({VoidCallback? onAdDismissed}) {
    _opportunityCount++;

    final isDue = _opportunityCount % _showEveryNOpportunities == 0;
    if (!isDue || _isWithinCooldown) {
      onAdDismissed?.call();
      return;
    }

    if (_interstitialAd != null) {
      _showLoadedAd(onAdDismissed);
      return;
    }

    _pendingCallback = onAdDismissed;

    loadAd();
  }

  void _showLoadedAd(VoidCallback? callback) {
    final ad = _interstitialAd;

    if (ad == null) {
      // debugPrint('Interstitial: no loaded ad available');

      callback?.call();
      return;
    }

    _interstitialAd = null;

    _pendingCallback = callback;

    _lastShownAt = DateTime.now();

    // debugPrint('Interstitial: showing ad...');

    ad.show();
  }

  void dispose() {
     _pendingCallback = null;
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
