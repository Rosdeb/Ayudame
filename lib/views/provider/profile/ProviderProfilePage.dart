import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../services/notifications/firebase_messaging_service.dart';

import 'package:get/get.dart';
import 'package:middle_ware/core/app_icons.dart';
import 'package:middle_ware/core/routes/app_routes.dart';
import 'package:middle_ware/core/theme/app_colors.dart';
import 'package:middle_ware/views/provider/profile/help_support/ProviderHelpSupportScreen.dart';
import 'package:middle_ware/views/provider/profile/notification/ProviderNotificationPage.dart';
import 'package:middle_ware/views/provider/profile/portfolio/PortfolioListScreen.dart';
import 'package:middle_ware/views/provider/profile/privacy%20/ProviderPrivacyPolicyScreen.dart';
import 'package:middle_ware/views/provider/profile/terms/ProviderTermsConditionScreen.dart';
import 'package:middle_ware/views/provider/profile/All_services%20/all_services_page.dart';
import 'package:middle_ware/views/provider/profile/provider_bank_information.dart';
import 'package:middle_ware/views/provider/profile/edit_profile/provider_edit_profile.dart';
import 'package:middle_ware/views/provider/profile/provider_payment.dart';
import 'package:middle_ware/widgets/custom_appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../controller/provider/profile/provider_profile_controller.dart';
import '../../../controller/provider/home_provider_controller.dart';
import '../../../utils/token_service.dart';
import 'package:middle_ware/core/localization/app_translations.dart';
import 'package:middle_ware/services/storage_service.dart';

class ProviderProfilePage extends StatefulWidget {
  const ProviderProfilePage({Key? key}) : super(key: key);

  @override
  State<ProviderProfilePage> createState() => _ProviderProfilePageState();
}

class _ProviderProfilePageState extends State<ProviderProfilePage> {
  final ProviderProfileController controller = Get.put(
    ProviderProfileController(),
  );
  final HomeProviderController homeController = Get.put(
    HomeProviderController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: false,
        title: AppTranslations.translateValue("Profile"),
        onBackTap: () => Get.offAllNamed(AppRoutes.providerBottomNavScreen),
      ),
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (controller.errorMessage.isNotEmpty) {
                      return Center(
                        child: Text(controller.errorMessage.value),
                      );
                    }

                    final profile = controller.providerProfile.value;

                    if (profile == null) {
                      return Center(
                        child: Text(
                          AppTranslations.translateValue(
                            "No profile data found",
                          ),
                        ),
                      );
                    }

                    return Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.09),
                            offset: Offset(0, 2),
                            blurRadius: 1,
                            spreadRadius: 0
                          )
                        ]
                      ),
                      child: Row(
                          children: [
                            // Profile Image
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 35,
                                backgroundImage:
                                profile.userId.profilePicture != null &&
                                    profile.userId.profilePicture!.isNotEmpty
                                    ? NetworkImage(
                                  profile.userId.profilePicture!,
                                )
                                    : const AssetImage(
                                  "assets/images/emptyUser.png",
                                ) as ImageProvider,
                              ),
                            ),

                            const SizedBox(width: 16),

                            // User Information
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.userId.fullName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    profile.userId.email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Inter",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    );
                  }),

                  const SizedBox(height: 10,),
                  Obx(() => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          // --- My Order Card ---
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9F8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        AppIcons.my_order,
                                        width: 20,
                                        height: 20,
                                        colorFilter: ColorFilter.mode(
                                          Colors.grey.shade700,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        AppTranslations.translateValue('My Order',),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  IntrinsicHeight(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        // This Month Section
                                        Column(
                                          children: [
                                            Text(
                                              AppTranslations.translateValue('This Month',),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              homeController.myOrdersThisMonth
                                                  .value
                                                  .toString()
                                                  .padLeft(2, '0'),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Vertical Divider
                                        VerticalDivider(
                                          color: Colors.grey.shade400,
                                          thickness: 1,
                                        ),
                                        // Total Section
                                        Column(
                                          children: [
                                            Text(
                                              AppTranslations.translateValue('Total',),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              homeController.myOrdersTotal.value.toString().padLeft(2, '0'),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // --- Total Income Card ---
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              height: 105,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9F8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        AppIcons.total_income,
                                        width: 20,
                                        height: 20,
                                        colorFilter: ColorFilter.mode(
                                          Colors.grey.shade700,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        AppTranslations.translateValue('Total Income',),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    AppTranslations.translateValue(
                                      '\$${homeController.incomeTotal.value}',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Account Information Section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                          child: Text(
                            AppTranslations.translateValue(
                              'Account Information',
                            ),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        _buildMenuItem(
                          iconPath: AppIcons.profileIcon,
                          title: AppTranslations.translateValue('Edit Profile'),
                          onTap: () {
                            Get.to(() => const ProviderEditProfileScreen());
                          },
                        ),
                        _buildMenuItem(
                          iconPath: AppIcons.all_service,
                          title: AppTranslations.translateValue('All Services'),
                          onTap: () {
                            Get.to(() => AllServicesPage());
                          },
                        ),
                        _buildMenuItem(
                          iconPath: AppIcons.oder_history,
                          title: AppTranslations.translateValue(
                            'Order History',
                          ),
                          onTap: () => Get.offAllNamed(
                            AppRoutes.providerBottomNavScreen,
                            arguments: 2,
                          ),
                        ),
                        _buildMenuItem(
                          iconPath: AppIcons.portfolio,
                          title: AppTranslations.translateValue('Portfolio'),
                          onTap: () {
                            // Get.to(() => PortfolioPage());
                            Get.to(() => PortfolioListScreen());
                          },
                        ),
                        _buildMenuItem(
                          iconPath: AppIcons.payment,
                          title: AppTranslations.translateValue(
                            'Payment History',
                          ),
                          onTap: () {
                            Get.to(() => const provider_PaymentHistoryScreen());
                          },
                        ),
                        _buildMenuItem(
                          iconPath: AppIcons.bank,
                          title: AppTranslations.translateValue(
                            'Bank Information',
                          ),
                          onTap: () {
                            Get.to(() => BankInformationScreen());
                          },
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Policy Center Section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                          child: Text(
                            AppTranslations.translateValue('Policy Center'),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        _buildMenuItem(
                          iconPath: AppIcons.privacy,
                          title: AppTranslations.translateValue(
                            'profile.privacy_policy',
                          ),
                          onTap: () {
                            Get.to(() => const ProviderPrivacyPolicyScreen());
                          },
                        ),
                        _buildMenuItem(
                          iconPath: AppIcons.terms,
                          title: AppTranslations.translateValue(
                            'profile.terms_condition',
                          ),
                          onTap: () {
                            Get.to(() => const ProviderTermsConditionScreen());
                          },
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Settings Section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                          child: Text(
                            AppTranslations.translateValue('Settings'),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        _buildMenuItem(
                          iconPath: AppIcons.notification,
                          title: AppTranslations.translateValue('Notification'),
                          onTap: () {
                            Get.to(() => const ProviderNotificationPage());
                          },
                        ),
                        _buildMenuItem(
                          iconPath: AppIcons.help,
                          title: AppTranslations.translateValue(
                            'Help & Support',
                          ),
                          onTap: () {
                            Get.to(() => ProviderHelpSupportScreen());
                          },
                        ),
                        _buildMenuItem(
                          iconPath: AppIcons.logout,
                          title: AppTranslations.translateValue('Log Out'),
                          onTap: _showLogoutDialog,
                        ),
                        _buildMenuItem(
                          iconPath: AppIcons.delete,
                          title: AppTranslations.translateValue(
                            'Delete Account',
                          ),
                          onTap: () {
                            _showDeleteAccountDialog(context);
                          },
                          isDestructive: true,
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    AppIcons.logout,
                    width: 32,
                    height: 32,
                    colorFilter: ColorFilter.mode(
                      Colors.orange.shade400,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppTranslations.translateValue('Log Out'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppTranslations.translateValue(
                    'Are you sure you want to log out?',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          AppTranslations.translateValue('Cancel'),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Clear session using StorageService.clearAll
                          await FirebaseMessagingService.instance().removeTokenOnLogout();
                          await TokenService().clearToken();
                          await StorageService.clearAll();

                          // Close dialog
                          Navigator.of(context).pop();

                          // Navigate to common user login screen and clear all previous routes
                          Get.offAllNamed(AppRoutes.userTypeSelection);

                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          AppTranslations.translateValue('Log Out'),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    AppIcons.delete,
                    width: 32,
                    height: 32,
                    colorFilter: ColorFilter.mode(
                      Colors.red.shade400,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppTranslations.translateValue('Delete Account'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure to delete this account? This action cannot be undone.'
                      .tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          AppTranslations.translateValue('Cancel'),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppTranslations.translateValue(
                                  'Account deleted successfully',
                                ),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          AppTranslations.translateValue('Yes, Delete'),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required String iconPath,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
    bool isDestructive = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                SvgPicture.asset(
                  iconPath,
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(
                    isDestructive ? Colors.red : Colors.black54,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: 14,
                      color: isDestructive ? Colors.red : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SvgPicture.asset(
                  AppIcons.arrow_right,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    isDestructive ? Colors.red : Colors.black38,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
