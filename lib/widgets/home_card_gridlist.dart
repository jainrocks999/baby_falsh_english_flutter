import 'package:baby_flash_apps/core/constants/app_colors.dart';
import 'package:baby_flash_apps/core/constants/app_language.dart';
import 'package:baby_flash_apps/core/constants/category.dart';
import 'package:baby_flash_apps/core/utils/helper.dart';
import 'package:baby_flash_apps/database/db_provider.dart';
import 'package:baby_flash_apps/router/route_paths.dart';
import 'package:baby_flash_apps/widgets/home_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeCardGridlist extends ConsumerWidget {
  const HomeCardGridlist({super.key});

  void handleOnPress({
    required BuildContext context,
    required dynamic item,
    required int index,
    required bool questionMode,
  }) {
    final route = questionMode ? RoutePaths.exercise : RoutePaths.detail;

    context.push(route, extra: {'category': item.category, 'index': index});
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dbProvider);
    final cards = AppLanguageConfig.hideAlphabetCategory
        ? homeCardList.where((item) => item.category != 'Alphabet').toList()
        : homeCardList;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (context, index) {
        final item = cards[index];

        return HomeCards(
          imagePath: item.imagePath,
          title: item.title,
          subText: AppHelpers.getCount(item.category, state.categoryCounts),
          cardBg: item.cardBg,
          btnBg: item.btnBg ?? AppColors.primaryBtnBg,
          onPress: () => handleOnPress(
            context: context,
            item: item,
            index: index,
            questionMode: state.questionMode,
          ),
        );
      },
    );
  }
}
