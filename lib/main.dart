import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/splash/welcome_back_screen.dart';
import 'services/app_state.dart';
import 'services/analytics_service.dart';
import 'utils/colors.dart';
import 'utils/common_utils.dart';
import 'utils/strings.dart';
import 'utils/text_app.dart';
import 'adsmanager/ad_service.dart';
import 'adsmanager/ad_ids.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'services/remote_config_service.dart';
import 'services/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  try {
    await Firebase.initializeApp();
    await RemoteConfigService.instance.initialize();
    
    // Initialize notifications and schedule random Firebase alerts
    await NotificationService.instance.initialize();
    await NotificationService.instance.requestPermissions();
    NotificationService.instance.scheduleDailyNotifications();
  } catch (e) {
    CommonUtils.printLog('Firebase initialization failed: $e');
  }

  await AdService.instance.initialize();
  // Preload App Open Ad so it is ready after splash
  AdService.instance.loadAppOpenAd(adUnitId: AdIds.appOpenAdUnitId);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
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
        _showWelcomeBackIfNeeded();
      }
    }
  }

  Future<void> _showWelcomeBackIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      if (hasSeenOnboarding) {
        navigatorKey.currentState?.push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const WelcomeBackScreen(isResume: true),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    } catch (e) {
      CommonUtils.printLog('Error showing welcome back screen on resume: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          title: AppStrings.appName,
          navigatorKey: navigatorKey,
          navigatorObservers: [AnalyticsService.instance.observer],
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
            textTheme: AppTextStyles.getTextTheme(ThemeData.light().textTheme),
            useMaterial3: true,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

