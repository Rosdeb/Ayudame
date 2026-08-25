import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/routes/app_routes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:middle_ware/services/api_service.dart';
import '../../../utils/constants.dart';
import '../../../widgets/custom_loading_button.dart';
import '../../../widgets/user_custom_text_field.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _agreeToTerms = false;
  bool isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailOrPhoneController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final String apiUrl = "${ApiService.BASE_URL}/api/auth/register";
  String t(String key) => AppTranslations.translateValue(key);

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      Get.snackbar(
        t('auth.terms_required'),
        t('auth.please_accept_terms'),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "fullName": nameController.text.trim(),
          "email": emailOrPhoneController.text.trim(),
          "password": passController.text.trim(),
          "termsAccepted": _agreeToTerms,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          t('common.success'),
          data["message"] ?? t('auth.account_created'),
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offNamed(
          AppRoutes.oTPVerificationForSignup,
          arguments: {"email": emailOrPhoneController.text.trim()},
        );
      } else {
        Get.snackbar(
          t('common.error'),
          data["message"] ?? t('common.failed'),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        t('common.error'),
        "${t('network.network_error')}: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Create Account Title
                  Text(
                    t('auth.sign_up'),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    t('auth.create_account_subtitle'),
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),

                  const SizedBox(height: 40),

                  // Full Name Label
                  Text(
                    t('auth.full_name'),
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),

                  // Full Name Field
                  CustomTextField1(
                    textEditingController: nameController,
                    hintText: t('auth.full_name_hint'),
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: AppColors.grey,
                    ),
                    fillColor: const Color(0xFFFFFFFF),
                    fieldBorderColor: AppColors.grey,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t('validation.please_enter_full_name');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Email or Number Label
                  Text(
                    t('auth.enter_email_or_number'),
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),

                  // Email/Phone Field
                  CustomTextField1(
                    textEditingController: emailOrPhoneController,
                    hintText: t('auth.email_or_phone_hint'),
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: AppColors.grey,
                    ),
                    fillColor: const Color(0xFFFFFFFF),
                    fieldBorderColor: AppColors.grey,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t('validation.please_enter_email');
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 20),

                  // Password Label
                  Text(
                    t('common.password'),
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),

                  // Password Field
                  CustomTextField1(
                    textEditingController: passController,
                    hintText: t('auth.password_hint'),
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: AppColors.grey,
                    ),
                    isPassword: true,
                    fillColor: const Color(0xFFFFFFFF),
                    fieldBorderColor: AppColors.grey,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t('validation.please_enter_password');
                      } else if (value.length < 6) {
                        return t('validation.password_min_length');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Terms and Conditions Checkbox
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                            });
                          },
                          activeColor: const Color(0xFF1C5941),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              t('auth.i_agree_to'),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                t('auth.terms_conditions'),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF1C5941),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  CustomLoadingButton(
                    title: "auth.sign_up",
                    isLoading: isLoading,
                    onTap: _createUser,
                  ),


                  const SizedBox(height: 24),

                  // // Or Continue With
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: Divider(color: Colors.grey[300], thickness: 1),
                  //     ),
                  //     Padding(
                  //       padding: EdgeInsets.symmetric(horizontal: 16),
                  //       child: Text(
                  //         t('auth.or_continue_with'),
                  //         style: TextStyle(fontSize: 13, color: Colors.black54),
                  //       ),
                  //     ),
                  //     Expanded(
                  //       child: Divider(color: Colors.grey[300], thickness: 1),
                  //     ),
                  //   ],
                  // ),
                  //
                  // const SizedBox(height: 24),
                  //
                  // // Social Login Buttons
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     // Google
                  //     Container(
                  //       width: 56,
                  //       height: 56,
                  //       decoration: BoxDecoration(
                  //         color: Colors.white,
                  //         border: Border.all(color: Colors.grey[300]!),
                  //         borderRadius: BorderRadius.circular(28),
                  //       ),
                  //       child: IconButton(
                  //         onPressed: () {},
                  //         icon: Image.network(
                  //           'https://www.google.com/favicon.ico',
                  //           width: 24,
                  //           height: 24,
                  //           errorBuilder: (context, error, stackTrace) {
                  //             return Text(
                  //               AppTranslations.translateValue('G'),
                  //               style: TextStyle(
                  //                 fontSize: 24,
                  //                 fontWeight: FontWeight.bold,
                  //                 color: Colors.blue,
                  //               ),
                  //             );
                  //           },
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  const SizedBox(height: 24),

                  // Login Text
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          t('auth.already_have_account'),
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.toNamed(AppRoutes.userlogin);
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
