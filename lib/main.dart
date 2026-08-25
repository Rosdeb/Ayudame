import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:middle_ware/services/firebasenotification/firebasenotification.dart';
import 'package:middle_ware/services/notifications/local_notifications_service.dart';
import 'package:middle_ware/utils/token_service.dart';
import 'core/localization/app_translations.dart';
import 'core/localization/locale_controller.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_colors.dart';
import 'controllers/deep_link_controller.dart';
import 'firebase_options.dart';

// Custom Route Observer for logging navigation
class AppRouteObserver extends GetObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    print('🔵 NAVIGATING TO: ${route.settings.name ?? "Unknown"}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    print('⬅️ POPPED FROM: ${route.settings.name ?? "Unknown"}');
    if (previousRoute != null) {
      print('✅ BACK TO: ${previousRoute.settings.name ?? "Unknown"}');
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    print('🗑️ REMOVED: ${route.settings.name ?? "Unknown"}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    print('🔄 REPLACING: ${oldRoute?.settings.name ?? "Unknown"} WITH ${newRoute?.settings.name ?? "Unknown"}');
  }
}



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final localNotificationsService =  LocalNotificationsService.instance();
  await localNotificationsService.init();

 // final firebaseMessagingService =  FirebaseMessagingService.instance();
 // await firebaseMessagingService.init(localNotificationsService: localNotificationsService);


  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  await NotificationService.initialize();
  await TokenService().init();

  await AppTranslations.init();
  final localeController = Get.put(LocaleController(), permanent: true);
  await localeController.loadSavedLocale();
  
  // Initialize Deep Link Controller
  Get.put(DeepLinkController(), permanent: true);

  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetBuilder<LocaleController>(
          builder: (localeController) => GetMaterialApp(
            title: 'Ayudame',
            debugShowCheckedModeBanner: false,

            // Initial route
            initialRoute: AppRoutes.splash,

            // GetX routes
            getPages: AppRoutes.pages,

            // Route Observer for logging
            navigatorObservers: [AppRouteObserver()],

            // Localization
            translations: AppTranslations(),
            locale: localeController.locale,
            fallbackLocale: AppTranslations.englishLocale,
            supportedLocales: const [
              AppTranslations.englishLocale,
              AppTranslations.spanishLocale,
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // Default transitions
            defaultTransition: Transition.rightToLeft,
            transitionDuration: const Duration(milliseconds: 300),

            // Theme
            theme: ThemeData(
              fontFamily: GoogleFonts.inter().fontFamily,
              textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
              primaryColor: AppColors.primary,
              scaffoldBackgroundColor: AppColors.scaffold,
              useMaterial3: true,

              // AppBar Theme
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
              ),

              // Card Theme
              cardTheme: const CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),

              // Input Decoration Theme
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),

              // Elevated Button Theme
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              // Text Button Theme
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),

              // Color Scheme
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                primary: AppColors.primary,
                secondary: AppColors.secondary,
                error: AppColors.error,
                surface: AppColors.surface,
              ),
            ),
          ),
        );
      },
    );
  }
}
