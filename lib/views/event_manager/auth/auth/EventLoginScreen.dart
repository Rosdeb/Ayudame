import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:middle_ware/core/localization/app_translations.dart';
import 'package:middle_ware/core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../viewmodels/event_manager_viewmodel.dart';

class EventLoginScreen extends StatefulWidget {
  const EventLoginScreen({super.key});

  @override
  State<EventLoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<EventLoginScreen> {
  final _viewModel = Get.put(EventManagerViewModel());
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _obscurePassword = true;
  String t(String key) => AppTranslations.translateValue(key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
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
                  controller: _emailController,
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
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: '••••••••••',
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
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            activeColor: const Color(0xFF1C5941),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
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
                        Get.toNamed(AppRoutes.eventForgotPass);
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
                      onPressed: _viewModel.isLoading.value
                          ? null
                          : () {
                              if (_emailController.text.isEmpty ||
                                  _passwordController.text.isEmpty) {
                                Get.snackbar(
                                  t('common.error'),
                                  t('auth.enter_email_and_password'),
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              _viewModel.login(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                              );
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
                          ? const SizedBox(
                              width: 20,
                              height: 20,
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
                            return const Text(
                              'G',
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
                    const SizedBox(width: 16),

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
                        icon: const Icon(
                          Icons.apple,
                          size: 28,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

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
                        icon: const Icon(
                          Icons.facebook,
                          size: 28,
                          color: Color(0xFF1877F2),
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
                          Get.toNamed(AppRoutes.eventRegister);
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
