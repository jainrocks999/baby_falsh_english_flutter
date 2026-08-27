import 'package:flutter/foundation.dart';
import 'package:baby_flash_apps/core/constants/app_language.dart';

class AdsUnitKey {
  static String get bannerAdId =>
      kDebugMode
          ? 'ca-app-pub-3940256099942544/6300978111'
          : AppLanguageConfig.bannerAdId;

  static String get bannerAdIdIOS =>
      kDebugMode
          ? 'ca-app-pub-3940256099942544/2934735716'
          : AppLanguageConfig.bannerAdIdIOS;

  static String get interstitalAdId =>
      kDebugMode
          ? 'ca-app-pub-3940256099942544/1033173712'
          : AppLanguageConfig.interstitialAdId;

  static String get interstitalAdIdIOS =>
      kDebugMode
          ? 'ca-app-pub-3940256099942544/4411468910'
          : AppLanguageConfig.interstitialAdIdIOS;
}