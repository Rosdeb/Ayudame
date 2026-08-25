import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:middle_ware/core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../viewmodels/business_auth_viewmodel.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class BusinessForgotPasswordScreen extends StatelessWidget {
  BusinessForgotPasswordScreen({super.key});

  final BusinessAuthViewModel _authViewModel = Get.put(BusinessAuthViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          AppTranslations.translateValue('Forgot Password'),
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Title
            Text(
              AppTranslations.translateValue('Forgot Password?'),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              'Don\'t worry! Enter your registered email\nto receive a reset code.'
                  .tr,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // Email Label
            Text(
              AppTranslations.translateValue('Enter your email'),
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _authViewModel.forgotEmailController,
              decoration: InputDecoration(
                hintText: AppTranslations.translateValue('Enter your email'),
                hintStyle: const TextStyle(fontSize: 14, color: Colors.black38),
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  size: 20,
                  color: Colors.black54,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1C5941)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _authViewModel.isLoading.value
                      ? null
                      : () {
                          _authViewModel.sendOtp();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C5941),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _authViewModel.isLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          AppTranslations.translateValue('Send Reset Code'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppTranslations.translateValue(
                          'Remembered your password? ',
                        ),
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.toNamed(AppRoutes.businessLogin);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          AppTranslations.translateValue('Login'),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      AppTranslations.translateValue('Need Help?'),
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
