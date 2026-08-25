import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:middle_ware/core/localization/app_translations.dart';
import 'package:middle_ware/core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import 'package:middle_ware/viewmodels/event_manager_viewmodel.dart';

class EventForgotPasswordScreen extends StatefulWidget {
  const EventForgotPasswordScreen({super.key});

  @override
  State<EventForgotPasswordScreen> createState() =>
      _EventForgotPasswordScreenState();
}

class _EventForgotPasswordScreenState extends State<EventForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _viewModel = Get.put(EventManagerViewModel());
  String t(String value) => AppTranslations.translateValue(value);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          t('auth.forgot_password_title'),
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
              t('auth.forgot_password_title'),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              t('auth.forgot_password_subtitle'),
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // Email or Phone Label
            Text(
              t('auth.enter_email_or_number'),
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: t('auth.email_or_phone_hint'),
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
                  onPressed: _viewModel.isLoading.value
                      ? null
                      : () {
                          _viewModel.sendOtp(_emailController.text.trim());
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C5941),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _viewModel.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          t('auth.send_reset_code'),
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
                        '${t('auth.remembered_password')} ',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.toNamed(AppRoutes.eventLogin);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          t('auth.login'),
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
                      t('auth.need_help'),
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
