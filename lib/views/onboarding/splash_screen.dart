import 'package:flutter/material.dart';
import 'package:middle_ware/core/theme/app_colors.dart';
import 'package:middle_ware/core/routes/app_routes.dart';
import 'package:middle_ware/utils/token_service.dart';
import 'package:middle_ware/services/storage_service.dart';
import 'package:get/get.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _homeRouteForRole(String? role) {
    switch ((role ?? '').trim().toLowerCase()) {
      case 'user':
        return AppRoutes.userBottomNavScreen;
      case 'provider':
        return AppRoutes.providerBottomNavScreen;
      case 'business':
      case 'business_owner':
      case 'businessowner':
        return AppRoutes.businessHome;
      case 'event_manager':
      case 'event-manager':
      case 'eventmanager':
        return AppRoutes.eventHome;
      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Wait for 2 seconds to show splash screen
    await Future.delayed(const Duration(seconds: 2));

    // Check if user has a valid token (support both token helpers)
    final tokenFromService = await TokenService().getToken();
    final tokenFromStorage = await StorageService.getToken();
    final token = (tokenFromService?.isNotEmpty ?? false)
        ? tokenFromService
        : tokenFromStorage;
    final role = await StorageService.getUserRole();
    final targetRoute = _homeRouteForRole(role);

    if (!mounted) return;

    if (token != null && token.isNotEmpty && targetRoute != null) {
      Navigator.pushReplacementNamed(context, targetRoute);
    } else {
      // User is not logged in or role is missing, navigate to onboarding flow
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Container(
        // Three-color linear gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF9CCCA9), // #9CCCA9 - Light green
              Color(0xFFFFFFFF), // #FFFFFF - White
              Color(0xFF9CCCA9), // #9CCCA9 - Light green
            ],
            stops: [0.0, 0.5, 1.0], // Control the position of each color
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo or icon with image
              Container(
                width: 180,
                height: 200,

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/splash.png', // Path to your image
                    fit: BoxFit
                        .cover, // How the image should be inscribed into the box
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                AppTranslations.translateValue('Ayudame'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
