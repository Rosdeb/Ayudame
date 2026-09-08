import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/provider/provider_profile_model.dart';
import '../../../services/api_service.dart';
import '../../../utils/constants.dart';

class ProviderProfileController extends GetxController {
  var isLoading = false.obs;
  var providerProfile = Rxn<ProviderInfo>();
  var errorMessage = ''.obs;

  final String profileUrl = "${ApiService.BASE_URL}/api/providers/me";

  @override
  void onInit() {
    super.onInit();
    fetchProviderProfile();
  }

  static const String _providerProfileCacheKey = 'provider_profile_cache';

  Future<void> loadCachedProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_providerProfileCacheKey);
      if (cachedData != null && cachedData.isNotEmpty) {
        final data = jsonDecode(cachedData);
        final model = ProviderProfileModel.fromJson(data);
        providerProfile.value = model.data.provider;
      }
    } catch (e) {
      print("Error loading cached provider profile: $e");
    }
  }

  Future<void> fetchProviderProfile() async {
    await loadCachedProfile();

    try {
      if (providerProfile.value == null) isLoading(true);
      errorMessage('');

      final response = await ApiService.get(
        endpoint: '/api/providers/me',
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final model = ProviderProfileModel.fromJson(body);
        providerProfile.value = model.data.provider;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_providerProfileCacheKey, response.body);
      } else {
        if (providerProfile.value == null) errorMessage.value = "Failed to load provider profile";
      }
    } catch (e) {
      if (providerProfile.value == null) errorMessage.value = e.toString();
      print("Error fetching provider profile: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<bool> updateProviderProfile({
    required String fullName,
    required String phoneNumber,
    String? dateOfBirth,
    String? occupation,
  }) async {
    try {
      isLoading(true);
      errorMessage('');

      final body = {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        if (dateOfBirth != null && dateOfBirth.isNotEmpty) 'dateOfBirth': dateOfBirth,
        if (occupation != null && occupation.isNotEmpty) 'occupation': occupation,
      };

      print("Update Provider Profile Request Body: ${jsonEncode(body)}");

      final response = await ApiService.put(
        endpoint: '/api/providers/me',
        body: body,
      );

      print("Update Provider Profile Status: ${response.statusCode}");
      print("Update Provider Profile Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final model = ProviderProfileModel.fromJson(responseBody);
        providerProfile.value = model.data.provider;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_providerProfileCacheKey, response.body);
        
        return true;
      } else {
        // Try to parse error message from response
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage.value = errorBody['message'] ?? "Failed to update provider profile (${response.statusCode})";
        } catch (e) {
          errorMessage.value = "Failed to update provider profile (Status: ${response.statusCode})";
        }
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print("Error updating provider profile: $e");
      return false;
    } finally {
      isLoading(false);
    }
  }
}
