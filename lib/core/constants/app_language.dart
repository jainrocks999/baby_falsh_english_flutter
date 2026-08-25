enum AppLanguage {
  english,
  french,
  italian,
  japanese,
  spanish,
}

class AppAdUnits {
  final String bannerAndroid;
  final String bannerIos;
  final String interstitialAndroid;
  final String interstitialIos;

  const AppAdUnits({
    required this.bannerAndroid,
    required this.bannerIos,
    required this.interstitialAndroid,
    required this.interstitialIos,
  });
}

/// Change [language] once, then build the APK.

/// This sets table, badge, and ad unit IDs automatically.
/// Android Manifest `APPLICATION_ID` still set manually.
class AppLanguageConfig {
  /// 👇 Only this line needs to change before a new APK build.
  static const AppLanguage language = AppLanguage.italian;

  static String get tableName {
    switch (language) {
      case AppLanguage.english:
        return 'tbl_items';
      case AppLanguage.french:
        return 'tbl_french';
      case AppLanguage.italian:
        return 'tbl_italian';
      case AppLanguage.japanese:
        return 'tbl_japanies';
      case AppLanguage.spanish:
        return 'tbl_spanish';
    }
  }

  static bool get isJapanese => language == AppLanguage.japanese;

  static bool get hideAlphabetCategory => isJapanese;

  /// Native word label on flashcards. Off for English APK.
  static bool get showLanguageText => language != AppLanguage.english;

  static String get languageBadgeAsset {
    switch (language) {
      case AppLanguage.english:
        return 'assets/images/languages/english.png';
      case AppLanguage.french:
        return 'assets/images/languages/french.png';
      case AppLanguage.italian:
        return 'assets/images/languages/italian.png';
      case AppLanguage.japanese:
        return 'assets/images/languages/japanese.png';
      case AppLanguage.spanish:
        return 'assets/images/languages/spanish.png';
    }
  }

  static const Map<AppLanguage, AppAdUnits> adUnits = {
    AppLanguage.english: AppAdUnits(
      bannerAndroid: 'ca-app-pub-6121378252341914/4051590879',
      bannerIos: 'ca-app-pub-6121378252341914/6304074496',
      interstitialAndroid: 'ca-app-pub-6121378252341914/5444563592',
      interstitialIos: 'ca-app-pub-6121378252341914/9445243157',
    ),
    AppLanguage.french: AppAdUnits(
      bannerAndroid: 'ca-app-pub-6121378252341914/7439000680',
      bannerIos: 'ca-app-pub-6121378252341914/9053238758',
      interstitialAndroid: 'ca-app-pub-6121378252341914/1509840988',
      interstitialIos: 'ca-app-pub-6121378252341914/2139406698',
    ),
    AppLanguage.italian: AppAdUnits(
      bannerAndroid: 'ca-app-pub-6121378252341914/7858209609',
      bannerIos: 'ca-app-pub-6121378252341914/1593369953',
      interstitialAndroid: 'ca-app-pub-6121378252341914/3201663775',
      interstitialIos: 'ca-app-pub-6121378252341914/8966639111',
    ),
    AppLanguage.japanese: AppAdUnits(
      bannerAndroid: 'PASTE_JAPANESE_BANNER_ANDROID',
      bannerIos: 'PASTE_JAPANESE_BANNER_IOS',
      interstitialAndroid: 'PASTE_JAPANESE_INTERSTITIAL_ANDROID',
      interstitialIos: 'PASTE_JAPANESE_INTERSTITIAL_IOS',
    ),
    AppLanguage.spanish: AppAdUnits(
      bannerAndroid: 'PASTE_SPANISH_BANNER_ANDROID',
      bannerIos: 'PASTE_SPANISH_BANNER_IOS',
      interstitialAndroid: 'PASTE_SPANISH_INTERSTITIAL_ANDROID',
      interstitialIos: 'PASTE_SPANISH_INTERSTITIAL_IOS',
    ),
  };

  static AppAdUnits get currentAds => adUnits[language]!;

  static String get bannerAdId => currentAds.bannerAndroid;
  static String get bannerAdIdIOS => currentAds.bannerIos;
  static String get interstitialAdId => currentAds.interstitialAndroid;
  static String get interstitialAdIdIOS => currentAds.interstitialIos;
}
