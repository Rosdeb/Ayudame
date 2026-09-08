import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:middle_ware/views/components/floatingbar.dart';
import '../models/business_model.dart';
import '../services/business_auth_service.dart';
import '../services/storage_service.dart';
import '../core/routes/app_routes.dart';
import '../utils/token_service.dart';
import '../services/notifications/firebase_messaging_service.dart';

class BusinessAuthViewModel extends GetxController {
  // Controllers for Login
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Controllers for Sign Up
  final businessNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final businessTypeController = TextEditingController();

  // Controllers for Forgot Password
  final forgotEmailController = TextEditingController();
  final verificationCodeController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  final BusinessAuthService _authService = BusinessAuthService();

  // Observable states
  var imageVersion = DateTime.now().millisecondsSinceEpoch.obs;

  String getImageUrl(String? url) {
    if (url == null || url.isEmpty || !url.startsWith('http')) return url ?? "";
    final separator = url.contains('?') ? '&' : '?';
    return "$url${separator}v=${imageVersion.value}";
  }

  var isLoading = false.obs;
  var currentBusiness = Rxn<BusinessModel>();
  var businessProfile = Rxn<BusinessModel>();
  var isLoggedIn = false.obs;
  var rememberMe = false.obs;
  var faqs = <dynamic>[].obs;
  var privacyPolicy = Rxn<Map<String, dynamic>>();
  var termsConditions = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
    getBusinessInfo();
    getBusinessProfile();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final remember = await StorageService.getRememberMe('business');
    if (remember) {
      rememberMe.value = true;
      final email = await StorageService.getSavedEmail('business');
      final password = await StorageService.getSavedPassword('business');
      if (email != null) emailController.text = email;
      if (password != null) passwordController.text = password;
    }
  }

  void _handleError(dynamic e, {String prefix = "Error"}) {
    String errorMsg = e.toString().replaceAll('Exception: ', '');
    debugPrint(" $prefix: $errorMsg");

    if (errorMsg.toLowerCase().contains("token") &&
        (errorMsg.toLowerCase().contains("expired") ||
            errorMsg.toLowerCase().contains("expaired") ||
            errorMsg.toLowerCase().contains("unauthorized"))) {
      Get.snackbar(
        "common.error".tr,
        "auth.please_login_again".tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      StorageService.clearAll();
      isLoggedIn.value = false;
      Get.offAllNamed(AppRoutes.businessLogin);
    } else {
      Get.snackbar(
        "common.error".tr,
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Check if business user is logged in
  Future<void> checkAuthStatus() async {
    try {
      final token = await StorageService.getToken();
      final role = await StorageService.getUserRole();

      if (token != null && token.isNotEmpty && role == 'business') {
        isLoggedIn.value = true;

        // Load business data from storage
        final businessId = await StorageService.getBusinessId();
        final email = await StorageService.getUserEmail();
        final ownerName = await StorageService.getUserName();

        if (businessId != null) {
          currentBusiness.value = BusinessModel(
            id: businessId,
            email: email,
            ownerName: ownerName,
          );
        }
      } else {
        isLoggedIn.value = false;
      }
    } catch (e) {
      debugPrint("❌ Check Auth Status Error: $e");
      isLoggedIn.value = false;
    }
  }

  /// Business Login
  Future<void> login(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {

      FloatingErrorBar.show(context, message: "auth.enter_email_and_password".tr);
      // Get.snackbar(
      //   "common.error".tr,
      //   "auth.enter_email_and_password".tr,
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      // );
      return;
    }

    debugPrint("🔐 Attempting Business Login...");
    debugPrint("📧 Email: ${emailController.text.trim()}");

    isLoading.value = true;

    try {
      final response = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      debugPrint("✅ Login Response: ${response.success}");
      debugPrint("📝 Message: ${response.message}");

      if (response.success && response.data != null) {
        // Store token and business data
        await TokenService().saveSession(
          accessToken: response.data!.token,
          refreshToken: response.data!.refreshToken,
        );
        await StorageService.saveUserId(response.data!.business.id ?? '');
        await StorageService.saveUserEmail(response.data!.business.email ?? '');
        await StorageService.saveUserName(
          response.data!.business.businessName ?? '',
        );
        await StorageService.saveUserRole('business');
        await StorageService.saveBusinessId(response.data!.business.id ?? '');

        debugPrint("💾 Token saved");
        debugPrint("👤 Business ID: ${response.data!.business.id}");

        // Update current business
        currentBusiness.value = response.data!.business;
        isLoggedIn.value = true;

        await StorageService.saveRememberMe('business', rememberMe.value);
        if (rememberMe.value) {
          await StorageService.saveSavedCredentials(
            'business',
            emailController.text.trim(),
            passwordController.text,
          );
        } else {
          await StorageService.clearSavedCredentials('business');
        }


        // Navigate to business home
        Get.offAllNamed(AppRoutes.businessHome);
      } else {
        debugPrint(" Login failed: ${response.message}");
        FloatingErrorBar.show(context, message:   "common.error".tr,);
      }
    } catch (e) {
      debugPrint(" Login Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Business Sign Up (Consolidated)
  Future<void> signUp({
    required String fullName,
    required String contact, // Email or Phone
    required String businessName,
    required String category,
    required String address,
    required String password,
    String? dob,
    String? occupation,
    String? referenceId,
    String? businessPhotoPath,
    String? idCardFrontPath,
    String? idCardBackPath,
  }) async {
    isLoading.value = true;

    try {
      // Determine if contact is email or phone
      String? email;
      String? phone;

      if (contact.contains('@')) {
        email = contact;
      } else {
        phone = contact;
      }

      final response = await _authService.signUp(
        businessName: businessName,
        ownerName: fullName,
        email: email,
        phone: phone,
        password: password,
        address: address,
        businessType: category,
        businessPhoto: businessPhotoPath,
        idCardFront: idCardFrontPath,
        idCardBack: idCardBackPath,
        occupation: occupation,
        referenceId: referenceId,
        dob: dob,
      );

      if (response.success && response.data != null) {
        // Store token and business data
        await TokenService().saveSession(
          accessToken: response.data!.token,
          refreshToken: response.data!.refreshToken,
        );
        await StorageService.saveUserId(response.data!.business.id ?? '');
        await StorageService.saveUserEmail(response.data!.business.email ?? '');
        await StorageService.saveUserName(
          response.data!.business.businessName ?? '',
        );
        await StorageService.saveUserRole('business');
        await StorageService.saveBusinessId(response.data!.business.id ?? '');

        // Update current business
        currentBusiness.value = response.data!.business;
        isLoggedIn.value = true;

        // Set temp contact for verification
        tempRegistrationEmail = email ?? (phone != null ? "$phone@tempmail.com" : '');
        tempRegistrationPhone = phone ?? '';
        //
        // Get.snackbar(
        //   "common.success".tr,
        //   "auth.account_created".tr,
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        // );

        // Navigate to OTP Verification
        Get.toNamed(AppRoutes.businessOtp, arguments: {'isRegistration': true});
      } else {
        Get.snackbar(
          "common.error".tr,
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint(" Registration Exception: $e");
      Get.snackbar(
        "common.error".tr,
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Send OTP
  Future<void> sendOtp() async {
    if (forgotEmailController.text.isEmpty) {
      Get.snackbar(
        "common.error".tr,
        "validation.please_enter_email_or_phone".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      String input = forgotEmailController.text.trim();
      String? email;
      String? phone;

      if (input.contains('@')) {
        email = input;
      } else {
        phone = input;
      }

      final response = await _authService.sendOtp(email: email, phone: phone);

      // Navigate to verification screen
      Get.toNamed(AppRoutes.businessOtp);
    } catch (e) {
      Get.snackbar(
        "common.error".tr,
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Temp storage for registration verification
  var tempRegistrationEmail = '';
  var tempRegistrationPhone = '';

  /// Verify Registration OTP
  Future<void> verifyRegistrationOtp(String otp) async {
    if (otp.isEmpty || otp.length != 6) {
      Get.snackbar(
        "common.error".tr,
        "validation.complete_verification_code".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await _authService.verifyRegistrationOtp(
        email: tempRegistrationEmail.isNotEmpty ? tempRegistrationEmail : null,
        phone: tempRegistrationPhone.isNotEmpty ? tempRegistrationPhone : null,
        otp: otp,
      );

      Get.offAllNamed(AppRoutes.businessLogin);
    } catch (e) {
      Get.snackbar(
        "common.error".tr,
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Verify OTP (Forgot Password)
  Future<void> verifyOtp() async {
    if (verificationCodeController.text.isEmpty) {
      Get.snackbar(
        "common.error".tr,
        "auth.enter_verification_code".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      String input = forgotEmailController.text.trim();
      String? email;
      String? phone;

      if (input.contains('@')) {
        email = input;
      } else {
        phone = input;
      }

      final response = await _authService.verifyOtp(
        email: email,
        phone: phone,
        otp: verificationCodeController.text.trim(),
      );

      Get.toNamed(AppRoutes.businessResetPassword);
    } catch (e) {
      Get.snackbar(
        "common.error".tr,
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Reset Password
  Future<void> resetPassword() async {
    if (newPasswordController.text.isEmpty ||
        confirmNewPasswordController.text.isEmpty) {
      Get.snackbar(
        "common.error".tr,
        "validation.field_required".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (newPasswordController.text != confirmNewPasswordController.text) {
      Get.snackbar(
        "common.error".tr,
        "validation.passwords_dont_match".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      String input = forgotEmailController.text.trim();
      String? email;
      String? phone;

      if (input.contains('@')) {
        email = input;
      } else {
        phone = input;
      }

      final response = await _authService.resetPassword(
        email: email,
        phone: phone,
        otp: verificationCodeController.text.trim(),
        newPassword: newPasswordController.text,
        confirmPassword: confirmNewPasswordController.text,
      );

      // Navigate back to login
      Get.offNamed(AppRoutes.businessLogin);
    } catch (e) {
      Get.snackbar(
        "common.error".tr,
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get Business Info
  Future<void> getBusinessInfo() async {
    try {
      final businessData = await _authService.getBusinessInfo();
      currentBusiness.value = BusinessModel.fromJson(businessData);
      debugPrint("====== BUSINESS OWNER LOGS ======");
      debugPrint("Raw API Data: $businessData");
      debugPrint("Parsed Logo: ${currentBusiness.value?.logo}");
      debugPrint("Parsed Name: ${currentBusiness.value?.businessName}");
      debugPrint("Image Version: ${imageVersion.value}");
      debugPrint("===============================");
    } catch (e) {
      debugPrint("Error loading business info: $e");
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      await FirebaseMessagingService.instance().removeTokenOnLogout();
      await StorageService.clearAll();
      currentBusiness.value = null;
      isLoggedIn.value = false;

      Get.offAllNamed(AppRoutes.userTypeSelection);

      // Get.snackbar(
      //   "common.success".tr,
      //   "profile.logout_success".tr,
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.green,
      //   colorText: Colors.white,
      // );
    } catch (e) {
      debugPrint("Sign Out Error: $e");
    }
  }

  /// Update Business Profile
  Future<void> updateProfile({
    required String fullName,
    required String email,
    String? phoneNumber,
    String? occupation,
    String? dateOfBirth,
    String? profilePicturePath,
    String? currentPassword,
    String? newPassword,
    String? confirmPassword,
  }) async {
    isLoading.value = true;
    try {
      final response = await _authService.updateProfile(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        occupation: occupation,
        dateOfBirth: dateOfBirth,
        profilePicturePath: profilePicturePath,
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      // Update business info directly from the PUT response data
      if (response['data'] != null) {
        currentBusiness.value = BusinessModel.fromJson(response['data']);
        debugPrint("✅ Updated currentBusiness from PUT response!");
      }
      
      // We can also fetch just to be perfectly synced
      await getBusinessInfo();
      await getBusinessProfile();
      imageVersion.value = DateTime.now().millisecondsSinceEpoch;

      // Update Local Storage with new data
      final business = currentBusiness.value;
      if (business != null) {
        if (business.email != null) {
          await StorageService.saveUserEmail(business.email!);
        }
        if (business.ownerName != null) {
          await StorageService.saveUserName(business.ownerName!);
        }
      }

      // Get.snackbar(
      //   "common.success".tr,
      //   response['message'] ?? "Profile updated successfully",
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.green,
      //   colorText: Colors.white,
      // );

      Get.back(); // Go back from edit screen
    } catch (e) {
      _handleError(e, prefix: "Profile Update Viewmodel Error");
    } finally {
      isLoading.value = false;
    }
  }

  /// Get Business Profile (Entity specifics)
  Future<void> getBusinessProfile() async {
    isLoading.value = true;
    try {
      final profileData = await _authService.getBusinessProfile();
      businessProfile.value = BusinessModel.fromJson(profileData);
      debugPrint("====== BUSINESS PROFILE LOGS ======");
      debugPrint("API Response: $profileData");
      debugPrint("Parsed Logo: ${businessProfile.value?.logo}");
      debugPrint("=================================");
      debugPrint("✅ Loaded business profile: ${businessProfile.value?.businessName}",);
    } catch (e) {
      debugPrint(" Error loading business profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Update Business Profile (Entity specifics)
  Future<void> updateBusinessProfile({
    required String businessName,
    required String businessCategory,
    required String businessAddress,
    required String description,
    String? businessLogoPath,
    String? businessCoverPath,
  }) async {
    isLoading.value = true;
    try {
      final response = await _authService.updateBusinessProfile(
        businessName: businessName,
        businessCategory: businessCategory,
        businessAddress: businessAddress,
        description: description,
        businessLogoPath: businessLogoPath,
        businessCoverPath: businessCoverPath,
      );

      // Refresh both
      await getBusinessProfile();
      await getBusinessInfo();
      imageVersion.value = DateTime.now().millisecondsSinceEpoch;

      Get.back(); // Go back from edit screen
    } catch (e) {
      _handleError(e, prefix: "Business Profile Update ViewModel Error");
    } finally {
      isLoading.value = false;
    }
  }

  /// Get FAQs
  Future<void> getFaqs() async {
    isLoading.value = true;
    try {
      final data = await _authService.getFaqs();
      faqs.assignAll(data);
      debugPrint("✅ Loaded ${faqs.length} FAQs");
    } catch (e) {
      debugPrint("❌ Error loading FAQs: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Get Privacy Policy
  Future<void> getPrivacyPolicy() async {
    isLoading.value = true;
    try {
      final data = await _authService.getPrivacyPolicy();
      privacyPolicy.value = data;
      debugPrint("✅ Loaded privacy policy");
    } catch (e) {
      debugPrint("❌ Error loading privacy policy: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Get Terms and Conditions
  Future<void> getTermsConditions() async {
    isLoading.value = true;
    try {
      final data = await _authService.getTermsConditions();
      termsConditions.value = data;
      debugPrint("✅ Loaded terms and conditions");
    } catch (e) {
      debugPrint("❌ Error loading terms and conditions: $e");
    } finally {
      isLoading.value = false;
    }
  }

  var stats = Rxn<Map<String, dynamic>>();

  /// Get Stats
  Future<void> getStats() async {
    // Don't set full page loading for stats as it's part of dashboard
    try {
      final data = await _authService.getStats();
      stats.value = data;
      debugPrint("✅ Loaded stats: $data");
    } catch (e) {
      debugPrint("❌ Error loading stats: $e");
    }
  }

  var activities = Rxn<List<dynamic>>();

  /// Get Activities
  Future<void> getActivities({String? timeFilter}) async {
    try {
      final data = await _authService.getActivities(timeFilter: timeFilter);
      activities.value = data;
      debugPrint("✅ Loaded activities: ${data.length} items (filter: $timeFilter)");
    } catch (e) {
      debugPrint("❌ Error loading activities: $e");
    }
  }

  /// Change Password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    isLoading.value = true;
    try {
      final response = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      // Clear password fields logic could be here but controllers are local to edit screen usually
    } catch (e) {
      debugPrint("❌ Change Password ViewModel Error: $e");
      Get.snackbar(
        "common.error".tr,
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete Account
  Future<void> deleteAccount() async {
    isLoading.value = true;
    try {
      final response = await _authService.deleteAccount();

      // Clear data and storage
      await StorageService.clearAll();
      currentBusiness.value = null;
      isLoggedIn.value = false;

      // Navigate to login
      Get.offAllNamed(AppRoutes.businessLogin);
    } catch (e) {
      debugPrint("❌ Delete Account ViewModel Error: $e");
      Get.snackbar(
        "common.error".tr,
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Note: Manual disposal of TextEditingControllers here can cause
    // "used after disposed" errors when navigating between screens
    // due to GetX's navigation life-cycle.
    // Flutter will garbage collect these when the controller is destroyed.
    super.onClose();
  }
}
