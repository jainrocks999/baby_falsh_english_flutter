import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/rendering.dart';

class MusicService {
  static const double _normalVolume = 1.0;
  static const double _duckedVolume = 0.25;
  static const double effectsVolume = 1.0;

  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;

  MusicService._internal();

  static final AudioContext backgroundMusicAudioContext = AudioContext(
    android: AudioContextAndroid(
      isSpeakerphoneOn: true,
      stayAwake: false,
      contentType: AndroidContentType.music,
      usageType: AndroidUsageType.media,
      audioFocus: AndroidAudioFocus.none,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: {AVAudioSessionOptions.mixWithOthers},
    ),
  );

  static final AudioContext effectsAudioContext = AudioContext(
    android: AudioContextAndroid(
      isSpeakerphoneOn: true,
      contentType: AndroidContentType.music,
      usageType: AndroidUsageType.media,
      audioFocus: AndroidAudioFocus.none,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: {AVAudioSessionOptions.mixWithOthers},
    ),
  );

  final AudioPlayer _musicPlayer = AudioPlayer(playerId: 'music');
  bool _isInitialized = false;
  int _duckingRequests = 0;

  Future<void> playMusic({String path = 'helpers/babyflashtheme.mp3'}) async {
    try {
      if (!_isInitialized) {
        await _musicPlayer.setReleaseMode(ReleaseMode.loop);
        await _musicPlayer.setAudioContext(backgroundMusicAudioContext);
        _isInitialized = true;
      }
      _duckingRequests = 0;
      await _musicPlayer.setVolume(_normalVolume);
      await _musicPlayer.stop();
      await _musicPlayer.play(AssetSource(path));
    } catch (e) {
      debugPrint("Music error: $e");
    }
  }

  Future<void> stopMusic() async {
    try {
      _duckingRequests = 0;
      await _musicPlayer.setVolume(_normalVolume);
      await _musicPlayer.stop();
    } catch (e) {
      debugPrint("Stop music error: $e");
    }
  }

  Future<void> duckMusic() async {
    try {
      _duckingRequests++;
      if (!_isInitialized) return;
      await _musicPlayer.setVolume(_duckedVolume);
    } catch (e) {
      debugPrint("Duck music error: $e");
    }
  }

  Future<void> restoreMusicVolume() async {
    try {
      if (_duckingRequests > 0) {
        _duckingRequests--;
      }
      if (_duckingRequests > 0 || !_isInitialized) return;
      await _musicPlayer.setVolume(_normalVolume);
    } catch (e) {
      debugPrint("Restore music error: $e");
    }
  }

  Future<T> runWithDuckedMusic<T>(Future<T> Function() action) async {
    await duckMusic();
    try {
      return await action();
    } finally {
      await restoreMusicVolume();
    }
  }
}
