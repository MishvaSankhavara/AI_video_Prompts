import 'package:flutter/material.dart';
import '../utils/text_app.dart';

class VideoLoadingIndicator extends StatelessWidget {
  const VideoLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          bottomRight: Radius.circular(15),
          topRight: Radius.circular(2),
          bottomLeft: Radius.circular(2),
        ),
      ),
      child: Text(
        'Loading..',
        style: AppTextStyles.getStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
