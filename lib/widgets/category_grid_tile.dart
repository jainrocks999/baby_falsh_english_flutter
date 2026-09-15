import 'package:baby_flash_apps/core/constants/app_colors.dart';
import 'package:baby_flash_apps/core/utils/responsive.dart';
import 'package:flutter/material.dart';

class CategoryGridTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subText;
  final Color cardBg;
  final VoidCallback onTap;
  final IconData? secondaryIcon;
  final VoidCallback? onSecondaryTap;

  const CategoryGridTile({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subText,
    required this.cardBg,
    required this.onTap,
    this.secondaryIcon,
    this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTablet = ResponsiveUtils.isTablet(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              spreadRadius: 1,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Image.asset(imagePath, fit: BoxFit.contain),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "BubblegumSans",
                    fontSize: ResponsiveUtils.fontSize(
                      context,
                      isTablet ? 3.2 : 4.4,
                    ),
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryTxt,
                  ),
                ),
                Text(
                  subText,
                  style: TextStyle(
                    fontFamily: "BubblegumSans",
                    fontSize: ResponsiveUtils.fontSize(
                      context,
                      isTablet ? 2 : 3,
                    ),
                    color: AppColors.primaryTxt,
                  ),
                ),
              ],
            ),
            if (secondaryIcon != null && onSecondaryTap != null)
              Positioned(
                top: -8,
                right: -8,
                child: GestureDetector(
                  onTap: onSecondaryTap,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 4),
                      ],
                    ),
                    child: Icon(
                      secondaryIcon,
                      size: isTablet ? 18 : 20,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
