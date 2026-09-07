import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:middle_ware/views/components/custom_app_bar.dart';
import 'package:get/get.dart';
import 'package:middle_ware/views/user/orders/OrderHistoryScreen.dart';
import 'package:middle_ware/views/user/profile/EditProfileScreen.dart';
import 'package:middle_ware/views/user/profile/HelpSupportScreen.dart';
import 'package:middle_ware/views/user/profile/NotificationPage.dart';
import 'package:middle_ware/views/user/profile/WishlistScreen.dart';
import 'package:middle_ware/views/user/profile/my_events.dart';
import 'package:middle_ware/views/user/profile/user_bank_information.dart';
import 'package:shimmer/shimmer.dart';
import '../../../controller/user/profile/profile_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import '../../../services/firebasenotification/firebasenotification.dart';
import 'PrivacyPolicyScreen.dart';
import 'TermsConditionScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../utils/token_service.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key}) : super(key: key);

  final _controller = ValueNotifier<bool>(false);
  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: CustomAppBar(title: AppTranslations.translateValue("Profile"),onBackTap: (){
        Get.back();
      },),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    Obx(() {
                      if (profileController.isLoading.value) {
                        return const CircularProgressIndicator();
                      }

                      if (profileController.errorMessage.isNotEmpty) {
                        return Text(profileController.errorMessage.value);
                      }

                      final user = profileController.user.value;
                      if (user == null) {
                        return Text(
                          AppTranslations.translateValue("User data not found"),
                        );
                      }

                      return Column(
                        children: [
                          // ----------- Profile Image ----------
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.mainAppColor,
                                  width: 1.5,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.grey[200],
                                child: ClipOval(
                                  child: user == null
                                      ? Image.asset(
                                          "assets/images/emptyUser.png",
                                          width: 50,
                                          height: 60,
                                          fit: BoxFit.contain,
                                        )
                                      : CachedNetworkImage(
                                          imageUrl: user.profilePicture ?? "",
                                          width: 110,
                                          height: 110,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Shimmer.fromColors(
                                                baseColor: Colors.grey[300]!,
                                                highlightColor:
                                                    Colors.grey[100]!,
                                                child: Container(
                                                  width: 110,
                                                  height: 110,
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Colors.grey,
                                                        shape: BoxShape.circle,
                                                      ),
                                                ),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                                "assets/images/emptyUser.png",
                                                width: 50,
                                                height: 60,
                                                fit: BoxFit.contain,
                                              ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Text(
                            user.fullName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            user.email,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      );
                    }),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.030,
                    ),

                    /// Account Information Details
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Color(0xFFE3E6F0),
                          width: 0.6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            offset: const Offset(0, 2),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTranslations.translateValue(
                              "Account Information",
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.black,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.025,
                          ),
                          settingsTile(
                            iconPath: "assets/icons/editProfile.svg",
                            title: AppTranslations.translateValue(
                              "Edit Profile",
                            ),
                            onTap: () {
                              final user = profileController.user.value;
                              if (user != null) {
                                Get.to(
                                  () => EditProfileScreen(),
                                  arguments: user,
                                );
                              } else {
                                Get.snackbar(
                                  AppTranslations.translateValue("Error"),
                                  AppTranslations.translateValue(
                                    "User data not found",
                                  ),
                                );
                              }
                            },
                          ),
                          SizedBox(height: 16.h),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    "assets/icons/people.png",
                                    width: 24,
                                    height: 24,
                                    color: Color(0xFF4d4d4d),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    AppTranslations.translateValue(
                                      "Switch to provider",
                                    ),
                                    style: TextStyle(
                                      fontFamily: 'Montserrat-Regular',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF4d4d4d),
                                    ),
                                  ),
                                ],
                              ),
                              AdvancedSwitch(
                                activeColor: AppColors.mainAppColor,
                                inactiveColor: Color(
                                  0xFF787880,
                                ).withOpacity(0.16),
                                width: 48.w,
                                height: 25.h,
                                controller: _controller,
                                borderRadius: BorderRadius.circular(77),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          settingsTile(
                            iconPath: "assets/icons/wishlistIcon.svg",
                            title: AppTranslations.translateValue("Favorites"),
                            onTap: () {
                              Get.to(() => WishlistScreen());
                            },
                          ),
                          SizedBox(height: 16.h),
                          settingsTile(
                            iconPath: "assets/icons/eventIcon.svg",
                            title: AppTranslations.translateValue("My events"),
                            onTap: () {
                              Get.to(() => MyEvents());
                            },
                          ),
                          SizedBox(height: 16.h),
                          settingsTile(
                            iconPath: "assets/icons/orderHistory.svg",
                            title: "My Tickets",
                            onTap: () {
                              Get.toNamed(AppRoutes.userETicket);
                            },
                          ),
                          SizedBox(height: 16.h),
                          settingsTile(
                            iconPath: "assets/icons/orderHistory.svg",
                            title: AppTranslations.translateValue(
                              "order history",
                            ),
                            onTap: () {
                              Get.to(() => OrderHistoryScreen());
                            },
                          ),
                          SizedBox(height: 16.h),
                          settingsTile(
                            iconPath: "assets/icons/bankIcon.svg",
                            title: AppTranslations.translateValue(
                              "Bank Information",
                            ),
                            onTap: () {
                              Get.to(() => userBankInformation());
                            },
                          ),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    /// Policy Center Details
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Color(0xFFE3E6F0),
                          width: 0.6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            offset: const Offset(0, 2),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTranslations.translateValue("Policy Center"),
                            style: GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.black,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.025,
                          ),
                          settingsTile(
                            iconPath: "assets/icons/privacyIcon.svg",
                            title: AppTranslations.translateValue(
                              "profile.privacy_policy",
                            ),
                            onTap: () {
                              Get.to(() => PrivacyPolicyScreen());
                            },
                          ),
                          SizedBox(height: 16.h),
                          settingsTile(
                            iconPath: "assets/icons/termsIcon.svg",
                            title: AppTranslations.translateValue(
                              "profile.terms_condition",
                            ),
                            onTap: () {
                              Get.to(() => TermsConditionScreen());
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    /// Settings Details
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Color(0xFFE3E6F0),
                          width: 0.6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            offset: const Offset(0, 2),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTranslations.translateValue("Settings"),
                            style: GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.black,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          settingsTile(
                            title: AppTranslations.translateValue(
                              "Notification",
                            ),
                            onTap: () {
                              Get.to(() => NotificationPage());
                            },
                            iconPath: 'assets/icons/notification.svg',
                          ),
                          SizedBox(height: 16.h),
                          settingsTile(
                            title: AppTranslations.translateValue(
                              "Help & support",
                            ),
                            onTap: () {
                              Get.to(() => HelpSupportScreen());
                            },
                            iconPath: 'assets/icons/helpIcon.svg',
                          ),
                          SizedBox(height: 16.h),
                          settingsTile(
                            title: AppTranslations.translateValue("Log out"),
                            onTap: () async {
                              _showLogoutDialog(context);
                            },
                            iconPath: 'assets/icons/logout.svg',
                          ),
                          SizedBox(height: 16.h),
                          GestureDetector(
                            onTap: () {
                              _showDeleteDialog(context);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/delete.svg",
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          AppTranslations.translateValue(
                                            "Delete Account",
                                          ),
                                          style: TextStyle(
                                            fontFamily: 'Montserrat-Regular',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.025,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget settingsTile({
    required String iconPath,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SvgPicture.asset(iconPath, color: Color(0xFF4d4d4d)),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Montserrat-Regular',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4d4d4d),
                ),
              ),
            ],
          ),
          Icon(Icons.arrow_forward_ios, size: 17, color: Color(0xFF4d4d4d)),
        ],
      ),
    );
  }

  // -------------------- Delete Confirmation Dialog --------------------
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: SvgPicture.asset("assets/icons/deleteIcon.svg")),
              SizedBox(height: 12.h),
              Text(
                AppTranslations.translateValue("Delete Account"),
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mainAppColor,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                AppTranslations.translateValue(
                  "Are you sure to delete this account?",
                ),
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF494949),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        AppTranslations.translateValue('Cancel'),
                        style: TextStyle(
                          fontFamily: 'Prompt_regular',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mainAppColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        elevation: 0,
                      ),
                      child: Text(
                        AppTranslations.translateValue('Delete'),
                        style: TextStyle(
                          fontFamily: 'Prompt_regular',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------- Logout Confirmation Dialog --------------------
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, size: 48, color: AppColors.mainAppColor),
              SizedBox(height: 12.h),
              Text(
                AppTranslations.translateValue("Logout"),
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mainAppColor,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                AppTranslations.translateValue(
                  "Are you sure you want to logout?",
                ),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF494949),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        AppTranslations.translateValue('Cancel'),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mainAppColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await TokenService().clearToken();

                          await PrefsHelper.clear();
                          print("Prefs cleared");

                          Navigator.of(context).pop();

                          Get.offAllNamed(AppRoutes.userTypeSelection);

                          Get.snackbar(
                            AppTranslations.translateValue('Success'),
                            AppTranslations.translateValue(
                              'Logged out successfully',
                            ),
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        } catch (e) {
                          print("Logout error: $e");
                          Get.snackbar(
                            'Error',
                            'Logout failed: $e',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainAppColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        elevation: 0,
                      ),
                      child: Text(
                        AppTranslations.translateValue('Logout'),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
