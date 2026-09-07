import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io' show Platform;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:middle_ware/widgets/custom_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../utils/constants.dart' hide AppColors;
import '../../../utils/token_service.dart';
import 'package:middle_ware/widgets/user_custom_text_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:middle_ware/services/api_service.dart';
import 'package:middle_ware/services/storage_service.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  bool _rememberMe = false;
  bool isLoading = false;

  final TextEditingController emailOrPhoneController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final loginApiUrl = "${ApiService.BASE_URL}/api/auth/login";
  final socialLoginApiUrl = "${ApiService.BASE_URL}/api/auth/social/direct-login";

  String t(String key) => AppTranslations.translateValue(key);
  String _normalizeRole(String? role) {
    final value = (role ?? '').trim().toLowerCase();
    if (value == 'event-manager' ||
        value == 'eventmanager' ||
        value == 'event_manager') {
      return 'event_manager';
    }
    if (value == 'business_owner' || value == 'businessowner') {
      return 'business';
    }
    return value;
  }

  String? _extractRoleFromToken(String? accessToken) {
    if (accessToken == null || accessToken.isEmpty) return null;
    final List<String> parts = accessToken.split('.');
    if (parts.length < 2) return null;
    try {
      final String normalized = base64Url.normalize(parts[1]);
      final String payload = utf8.decode(base64Url.decode(normalized));
      final dynamic decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded['userType']?.toString() ?? decoded['role']?.toString();
      }
    } catch (_) {}
    return null;
  }

  String _extractRoleFromResponse(Map<String, dynamic> responseBody) {
    final dynamic dataRaw = responseBody['data'];
    final Map<String, dynamic>? data = dataRaw is Map
        ? Map<String, dynamic>.from(dataRaw)
        : null;
    final dynamic userRaw = data?['user'];
    final Map<String, dynamic>? user = userRaw is Map
        ? Map<String, dynamic>.from(userRaw)
        : null;

    final String? role =
        user?['userType']?.toString() ??
        user?['role']?.toString() ??
        data?['userType']?.toString() ??
        data?['role']?.toString() ??
        _extractRoleFromToken(data?['accessToken']?.toString());

    return _normalizeRole(role ?? 'user');
  }

  String? _homeRouteForRole(String? role) {
    switch (_normalizeRole(role)) {
      case 'user':
        return AppRoutes.userBottomNavScreen;
      case 'provider':
        return AppRoutes.providerBottomNavScreen;
      case 'business':
        return AppRoutes.businessHome;
      case 'event_manager':
        return AppRoutes.eventHome;
      default:
        return null;
    }
  }

  Future<void> _handleLoginSuccess(Map<String, dynamic> responseBody) async {
    final Map<String, dynamic>? responseData =
        responseBody['data'] is Map<String, dynamic>
        ? responseBody['data'] as Map<String, dynamic>
        : null;
    final String accessToken =
        responseData?['accessToken']?.toString() ??
        responseBody['token']?.toString() ??
        '';
    final String refreshToken =
        responseData?['refreshToken']?.toString() ??
        responseBody['refreshToken']?.toString() ??
        '';

    if (accessToken.isEmpty) {
      Get.snackbar(
        t('common.error'),
        t('common.something_went_wrong'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    await TokenService().saveSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    final String normalizedRole = _extractRoleFromResponse(responseBody);
    await StorageService.saveUserRole(normalizedRole);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    if (!_rememberMe) {
      await prefs.remove("email");
      await prefs.remove("password");
    }

    final String targetRoute =
        _homeRouteForRole(normalizedRole) ?? AppRoutes.userBottomNavScreen;
    Get.offNamed(targetRoute);
  }

  Future<void> _loginUser(String email, String password) async {
    final SharedPreferences prefsHelper = await SharedPreferences.getInstance();
    if (!_formKey.currentState!.validate()) return;

    final savedToken = prefsHelper.getString(AppConstants.fcmToken);

    if (!await hasInternetConnection()) {
      Get.snackbar(t('network.no_internet'), t('network.check_connection'));
      return;
    }

    final body = {'email': email, 'password': password, 'fcmToken': savedToken};

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(loginApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final dynamic decoded = json.decode(response.body);
      final Map<String, dynamic> data = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{};

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          t('common.success'),
          data["message"] ?? t('auth.login_success'),
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await _handleLoginSuccess(data);
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
        isLoading = false;
      });
    }
  }

  Future<bool> hasInternetConnection() async {
    final dynamic connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult is List<ConnectivityResult>) {
      return connectivityResult.any(
        (ConnectivityResult result) => result != ConnectivityResult.none,
      );
    }
    if (connectivityResult is ConnectivityResult) {
      return connectivityResult != ConnectivityResult.none;
    }
    return false;
  }

  Future<void> _socialLogin({
    required String provider,
    String? accessToken,
    String? idToken,
    String? fullName,
  }) async {
    final SharedPreferences prefsHelper = await SharedPreferences.getInstance();
    final savedToken = prefsHelper.getString(AppConstants.fcmToken);

    if (!await hasInternetConnection()) {
      Get.snackbar(t('network.no_internet'), t('network.check_connection'));
      return;
    }

    final Map<String, dynamic> body = {
      'provider': provider,
      'accessToken': accessToken,
      'idToken': idToken,
      'fullName': fullName,
      'fcmToken': savedToken,
      'platform': Platform.operatingSystem,
    };

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(socialLoginApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final dynamic decoded = json.decode(response.body);
      final Map<String, dynamic> data = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{};

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          t('common.success'),
          data["message"]?.toString() ?? 'Social login successful',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await _handleLoginSuccess(data);
      } else {
        Get.snackbar(
          t('common.error'),
          data['message']?.toString() ?? t('common.failed'),
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
        isLoading = false;
      });
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: <String>['email', 'profile'],
      );
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) return;

      final GoogleSignInAuthentication auth = await account.authentication;
      if ((auth.idToken == null || auth.idToken!.isEmpty) &&
          (auth.accessToken == null || auth.accessToken!.isEmpty)) {
        Get.snackbar(t('common.error'), 'Google token not received');
        return;
      }

      await _socialLogin(
        provider: 'google',
        accessToken: auth.accessToken,
        idToken: auth.idToken,
        fullName: account.displayName,
      );
    } catch (e) {
      Get.snackbar(t('common.error'), "Google login failed: $e");
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
                  CustomTextField1(
                    textEditingController: emailOrPhoneController,
                    hintText: t('auth.email_or_phone_hint'),
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: Colors.black38,
                    ),
                    fillColor: const Color(0xFFFFFFFF),
                    fieldBorderColor: AppColors.grey,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t('validation.please_enter_email_or_phone');
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  Text(
                    t('common.password'),
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField1(
                    textEditingController: passController,
                    hintText: t('auth.password_hint'),
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: Colors.black38,
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
                          Get.toNamed(AppRoutes.userforgotPassword);
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
                    isLoading: isLoading,
                    onTap: () {
                      _loginUser(
                        emailOrPhoneController.text.trim(),
                        passController.text.trim(),
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
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: IconButton(
                          icon: Image.asset('assets/images/google_icon.png'),
                          onPressed: _loginWithGoogle,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Sign Up Link
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: t('auth.dont_have_account'),
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                        children: [
                          TextSpan(
                            text: ' ${t('auth.sign_up')}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C5941),
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.toNamed(AppRoutes.userregister);
                              },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailOrPhoneController.dispose();
    passController.dispose();
    super.dispose();
  }
}
