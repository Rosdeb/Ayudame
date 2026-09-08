import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../../../services/notifications/firebase_messaging_service.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/routes/app_routes.dart';
import '../../../models/user/profile/profile_model.dart';
import '../../../utils/token_service.dart';
import '../../../utils/constants.dart';
import 'package:middle_ware/services/api_service.dart';
import 'package:middle_ware/services/storage_service.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var user = Rxn<UserModel>();
  final String profileUrl = "${ApiService.BASE_URL}/api/auth/me";

  @override
  void onInit() {
    super.onInit();
    getProfile();
  }


  Future<bool> hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  static const String _profileCacheKey = 'user_profile_cache';

  Future<void> loadCachedProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_profileCacheKey);
      if (cachedData != null && cachedData.isNotEmpty) {
        final data = jsonDecode(cachedData);
        user.value = UserModel.fromJson(data);
      }
    } catch (e) {
      print("Error loading cached profile: $e");
    }
  }

  Future<void> getProfile() async {
    await loadCachedProfile();

    if (!await hasInternetConnection()) {
      if (user.value == null) {
        errorMessage.value = "No internet connection";
      }
      return;
    }

    final token = await TokenService().getToken();
    print("Loaded token in ProfileController: $token");
    if (token == null || token.isEmpty) {
      if (user.value == null) errorMessage.value = "No authentication token";
      return;
    }

    try {
      if (user.value == null) isLoading(true);

      final response = await http.get(
        Uri.parse(profileUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['data']['user'];
        user.value = UserModel.fromJson(userData);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_profileCacheKey, jsonEncode(userData));
      } else {
        if (user.value == null) Get.snackbar("Error", "Failed to load profile: ${response.statusCode}");
      }
    } catch (e) {
      if (user.value == null) Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }


  Future<void> fetchProfile() async {
    print('ProfileController: fetchProfile() called, redirecting to getProfile()');
    await getProfile();
  }

  Future<void> logout() async {
    await FirebaseMessagingService.instance().removeTokenOnLogout();
    await TokenService().clearToken();
    await StorageService.clearAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileCacheKey);
    Get.offAllNamed(AppRoutes.userTypeSelection);
  }
}
