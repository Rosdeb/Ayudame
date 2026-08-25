import 'dart:convert';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../../models/user/home/nearby_providers_model.dart';
import '../../../utils/token_service.dart';
import 'package:middle_ware/services/api_service.dart';

class NearbyProvidersController extends GetxController {
  var isLoading = false.obs;
  var providers = <NearbyProvider>[].obs;
  var categories = <CategoryWithProviders>[].obs;
  var errorMessage = ''.obs;
  var searchRadiusKm = '10.0'.obs; // Default value

  final String nearbyProvidersUrl =
      "${ApiService.BASE_URL}/api/home/nearby-providers";

  @override
  void onInit() {
    fetchNearbyProviders();
    super.onInit();
  }

  Future<void> fetchNearbyProviders({
    double? latitude,
    double? longitude,
    int maxDistance = 10000,
  }) async {
    try {
      isLoading(true);
      errorMessage('');
      providers.clear();
      categories.clear();

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
        _syncUserLocationToBackend(
          token: token,
          latitude: resolvedCoordinates.$1,
          longitude: resolvedCoordinates.$2,
        );
      }

      final uri = Uri.parse(nearbyProvidersUrl).replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Nearby Providers API Status: ${response.statusCode}");
      print("Nearby Providers API Body: ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final nearbyResponse = NearbyProvidersResponse.fromJson(body);

        if (nearbyResponse.data != null) {
          providers.value = nearbyResponse.data!.providers ?? [];
          categories.value = nearbyResponse.data!.categories ?? [];

          // Store search radius
          if (nearbyResponse.data!.searchRadius != null) {
            searchRadiusKm.value = nearbyResponse.data!.searchRadius!.kilometers ?? '10.0';
          }

          if (providers.isEmpty && categories.isNotEmpty && resolvedCoordinates != null) {
            providers.value = await _fetchProvidersFromTopCategories(
              token: token,
              latitude: resolvedCoordinates.$1,
              longitude: resolvedCoordinates.$2,
              maxDistance: maxDistance,
            );
          }
        }
      } else {
        errorMessage.value = _extractMessage(
          rawBody: response.body,
          fallback: "Failed to load nearby providers",
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print("Error fetching nearby providers: $e");
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

  Future<List<NearbyProvider>> _fetchProvidersFromTopCategories({
    required String token,
    required double latitude,
    required double longitude,
    required int maxDistance,
  }) async {
    final Map<String, NearbyProvider> uniqueProviders = {};
    final categoryIds = categories
        .map((c) => c.categoryId?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .take(5)
        .toList();

    for (final categoryId in categoryIds) {
      final Uri uri = Uri.parse(
        "${ApiService.BASE_URL}/api/home/nearby-providers/category/$categoryId?latitude=$latitude&longitude=$longitude&maxDistance=$maxDistance",
      );

      try {
        final response = await http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode != 200) continue;

        final body = jsonDecode(response.body);
        final dynamic rawProviders = body['data']?['providers'];
        if (rawProviders is! List) continue;

        for (final item in rawProviders) {
          if (item is! Map) continue;
          final map = Map<String, dynamic>.from(item);
          final nearbyProvider = NearbyProvider.fromJson(map);
          final String key = (nearbyProvider.providerId ?? '').trim();
          if (key.isEmpty || uniqueProviders.containsKey(key)) continue;
          uniqueProviders[key] = nearbyProvider;
        }
      } catch (_) {
        // Ignore per-category errors and continue with remaining categories.
      }
    }

    final List<NearbyProvider> merged = uniqueProviders.values.toList();
    merged.sort((a, b) {
      final double da = a.distance ?? double.infinity;
      final double db = b.distance ?? double.infinity;
      return da.compareTo(db);
    });
    return merged;
  }

  Future<void> _syncUserLocationToBackend({
    required String token,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final Uri uri = Uri.parse("${ApiService.BASE_URL}/api/auth/update-location");
      await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
        }),
      );
    } catch (_) {
      // Best-effort background sync only.
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
