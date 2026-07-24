import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/splash/welcome_back_screen.dart';
import 'services/favorites_service.dart';
import 'services/shareed_prefe.dart';
import 'viewmodel/fetch_video_category.dart';
// import 'services/analytics_service.dart';
import 'utils/colors.dart';
import 'utils/common_utils.dart';
import 'utils/constants.dart';
import 'utils/strings.dart';
import 'widgets/text_app.dart';
import 'adsmanager/ad_manager.dart';
import 'adsmanager/app_open_ad_service.dart';
import 'adsmanager/ad_ids.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'services/firebase/remote_config_service.dart';
import 'services/notification_service.dart';
import 'services/firebase/firebase_notification_service.dart';
import 'package:google_fonts/google_fonts.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  try {
    print('>>> MAIN: Initializing Firebase...');
    await Firebase.initializeApp();
    print('>>> MAIN: Firebase initialized successfully');

    if (kDebugMode) {
      // Disable Crashlytics collection while debugging
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    } else {
      // Enable Crashlytics collection for release
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      
      // Pass all uncaught "fatal" errors from the framework to Crashlytics
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }

    await RemoteConfigService.instance.initialize();
    print('>>> MAIN: RemoteConfig initialized');

    // Initialize FCM and local notifications
    await FirebaseNotificationService.instance.initialize();
    print('>>> MAIN: FirebaseNotificationService initialized');
    await FirebaseNotificationService.instance.requestPermissions();

    await NotificationService.instance.initialize();
    await NotificationService.instance.requestPermissions();
    NotificationService.instance.scheduleDailyNotifications();
  } catch (e) {
    print('===================================================');
    print('FIREBASE INITIALIZATION FAILED: $e');
    print('===================================================');
  }

  // AdManager.initialize is now delayed until after ATT consent is requested in splash_screen.dart
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoritesService()),
        ChangeNotifierProvider(create: (_) => FetchVideoCategoryViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _wasPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      _wasPaused = true;
    } else if (state == AppLifecycleState.resumed) {
      if (_wasPaused) {
        _wasPaused = false;
        if (!AppConstants.isAdShowing) {
          _showWelcomeBackIfNeeded();
        }
      }
    }
  }

  Future<void> _showWelcomeBackIfNeeded() async {
    try {
      final hasSeenOnboarding = await SharedPrefs.hasSeenOnboarding();
      if (hasSeenOnboarding) {
        navigatorKey.currentState?.push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const WelcomeBackScreen(isResume: true),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    } catch (e) {
      // CommonUtils.printLog('Error showing welcome back screen on resume: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: AppStrings.appName,
          navigatorKey: navigatorKey,
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
          ],
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.mainBackground,
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              surface: AppColors.cardBackground,
            ),
            textTheme: GoogleFonts.plusJakartaSansTextTheme(
              ThemeData.light().textTheme,
            ),
            useMaterial3: true,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
