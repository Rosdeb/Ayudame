import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/routes/app_routes.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top illustration section
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              color: Colors.white,
              child: Center(
                child: Image.asset(
                  'assets/images/bro.png',
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 280,
            left: 0,
            child: Container(
              height: 150,
              child: Center(
                child: Image.asset(
                  'assets/images/Rectangle.png',
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 280,
            left: 0,
            child: Container(
              height: 110, // Fixed height

              child: Center(
                child: Image.asset(
                  'assets/images/Rectangleb.png',
                  height: 110,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          // Bottom section with SVG background
          Align(
            alignment: Alignment.bottomCenter,

            child: Container(
              // Top illustration section
              height: MediaQuery.of(context).size.height * 0.58,
              child: Stack(
                children: [
                  // SVG background
                  Image.asset(
                    'assets/images/svg_background.png',
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.58,
                    fit: BoxFit.fitHeight,
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),

                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2,
                        ),
                        Text(
                          AppTranslations.translateValue(
                            'onboarding.welcome_title',
                          ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppTranslations.translateValue(
                            'onboarding.welcome_subtitle',
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () async {
                              LocationPermission permission = await Geolocator.checkPermission();
                              if (permission == LocationPermission.always ||
                                  permission == LocationPermission.whileInUse) {
                                Get.offNamed(AppRoutes.userTypeSelection, arguments: {'signupFlow': true});
                              } else {
                                Get.offNamed(AppRoutes.location);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF2D5F4F),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              AppTranslations.translateValue(
                                'onboarding.get_started',
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppTranslations.translateValue(
                                'auth.already_have_account',
                              ),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(AppRoutes.userlogin);
                              },
                              child: Text(
                                AppTranslations.translateValue('auth.login'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
