import 'dart:convert';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../../models/user/home/category_providers_model.dart';
import '../../../utils/token_service.dart';
import 'package:middle_ware/services/api_service.dart';

class CategoryProvidersController extends GetxController {
  var isLoading = false.obs;
  var providers = <CategoryProvider>[].obs;
  var errorMessage = ''.obs;

  Future<void> fetchCategoryProviders(String categoryId, {
    double? latitude,
    double? longitude,
    int maxDistance = 10000,
  }) async {
    try {
      isLoading(true);
      errorMessage('');
      providers.clear();

      final token = await TokenService().getToken();
      if (token == null || token.isEmpty) {
        errorMessage.value = "No authentication token";
        return;
      }

      final resolvedCoordinates = await _resolveCoordinates(
        latitude: latitude,
        longitude: longitude,
      );
      final Map<String, String> queryParams = {
        'maxDistance': '$maxDistance',
      };
      if (resolvedCoordinates != null) {
        queryParams['latitude'] = '${resolvedCoordinates.$1}';
        queryParams['longitude'] = '${resolvedCoordinates.$2}';
      }
      final uri = Uri.parse(
        "${ApiService.BASE_URL}/api/home/nearby-providers/category/$categoryId",
      ).replace(queryParameters: queryParams);

      print("Fetching category providers: $uri");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Category Providers status: ${response.statusCode}");
      print("Category Providers body: ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final categoryResponse = CategoryProvidersResponse.fromJson(body);
        
        if (categoryResponse.data?.providers != null) {
          providers.value = categoryResponse.data!.providers!;
        }
      } else {
        errorMessage.value = _extractMessage(
          rawBody: response.body,
          fallback: "Failed to load providers",
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print("Error fetching category providers: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<(double, double)?> _resolveCoordinates({
    required double? latitude,
    required double? longitude,
  }) async {
    if (latitude != null && longitude != null) {
      return (latitude, longitude);
    }

    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      return (position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }

  String _extractMessage({required String rawBody, required String fallback}) {
    try {
      final decoded = jsonDecode(rawBody);
      final dynamic message = decoded is Map ? decoded['message'] : null;
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    } catch (_) {}
    return fallback;
  }
}
