import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// - Pushing: Slides up from bottom to top.
/// - Popping (Back Button): Slides out from left to right.
///
class NavigationService {
  const NavigationService._();

  /// - Forward (Push): Slides up from bottom to top.
  /// - Reverse (Pop): Slides out from left to right.
  static Route<T> _createRoute<T>(Widget screen) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Detect if the route is popping (reverse animation)
        final isPopping = animation.status == AnimationStatus.reverse;

        // Slide from bottom on push, slide out to the right on pop
        final begin = isPopping ? Offset(1.w, 0.h) : Offset(0.w, 1.h);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);

        // Elegant fade transition
        final fadeTween = Tween<double>(begin: 0, end: 1);
        final fadeAnimation = animation.drive(fadeTween);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 350),
    );
  }

  /// Pushes a new screen onto the navigator stack.
  static Future<T?> push<T>(BuildContext context, Widget screen) {
    return Navigator.of(context).push<T>(_createRoute<T>(screen));
  }

  /// Replaces the current screen with a new screen.
  static Future<T?> pushReplacement<T, TO>(BuildContext context, Widget screen) {
    return Navigator.of(context).pushReplacement<T, TO>(_createRoute<T>(screen));
  }

  /// Pushes a new screen and removes all previous routes from the stack.
  static Future<T?> pushAndRemoveUntil<T>(BuildContext context, Widget screen) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      _createRoute<T>(screen),
      (route) => false,
    );
  }

  /// Pops the current screen off the navigator stack.
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }
}
