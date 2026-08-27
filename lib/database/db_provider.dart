import 'package:baby_flash_apps/core/constants/app_language.dart';
import 'package:baby_flash_apps/database/db_repository.dart';
import 'package:baby_flash_apps/services/secure_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/legacy.dart';

final dbProvider = StateNotifierProvider<DbNotifier, DbState>(
  (ref) => DbNotifier(DbRepository()),
);

class DbState {
  final bool isLoading;
  final String? message;
  final bool isSuccess;
  final List<Map<String, dynamic>> data;
  final Map<String, int> categoryCounts;
  final bool questionMode;
  final bool isSoundOn;
  final bool isMusicOn;
  final bool isShowLangTxt;
  final bool isSwpieOn;

  const DbState({
    this.isLoading = false,
    this.message,
    this.isSuccess = false,
    this.data = const [],
    this.categoryCounts = const {},
    this.questionMode = false,
    this.isSoundOn = false,
    this.isMusicOn = false,
    this.isShowLangTxt = false,
    this.isSwpieOn = false,
  });

  DbState copyWith({
    bool? isLoading,
    String? message,
    bool? isSuccess,
    List<Map<String, dynamic>>? data,
    Map<String, int>? categoryCounts,
    bool? questionMode,
    bool? isSoundOn,
    bool? isMusicOn,
    bool? isShowLangTxt,
    bool? isSwpieOn,
  }) {
    return DbState(
      isLoading: isLoading ?? this.isLoading,
      message: message,
      isSuccess: isSuccess ?? this.isSuccess,
      data: data ?? this.data,
      categoryCounts: categoryCounts ?? this.categoryCounts,
      questionMode: questionMode ?? this.questionMode,
      isSoundOn: isSoundOn ?? this.isSoundOn,
      isMusicOn: isMusicOn ?? this.isMusicOn,
      isShowLangTxt: isShowLangTxt ?? this.isShowLangTxt,
      isSwpieOn: isSwpieOn ?? this.isSwpieOn,
    );
  }
}

class DbNotifier extends StateNotifier<DbState> {
  final DbRepository repository;
  DbNotifier(this.repository)
    : super(
        DbState(isShowLangTxt: AppLanguageConfig.showLanguageText),
      );

  ///clear the state
  void clearData() {
    state = state.copyWith(
      data: [],
      isLoading: false,
      message: null,
      isSuccess: false,
    );
  }

  Future<void> loadQuestionMode() async {
    try {
      final value = await SecureStorage.getQuesMode();

      state = state.copyWith(questionMode: value);
    } catch (e) {
      state = state.copyWith(message: e.toString());
    }
  }

  Future<void> loadSoundSettings() async {
    try {
      final valueMusic = await SecureStorage.getMusic();
      final valueSound = await SecureStorage.getSound();
      final valueSwipe = await SecureStorage.getSwipe();
      state = state.copyWith(
        isMusicOn: valueMusic,
        isSoundOn: valueSound,
        isShowLangTxt: AppLanguageConfig.showLanguageText,
        isSwpieOn: valueSwipe,
      );
    } catch (e) {
      state = state.copyWith(message: e.toString());
    }
  }

  Future<void> fetchData({
    String? category,
    bool random = false,
    int limit = 0,
  }) async {
    state = state.copyWith(
      isLoading: true,
      message: null,
      data: [],
      isSuccess: false,
    );

    try {
      final result = await repository.fetchData(
        tableName: AppLanguageConfig.tableName,
        category: category,
        random: random,
        limit: limit,
      );
      debugPrint("result==>>>> $result");
      state = state.copyWith(isLoading: false, data: result, isSuccess: true);
    } catch (e) {
      debugPrint('error of Fetch Data $e');
      state = state.copyWith(
        isLoading: false,
        message: e.toString(),
        isSuccess: false,
      );
    }
  }

  Future<void> loadCateCounts() async {
    try {
      state = state.copyWith(isLoading: true);

      final result = await repository.getCategoryCounts(
        tableName: AppLanguageConfig.tableName,
      );
      state = state.copyWith(
        isLoading: false,
        categoryCounts: result,
        isSuccess: true,
      );
    } catch (e) {
      debugPrint('error of cate Count $e');
      state = state.copyWith(
        isLoading: false,
        message: e.toString(),
        isSuccess: false,
      );
    }
  }
}
