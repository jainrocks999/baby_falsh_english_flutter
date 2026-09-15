import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static const musicKey = 'MUSIC';
  static const soundKey = 'SOUND';
  static const swipeKey = 'SWIPE';

  static Future<void> setMusic(bool value) async {
    await _storage.write(key: musicKey, value: value.toString());
  }

  static Future<void> setSound(bool value) async {
    await _storage.write(key: soundKey, value: value.toString());
  }

  static Future<void> setSwipe(bool value) async {
    await _storage.write(key: swipeKey, value: value.toString());
  }

  static Future<bool> getMusic() async {
    final value = await _storage.read(key: musicKey);
    return value == null ? true : value == 'true';
  }

  static Future<bool> getSound() async {
    final value = await _storage.read(key: soundKey);
    return value == null ? true : value == 'true';
  }

  static Future<bool> getSwipe() async {
    final value = await _storage.read(key: swipeKey);
    return value == null ? true : value == 'true';
  }
}
