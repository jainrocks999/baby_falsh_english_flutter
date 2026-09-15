import 'package:baby_flash_apps/core/utils/helper.dart';
import 'package:baby_flash_apps/core/utils/responsive.dart';
import 'package:baby_flash_apps/router/route_paths.dart';
import 'package:baby_flash_apps/widgets/icon_elevated_btn.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({
    super.key,
    this.showBackButton = false,
    this.showSettingsButton = true,
  });

  final bool showBackButton;
  final bool showSettingsButton;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final current = GoRouterState.of(context).path;
    final isDetail =
        (current?.contains(RoutePaths.detail) ?? false) ||
        (current?.contains(RoutePaths.exercise) ?? false);

    final bool isTablet = ResponsiveUtils.isTablet(context);

    return AppBar(
      // toolbarHeight: 75,
      toolbarHeight: ResponsiveUtils.height(context, isTablet ? 12 : 9),
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: showBackButton
          ? ResponsiveUtils.width(context, isTablet ? 15 : 20)
          : null,
      leading: showBackButton
          ? Padding(
              padding: const EdgeInsets.only(left: 15),
              child: IconElevatedBtn(
                size: ResponsiveUtils.width(context, isTablet ? 10 : 16),
                assetPath: 'assets/svgs/back_btn.svg',
                onPressed: () {
                  Navigator.of(context).maybePop();
                },
                elevation: 0,
              ),
            )
          : null,
      actions: [
        if (!isDetail && showSettingsButton)
          IconElevatedBtn(
            size: ResponsiveUtils.width(context, isTablet ? 12 : 18),
            assetPath: 'assets/svgs/setting_btn.svg',
            onPressed: () {
              AppHelpers.showSettingModal(context);
            },
            elevation: 0,
          ),
        const SizedBox(width: 15),
      ],
    );
  }
}
