import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:middle_ware/core/theme/app_colors.dart';
import 'package:middle_ware/utils/location_helper.dart';
import 'package:middle_ware/views/onboarding/UserProviderSelectionScreen.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class LocationAccessScreen extends StatelessWidget {
  const LocationAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.mainAppColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  size: 32,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              Text(
                AppTranslations.translateValue(
                  'onboarding.location_access_title',
                ),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                AppTranslations.translateValue(
                  'onboarding.location_access_subtitle',
                ),
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final location = await getUserLocation();

                    if (location != null) {
                      print("Latitude: ${location.latitude}");
                      print("Longitude: ${location.longitude}");

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserProviderSelectionScreen(signupFlow: true),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppTranslations.translateValue(
                              'onboarding.please_allow_location',
                            ),
                          ),
                        ),
                      );
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C5941),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    AppTranslations.translateValue(
                      'onboarding.allow_location_access',
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
