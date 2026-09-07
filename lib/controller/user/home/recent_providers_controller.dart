import 'dart:convert';
import 'package:get/get.dart';
import '../../../models/user/home/recent_providers_model.dart';
import 'package:middle_ware/services/api_service.dart';




class RecentProviderController extends GetxController {
  var isLoading = false.obs;
  var providerList = <ProviderModel>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRecentProviders();
  }

  Future<void> fetchRecentProviders() async {
    try {
      isLoading(true);
      errorMessage('');

      // Using the global ApiService which automatically handles tokens and headers!
      final response = await ApiService.get(
        endpoint: '/api/auth/recent-providers',
        requireAuth: true, 
      );

      print("Recent Providers Status: ${response.statusCode}");
      print("Recent Providers Body: ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        final model = RecentProviderResponse.fromJson(body);

        // Assign list to GetX observable
        providerList.assignAll(model.data.providers);
      } else {
        final body = jsonDecode(response.body);
        errorMessage.value =
            body is Map<String, dynamic> && body['message'] != null
            ? body['message'].toString()
            : "Failed to load recent providers";
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading(false);
    }
  }
}
