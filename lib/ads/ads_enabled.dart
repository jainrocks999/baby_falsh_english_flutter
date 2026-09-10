import 'package:baby_flash_apps/services/secure_storage.dart';
import 'package:flutter/foundation.dart';

/// Debug-only ads toggle. Release builds always show ads.
class AdsEnabled {
  AdsEnabled._();

  static final ValueNotifier<bool> notifier = ValueNotifier<bool>(true);

  static bool get value {
    if (!kDebugMode) return true;
    return notifier.value;
  }

  static Future<void> load() async {
    if (!kDebugMode) {
      notifier.value = true;
      return;
    }
    notifier.value = await SecureStorage.getAdsEnabled();
  }

  static Future<void> set(bool enabled) async {
    if (!kDebugMode) return;
    notifier.value = enabled;
    await SecureStorage.setAdsEnabled(enabled);
  }
}
