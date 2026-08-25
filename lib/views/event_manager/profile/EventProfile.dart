import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:middle_ware/core/app_icons.dart';
import 'package:middle_ware/core/localization/app_translations.dart';
import 'package:middle_ware/core/theme/app_colors.dart';
import 'package:middle_ware/views/event_manager/profile/PrivacyPolicyScreen.dart';
import 'package:middle_ware/views/event_manager/profile/profile_info.dart';
import 'package:middle_ware/core/routes/app_routes.dart';

import '../../../widgets/custom_appbar.dart';
import 'EventHelpSupportScreen.dart';
import 'event_payment_history_screen.dart';
import 'EventTermsConditionScreen.dart';
import '../home/EventNotificationPage.dart';
import '../../../../viewmodels/event_manager_viewmodel.dart';

class EventProfilePage extends StatefulWidget {
  const EventProfilePage({super.key});

  @override
  State<EventProfilePage> createState() => _EventProfilePageState();
}

class _EventProfilePageState extends State<EventProfilePage> {
  final _viewModel = Get.put(EventManagerViewModel());
  String t(String value) => AppTranslations.translateValue(value);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: CustomAppBar(title: t("profile.profile"), showBackButton: false),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  Obx(() {
                    final manager = _viewModel.currentManager.value;
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundImage:
                              manager?.profilePicture != null &&
                                  manager!.profilePicture!.startsWith('http')
                              ? NetworkImage(manager.profilePicture!)
                              : const AssetImage('')
                                    as ImageProvider,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          manager?.fullName ?? t('Manager Name'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C5941),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            manager?.userType ?? t('onboarding.event_manager'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 24),

                  const SizedBox(height: 16),

                  // Account Information Section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
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
                            t('profile.account_information'),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        _buildMenuItem(
                          iconPath: AppIcons.profileIcon,
                          title: t('Profile info'),
                          onTap: () {
                            Get.to(() => const ProfileInfoScreen());
                          },
                        ),
                        _buildMenuItem(
                          iconPath: AppIcons.payment,
                          title: t('Payment History'),
                          onTap: () {
                            Get.to(() => const EventPaymentHistoryScreen());
                          },
                        ),
                        _buildMenuItem(
                          iconPath: AppIcons.bank,
                          title: t('profile.bank_information'),
                          onTap: () {
                            Get.toNamed(AppRoutes.bankInfo);
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
                          color: Colors.black.withValues(alpha: 0.05),
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
                            t('profile.policy_center'),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        _buildMenuItem(
                          iconPath: AppIcons.privacy,
                          title: 'profile.privacy_policy'.tr,
                          onTap: () => Get.to(() => EventPrivacyPolicyScreen()),
                        ),
                        _buildMenuItem(
                          iconPath: AppIcons.terms,
                          title: 'profile.terms_condition'.tr,
                          onTap: () =>
                              Get.to(() => EventTermsConditionScreen()),
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
                          color: Colors.black.withValues(alpha: 0.05),
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
                            t('profile.settings'),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        _buildMenuItem(
                          iconPath: AppIcons.notification,
                          title: t('profile.notification'),
                          onTap: () => Get.to(() => EventNotificationPage()),
                        ),
                        _buildMenuItem(
                          iconPath: AppIcons.help,
                          title: t('profile.help_support'),
                          onTap: () => Get.to(() => EventHelpSupportScreen()),
                        ),
                        _buildMenuItem(
                          iconPath: AppIcons.logout,
                          title: t('auth.logout'),
                          onTap: _showLogoutDialog,
                        ),
                        _buildMenuItem(
                          iconPath: AppIcons.delete,
                          title: t('profile.delete_account'),
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
                  t('dialogs.logout_title'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  t('dialogs.logout_message'),
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
                          t('common.cancel'),
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
                          _viewModel.logout();
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
                          t('dialogs.logout_title'),
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
                  t('profile.delete_account'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  t('profile.delete_account_confirm'),
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
                          t('common.cancel'),
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
                          _viewModel.deleteAccount();
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
                          t('Yes, Delete'),
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
                      fontSize: 14,
                      color: isDestructive ? Colors.red : Colors.black87,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Inter",
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
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Color(0xFFF0F0F0)),
          ),
      ],
    );
  }
}
