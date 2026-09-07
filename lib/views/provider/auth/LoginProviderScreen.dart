import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:middle_ware/views/components/successbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:middle_ware/services/api_service.dart';
import 'package:middle_ware/services/storage_service.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/routes/app_routes.dart';
import '../../../utils/token_service.dart';
import '../../../widgets/custom_loading_button.dart';

class LoginProviderScreen extends StatefulWidget {
  const LoginProviderScreen({super.key});

  @override
  State<LoginProviderScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginProviderScreen> {
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final remember = await StorageService.getRememberMe('provider');
    if (remember) {
      final email = await StorageService.getSavedEmail('provider');
      final password = await StorageService.getSavedPassword('provider');
      if (email != null) _emailOrPhoneController.text = email;
      if (password != null) _passwordController.text = password;
      if (mounted) {
        setState(() {
          _rememberMe = true;
        });
      }
    }
  }

  final String _loginApiUrl = "${ApiService.BASE_URL}/api/providers/login";
  String t(String key) => AppTranslations.translateValue(key);

  Future<void> _loginProvider(String email, String password) async {
    if (!_formKey.currentState!.validate()) return;

    if (!await _hasInternetConnection()) {
      Get.snackbar(t('network.no_internet'), t('network.check_connection'));
      return;
    }

    final body = {'email': email, 'password': password};

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(_loginApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {

        FloatingSuccessBar.show(context, message:  t('common.success') );

        final accessToken = data['data']?['accessToken'];
        final refreshToken = data['data']?['refreshToken'];
        if (accessToken is String && accessToken.isNotEmpty) {
          await TokenService().saveSession(
            accessToken: accessToken,
            refreshToken: refreshToken is String ? refreshToken : null,
          );
          await StorageService.saveUserRole('provider');
        }

        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);

        await StorageService.saveRememberMe('provider', _rememberMe);
        if (_rememberMe) {
          await StorageService.saveSavedCredentials('provider', email, password);
        } else {
          await StorageService.clearSavedCredentials('provider');
        }

        Get.offNamed(AppRoutes.providerBottomNavScreen);
      } else {
        Get.snackbar(
          t('common.error'),
          data['message'] ?? t('common.failed'),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        t('common.error'),
        "${t('common.something_went_wrong')}: $e",
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
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

                  // Welcome Back Title
                  Text(
                    t('auth.welcome_back_provider'),
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

                  TextFormField(
                    controller: _emailOrPhoneController,
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
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return t('validation.please_enter_email_or_phone');
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Password Label
                  Text(
                    t('common.password'),
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: t('auth.password_hint'),
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t('validation.please_enter_password');
                      }
                      return null;
                    },
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
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Get.toNamed(AppRoutes.providerForgotPass);
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

                  CustomLoadingButton(
                    title: "auth.login",
                    isLoading: _isLoading,
                    onTap: () {
                      _loginProvider(
                        _emailOrPhoneController.text.trim(),
                        _passwordController.text.trim(),
                      );
                    },
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
                      // Google
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
                            Get.toNamed(AppRoutes.providerRegister);
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
      ),
    );
  }
}
