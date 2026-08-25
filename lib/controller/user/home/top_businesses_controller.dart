import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../models/user/home/top_businesses_model.dart';
import '../../../utils/token_service.dart';
import 'package:middle_ware/services/api_service.dart';

class TopBusinessesController extends GetxController {
  var isLoading = false.obs;
  var businesses = <TopBusiness>[].obs;
  var errorMessage = ''.obs;

  @override
  void onReady() {
    super.onReady();
    if (businesses.isEmpty && !isLoading.value) {
      fetchTopBusinesses();
    }
  }

  Future<void> fetchTopBusinesses({int limit = 10, bool all = false}) async {
    try {
      isLoading(true);
      errorMessage('');
      
      final token = await TokenService().getToken();
      if (token == null || token.isEmpty) {
        errorMessage.value = "No authentication token";
        return;
      }

      final uri = all
          ? Uri.parse(
              "${ApiService.BASE_URL}/api/user/business-owner-profiles",
            ).replace(queryParameters: {'all': 'true'})
          : Uri.parse("${ApiService.BASE_URL}/api/user/top-businesses").replace(
              queryParameters: {'limit': limit.toString()},
            );
      final String url = uri.toString();
      
      print("Fetching top businesses: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Top Businesses status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final topBusinessesResponse = TopBusinessesResponse.fromJson(body);
        businesses.value = topBusinessesResponse.data?.businesses ?? <TopBusiness>[];
      } else {
        final body = jsonDecode(response.body);
        errorMessage.value =
            body is Map<String, dynamic> && body['message'] != null
            ? body['message'].toString()
            : "Failed to load top businesses";
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print("Error fetching top businesses: $e");
    } finally {
      isLoading(false);
    }
  }
}
