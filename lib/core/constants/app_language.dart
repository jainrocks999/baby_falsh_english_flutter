enum AppLanguage {
  english,
  french,
  italian,
  japanese,
  spanish,
}

/// Change [language] once, then build the APK.
///
/// English  → `AppLanguage.english`
/// French   → `AppLanguage.french`
/// Italian  → `AppLanguage.italian`
/// Japanese → `AppLanguage.japanese`
/// Spanish  → `AppLanguage.spanish`
class AppLanguageConfig {
  /// 👇 Only this line needs to change before a new APK build.
  static const AppLanguage language = AppLanguage.english;

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
}
