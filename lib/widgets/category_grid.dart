import 'package:baby_flash_apps/core/utils/helper.dart';
import 'package:baby_flash_apps/core/utils/responsive.dart';
import 'package:baby_flash_apps/model/home_card.dart';
import 'package:baby_flash_apps/widgets/category_grid_tile.dart';
import 'package:flutter/material.dart';

class CategoryGrid extends StatelessWidget {
  final List<HomeCardData> items;
  final Map<String, int> categoryCounts;
  final void Function(HomeCardData item, int index) onTap;
  final IconData? secondaryIcon;
  final void Function(HomeCardData item, int index)? onSecondaryTap;

  const CategoryGrid({
    super.key,
    required this.items,
    required this.categoryCounts,
    required this.onTap,
    this.secondaryIcon,
    this.onSecondaryTap,
  });

  static const double _spacing = 14;
  static const double _runSpacing = 18;
  static const double _aspectRatio = 0.85;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = ResponsiveUtils.isTablet(context);
    final crossAxisCount = isTablet ? 4 : 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSpacing = _spacing * (crossAxisCount - 1);
        final tileWidth = (constraints.maxWidth - totalSpacing) / crossAxisCount;
        final tileHeight = tileWidth / _aspectRatio;

        return Wrap(
          spacing: _spacing,
          runSpacing: _runSpacing,
          children: [
            for (int index = 0; index < items.length; index++)
              SizedBox(
                width: tileWidth,
                height: tileHeight,
                child: CategoryGridTile(
                  imagePath: items[index].imagePath,
                  title: items[index].title,
                  subText: AppHelpers.getCount(
                    items[index].category,
                    categoryCounts,
                  ),
                  cardBg: items[index].cardBg,
                  onTap: () => onTap(items[index], index),
                  secondaryIcon: secondaryIcon,
                  onSecondaryTap: onSecondaryTap == null
                      ? null
                      : () => onSecondaryTap!(items[index], index),
                ),
              ),
          ],
        );
      },
    );
  }
}
