import 'package:aivideoprompt/widgets/text_app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/colors.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color backgroundColor;
  final Color? surfaceTintColor;

  const CommonAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.backgroundColor = AppColors.white,
    this.surfaceTintColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: AppText(
        title,
        textColor: AppColors.textPrimary,
        textWeight: FontWeight.bold,
        textSize: 18.sp,
      ),
      leading: showBackButton
          ? IconButton(
              icon: FaIcon(
                FontAwesomeIcons.chevronLeft,
                color: AppColors.textPrimary,
                size: 18.sp,
              ),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      backgroundColor: backgroundColor,
      surfaceTintColor: surfaceTintColor,
      elevation: 0,
      centerTitle: false,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
