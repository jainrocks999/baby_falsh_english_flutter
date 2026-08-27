import 'package:flutter/foundation.dart';

/// Ads are always on in release. Debug can toggle them off from Settings.
class AdsEnabled {
  static final ValueNotifier<bool> debugEnabled = ValueNotifier(true);

  static bool get isEnabled => !kDebugMode || debugEnabled.value;
}
