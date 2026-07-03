import 'package:aivideoprompt/widgets/text_app.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utils/colors.dart';
import 'custom_app_dialog.dart';

class SupportLoginDialog extends StatefulWidget {
  const SupportLoginDialog({super.key});

  @override
  State<SupportLoginDialog> createState() => _SupportLoginDialogState();
}

class _SupportLoginDialogState extends State<SupportLoginDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: AppColors.mainBackground, // White
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.5),
            width: 1.2.w,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
              blurRadius: 24.r,
              offset: Offset(0.w, 12.h),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Close button in top-right
            Positioned(
              top: 0.h,
              right: 0.w,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32.w,
                  height: 32.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.6),
                      width: 1.w,
                    ),
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.xmark,
                    size: 14.sp,
                    color: AppColors.textPrimary, // Made slightly darker to match screenshot
                  ),
                ),
              ),
            ),
            
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                // Title
                Center(
                  child: AppText(
                    'For support',
                    textColor: AppColors.textPrimary,
                    textSize: 22.sp,
                    textWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30.h),
                
                // Name account field
                AppText(
                  'Name account',
                  textColor: AppColors.textPrimary,
                  textSize: 15.sp,
                  textWeight: FontWeight.w600,
                ),
                SizedBox(height: 8.h),
                _buildTextField(
                  controller: _nameController,
                  hintText: 'Enter name account',
                ),
                SizedBox(height: 20.h),
                
                // Password field
                AppText(
                  'Password',
                  textColor: AppColors.textPrimary,
                  textSize: 15.sp,
                  textWeight: FontWeight.w600,
                ),
                SizedBox(height: 8.h),
                _buildTextField(
                  controller: _passwordController,
                  hintText: 'Enter password',
                  obscureText: true,
                ),
                SizedBox(height: 30.h),
                
                // Login Button
                ScaleButton(
                  onTap: () {
                    // TODO: Implement Login Action
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 52.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(30.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 14.r,
                          offset: Offset(0.w, 6.h),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: AppText(
                      'Login',
                      textSize: 16.sp,
                      textWeight: FontWeight.bold,
                      textColor: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 1.5.w,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.textMuted.withValues(alpha: 0.6),
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
        ),
      ),
    );
  }
}
