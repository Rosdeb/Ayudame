import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/localization/app_translations.dart';
import '../../../viewmodels/business_auth_viewmodel.dart';
import '../../../core/routes/app_routes.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class BusinessLoginScreen extends StatefulWidget {
  const BusinessLoginScreen({super.key});

  @override
  State<BusinessLoginScreen> createState() => _BusinessLoginScreenState();
}

class _BusinessLoginScreenState extends State<BusinessLoginScreen> {
  final BusinessAuthViewModel _authViewModel = Get.put(BusinessAuthViewModel());
  bool _obscurePassword = true;
  String t(String key) => AppTranslations.translateValue(key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                Text(
                  t('auth.welcome_back'),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t('auth.login_to_account'),
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),

                const SizedBox(height: 40),

                Text(
                  t('auth.enter_email_or_number'),
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 8),

                // Email TextField
                TextField(
                  controller: _authViewModel.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: t('auth.email_address_or_phone'),
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.black38,
                    ),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      size: 20,
                      color: Colors.black54,
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
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

                const SizedBox(height: 20),

                Text(
                  t('common.password'),
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: _authViewModel.passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: AppTranslations.translateValue('••••••••••'),
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.black38,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      size: 20,
                      color: Colors.black54,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: Colors.black54,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
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

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Obx(
                          () => SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: _authViewModel.rememberMe.value,
                              onChanged: (value) {
                                _authViewModel.rememberMe.value =
                                    value ?? false;
                              },
                              activeColor: const Color(0xFF1C5941),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          t('auth.remember_me'),
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.businessForgotPass);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        t('auth.forgot_password'),
                        style: TextStyle(fontSize: 13, color: Colors.red),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _authViewModel.isLoading.value
                          ? null
                          : () => _authViewModel.login(),
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
                              t('auth.login'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.grey[300], thickness: 1),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        t('auth.or_continue_with'),
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.grey[300], thickness: 1),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Image.network(
                          'https://www.google.com/favicon.ico',
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              AppTranslations.translateValue('G'),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        t('auth.dont_have_account'),
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.toNamed(AppRoutes.businessRegister);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          t('auth.sign_up'),
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
    );
  }
}
