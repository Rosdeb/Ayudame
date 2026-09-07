import 'dart:convert';
import 'package:get/get.dart';
import '../../../models/provider/provider_service_model.dart';
import '../../../services/api_service.dart';

class AllServicesController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var services = <ProviderService>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  Future<void> fetchServices() async {
    isLoading(true);
    errorMessage('');

    try {
      final List<String> endpoints = <String>[
        "/api/services?includeEmployeeServices=true",
        "/api/services",
        "/api/providers/services",
      ];

      bool loaded = false;
      for (final endpoint in endpoints) {
        final response = await ApiService.get(
          endpoint: endpoint,
          requireAuth: true,
        );

        if (response.statusCode != 200) {
          continue;
        }

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
        }

        services.value = list
            .whereType<Map>()
            .map((e) => ProviderService.fromJson(Map<String, dynamic>.from(e)))
            .where((service) => service.id.isNotEmpty)
            .toList();

        if (services.isNotEmpty || endpoint == endpoints.last) {
          loaded = true;
          break;
        }
      }

      if (!loaded) {
        errorMessage('Failed to load services.');
      }
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }
}
