import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:middle_ware/views/components/floatingbar.dart';
import 'package:middle_ware/widgets/custom_appbar.dart';
import 'package:shimmer/shimmer.dart';
import '../../../controller/provider/profile/edit_profile_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../utils/token_service.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../controller/provider/profile/provider_profile_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../../widgets/user_custom_text_field.dart';
import 'ProviderProfilePage.dart';
import 'ProviderProfileScreen.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class ProviderEditProfileScreen extends StatefulWidget {
  const ProviderEditProfileScreen({super.key});

  @override
  State<ProviderEditProfileScreen> createState() =>
      _ProviderEditProfileScreenState();
}

class _ProviderEditProfileScreenState extends State<ProviderEditProfileScreen> {
  bool isLoading = false;
  final EditProfile _controller = Get.put(EditProfile());

  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final profileController = Get.find<ProviderProfileController>();
      await profileController.fetchProviderProfile();

      final profile = profileController.providerProfile.value;
      if (profile != null) {
        nameController.text = profile.userId.fullName;
        emailController.text = profile.userId.email;
        phoneController.text = profile.userId.phoneNumber;
        occupationController.text = profile.occupation;

        // Set date of birth if available
        if (profile.idCard.dateOfBirth != null) {
          dateController.text = profile.idCard.dateOfBirth!;
        }

        // Set profile image URL
        if (profile.userId.profilePicture != null &&
            profile.userId.profilePicture!.isNotEmpty) {
          _controller.setInitialImage(profile.userId.profilePicture!);
        }
      }
    } catch (e) {
      print("Error loading profile data: $e");
      // If ProviderProfileController doesn't exist, try to create it
      Get.put(ProviderProfileController());
      _loadProfileData();
    }
  }

  Future<void> updateUser() async {
    final token = await TokenService().getToken();
    if (token == null || token.isEmpty) {
      Get.snackbar(
        AppTranslations.translateValue("Alert"),
        AppTranslations.translateValue("No authentication token"),
      );
      return;
    }

    setState(() => isLoading = true);

    File? imageFile = _controller.selectedImage.value;
    String newName = nameController.text.trim();

    try {
      final response = await _controller.uploadProfile(
        fullName: newName,
        phoneNumber: phoneController.text.trim(),
        occupation: occupationController.text.trim(),
        imageFile: imageFile,
        token: token,
      );

      if (response["status"] == 200) {
        // Update ProviderProfileController instantly
        final p = Get.find<ProviderProfileController>();
        p.fetchProviderProfile();
        Get.off(() => ProviderProfilePage());
      } else {
        FloatingErrorBar.show(context, message:  response["body"]["message"] ?? "Update failed",);
      }
    } catch (e) {
      FloatingErrorBar.show(context, message:  "Error Something went wrong: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppTranslations.translateValue("Edit Profile"),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.055),
              Center(
                child: Stack(
                  children: [
                    Obx(() {
                      final imageUrl = _controller.userProfileImageUrl.value;
                      final file = _controller.selectedImage.value;

                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.mainAppColor,
                            width: 1.5,
                          ),
                        ),
                        child: ClipOval(
                          child: SizedBox(
                            width: 110,
                            height: 110,
                            child: file != null
                                // Picked image
                                ? Image.file(file, fit: BoxFit.cover)
                                // Server image with shimmer (same as profile page)
                                : CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(
                                            width: 110,
                                            height: 110,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                          "assets/images/emptyUser.png",
                                          fit: BoxFit.cover,
                                        ),
                                  ),
                          ),
                        ),
                      );
                    }),
                    Positioned(
                      bottom: 5,
                      right: 2,
                      child: GestureDetector(
                        onTap: () {
                          _controller.pickImage(ImageSource.gallery);
                        },
                        child: SvgPicture.asset(
                          "assets/icons/inputImageIcon.svg",
                          width: 28.w,
                          height: 28.h,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.030),

              Text(
                AppTranslations.translateValue("Full Name"),
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2B4237),
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField1(
                textEditingController: nameController,
                hintText: AppTranslations.translateValue('Name'),
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  color: Color(0xFF737373),
                ),
                fillColor: Color(0xFF1C5941).withOpacity(0.03),
                fieldBorderColor: AppColors.mainAppColor,
              ),
              SizedBox(height: 16.h),

              Text(
                AppTranslations.translateValue("E-mail address"),
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2B4237),
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField1(
                textEditingController: emailController,
                hintText: AppTranslations.translateValue('E-mail address'),
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  color: Color(0xFF737373),
                ),
                readOnly: true,
                fillColor: Color(0xFF1C5941).withOpacity(0.03),
                fieldBorderColor: AppColors.mainAppColor,
              ),
              SizedBox(height: 16.h),

              Text(
                AppTranslations.translateValue("Phone Number"),
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2B4237),
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField1(
                textEditingController: phoneController,
                hintText: AppTranslations.translateValue('phone number'),
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  color: Color(0xFF737373),
                ),
                fillColor: Color(0xFF1C5941).withOpacity(0.03),
                fieldBorderColor: AppColors.mainAppColor,
              ),
              SizedBox(height: 16.h),

              Text(
                AppTranslations.translateValue("Date of birth"),
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2B4237),
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField1(
                textEditingController: dateController,
                hintText: AppTranslations.translateValue('Date of birth'),
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  color: Color(0xFF737373),
                ),
                fillColor: Color(0xFF1C5941).withOpacity(0.03),
                fieldBorderColor: AppColors.mainAppColor,
              ),
              SizedBox(height: 16.h),

              Text(
                AppTranslations.translateValue("Select occupation"),
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2B4237),
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField1(
                textEditingController: occupationController,
                hintText: AppTranslations.translateValue('Select occupation'),
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  color: Color(0xFF737373),
                ),
                fillColor: Color(0xFF1C5941).withOpacity(0.03),
                fieldBorderColor: AppColors.mainAppColor,
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.044),

              GestureDetector(
                onTap: isLoading ? null : updateUser,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppColors.mainAppColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    isLoading ? "Loading..." : "Save Changes",
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE6E6E6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
