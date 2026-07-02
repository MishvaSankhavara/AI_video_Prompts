import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



class AppText extends StatelessWidget {
  final String text;
  final double? textSize;
  final FontWeight? textWeight;
  final Color? textColor;
  final TextAlign? textAlignment;
  final int? maxLinesCount;
  final TextOverflow? fontOverflow;
  final TextDecoration? textDecoration;
  final double? fontHeight;
  final double? lettersSpace;

  const AppText(
    this.text, {
    super.key,
    this.textSize,
    this.textWeight,
    this.textColor,
    this.textAlignment,
    this.maxLinesCount,
    this.fontOverflow,
    this.textDecoration,
    this.fontHeight,
    this.lettersSpace,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlignment,
      maxLines: maxLinesCount,
      overflow: fontOverflow,
      style: GoogleFonts.poppins(
        fontSize: textSize,
        fontWeight: textWeight,
        color: textColor,
        decoration: textDecoration,
        height: fontHeight,
        letterSpacing: lettersSpace,
      ),
    );
  }
}
