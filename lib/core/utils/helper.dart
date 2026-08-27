// import 'dart:math';

import 'package:baby_flash_apps/core/constants/app_language.dart';
import 'package:baby_flash_apps/screens/setting/settings_screen.dart';
import 'package:baby_flash_apps/widgets/activity_complete_modal.dart';
import 'package:flutter/material.dart';

class AppHelpers {
  static void showSettingModal(
    BuildContext context, {
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SettingsScreen(),
    );
  }

  static String getLanguageFolder(String? langName) {
    if (langName == null || langName.trim().isEmpty) {
      return AppLanguageConfig.soundFolder;
    }
    switch (langName.toLowerCase()) {
      case 'fre/fra':
        return 'french';
      case 'de':
        return 'german';
      case 'it':
        return 'italian';
      case 'es':
        return 'spanish';
      case 'en':
        return 'english';
      case 'ar':
      case 'ara':
      case 'arabic':
        return 'arabic';
      default:
        return 'japanies';
    }
  }

  static String? normalizeSoundFile(dynamic name) {
    if (name == null) return null;
    final value = name.toString().trim();
    if (value.isEmpty || value == '0') return null;
    return value.replaceAll(' ', '_').replaceAll('-', '_');
  }

  static String getModifiedImgName({
    required String image,
    required String langName,
  }) {
    final folder = getLanguageFolder(langName);

    String suffix = '';
    switch (folder) {
      case 'italian':
        suffix = '_it';
        break;
      case 'spanish':
        suffix = '_es';
        break;
      case 'japanies':
        suffix = '_jap';
        break;
    }
    final parts = image.split('.');
    if (parts.length < 2) return image;

    final name = parts.first;
    final ext = parts.last;
    return '$name$suffix.$ext';
  }

  static String getCount(String key, Map<String, int> counts) {
    final value = counts[key] ?? 0;
    return "Total $value Items";
  }

  static List<Map<String, dynamic>> getRandomItems(
    List<Map<String, dynamic>> data,
    Set<int> usedQuestionIndexes, {
    int count = 4,
  }) {
    //pick available questions
    final availableQuestions = List.generate(
      data.length,
      (i) => i,
    ).where((i) => !usedQuestionIndexes.contains(i)).toList();

    // reset if all used
    if (availableQuestions.isEmpty) {
      usedQuestionIndexes.clear();
      return getRandomItems(data, usedQuestionIndexes, count: count);
    }

    availableQuestions.shuffle();
    final questionIndex = availableQuestions.first;
    usedQuestionIndexes.add(questionIndex);

    final otherIndexes = List.generate(data.length, (i) => i)
      ..remove(questionIndex);

    otherIndexes.shuffle();
    final options = otherIndexes.take(count - 1).toList();

    final result = [questionIndex, ...options]..shuffle();

    return result.map((i) => data[i]).toList();
  }

  static Future<int> showAfterCompleteActivityModal(
    BuildContext context,
    int currentIndex, {
    VoidCallback? onConfirm,
  }) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ActivityCompleteModal(currentIndex: currentIndex),
    );
  }
}
