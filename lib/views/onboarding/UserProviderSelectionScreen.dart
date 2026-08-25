import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:middle_ware/core/theme/app_colors.dart';

import '../../core/localization/app_translations.dart';
import '../../core/routes/app_routes.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class UserProviderSelectionScreen extends StatefulWidget {
  const UserProviderSelectionScreen({super.key, this.signupFlow = false});

  final bool signupFlow;

  @override
  State<UserProviderSelectionScreen> createState() =>
      _UserProviderSelectionScreenState();
}

class _UserProviderSelectionScreenState
    extends State<UserProviderSelectionScreen> {
  String selectedRole = 'user';
  String t(String key) => AppTranslations.translateValue(key);

  bool get _isSignupFlow {
    final args = Get.arguments;
    if (args is Map && args['signupFlow'] == true) return true;
    return widget.signupFlow;
  }

  void _navigateToSelectedScreen() {
    switch (selectedRole) {
      case 'user':
        Get.toNamed(
          _isSignupFlow ? AppRoutes.userregister : AppRoutes.userlogin,
        );
        break;
      case 'provider':
        Get.toNamed(
          _isSignupFlow ? AppRoutes.providerRegister : AppRoutes.providerLogin,
        );
        break;
      case 'business_owner':
        Get.toNamed(
          _isSignupFlow ? AppRoutes.businessRegister : AppRoutes.businessLogin,
        );
        break;
      case 'event_manager':
        Get.toNamed(
          _isSignupFlow ? AppRoutes.eventRegister : AppRoutes.eventLogin,
        );
        break;
    }
  }

  Widget _buildSelectionCard({
    required String role,
    required String labelKey,
    required String iconPath,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
        });
      },
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1C5941) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1C5941)
                : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 28,
              height: 28,
              colorFilter: ColorFilter.mode(
                isSelected ? Colors.white : const Color(0xFF1C5941),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t(labelKey),
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF1C5941),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // First Row
              Row(
                children: [
                  Expanded(
                    child: _buildSelectionCard(
                      role: 'user',
                      labelKey: 'onboarding.user',
                      iconPath: 'assets/images/user.svg',
                      isSelected: selectedRole == 'user',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSelectionCard(
                      role: 'provider',
                      labelKey: 'onboarding.provider',
                      iconPath: 'assets/images/provider.svg',
                      isSelected: selectedRole == 'provider',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Second Row
              Row(
                children: [
                  Expanded(
                    child: _buildSelectionCard(
                      role: 'business_owner',
                      labelKey: 'onboarding.business',
                      iconPath: 'assets/images/business.svg',
                      isSelected: selectedRole == 'business_owner',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSelectionCard(
                      role: 'event_manager',
                      labelKey: 'onboarding.event_manager',
                      iconPath: 'assets/images/event.svg',
                      isSelected: selectedRole == 'event_manager',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _navigateToSelectedScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C5941),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    t('common.continue'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
