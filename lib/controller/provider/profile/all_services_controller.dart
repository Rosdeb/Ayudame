import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/provider/provider_service_model.dart';
import '../../../services/api_service.dart';

class AllServicesController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var services = <ProviderService>[].obs;

  static const String _cacheKey = 'provider_all_services_cache';

  @override
  void onInit() {
    super.onInit();
    loadFromCacheAndFetch();
  }

  Future<void> loadFromCacheAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);
    
    if (cachedData != null && cachedData.isNotEmpty) {
      try {
        final List<dynamic> list = json.decode(cachedData);
        services.value = list
            .whereType<Map>()
            .map((e) => ProviderService.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        
        // Silently fetch updates in background if we have cache
        fetchServices(background: true);
      } catch (e) {
        // If cache is corrupted, fetch normally
        fetchServices(background: false);
      }
    } else {
      // No cache, fetch normally with loading indicator
      fetchServices(background: false);
    }
  }

  Future<void> fetchServices({bool background = false}) async {
    if (!background) {
      isLoading(true);
      errorMessage('');
    }

    try {
      final List<String> endpoints = <String>[
        "/api/services?includeEmployeeServices=true",
        "/api/services",
        "/api/providers/services",
      ];

      bool loaded = false;
      String debugResponse = "";
      List<dynamic> finalList = [];

      for (final endpoint in endpoints) {
        final response = await ApiService.get(
          endpoint: endpoint,
          requireAuth: true,
        );

        if (response.statusCode != 200) {
          continue;
        }

        debugResponse = response.body;
        print("All services log: $debugResponse");

        final data = json.decode(response.body);
        List<dynamic> list = <dynamic>[];

        if (data is Map && data['data'] is Map) {
          final Map<String, dynamic> dataMap = Map<String, dynamic>.from(data['data']);
          if (dataMap['services'] is List) {
            list = dataMap['services'] as List<dynamic>;
          } else if (dataMap['items'] is List) {
            list = dataMap['items'] as List<dynamic>;
          } else if (dataMap['service'] is Map) {
            list = <dynamic>[dataMap['service']];
          }
        } else if (data is Map && data['services'] is List) {
          list = data['services'] as List<dynamic>;
        } else if (data is List) {
          list = data;
        } else if (data is Map && data['data'] is List) {
          list = data['data'] as List<dynamic>;
        }

        final parsedList = list
            .whereType<Map>()
            .map((e) => ProviderService.fromJson(Map<String, dynamic>.from(e)))
            .where((service) => service.id.isNotEmpty)
            .toList();

        if (parsedList.isNotEmpty) {
          services.value = parsedList;
          finalList = list;
          loaded = true;
          break;
        }
      }

      if (loaded) {
        // Save to cache
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(_cacheKey, json.encode(finalList));
      } else {
        if (!background) {
          // Remove debug logs to make UI cleaner
          errorMessage('No services found.');
        }
      }
    } catch (e) {
      if (!background) {
        errorMessage('Error fetching services: $e');
      }
    } finally {
      if (!background) {
        isLoading(false);
      }
    }
  }
}
