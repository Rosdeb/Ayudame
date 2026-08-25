import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:middle_ware/models/user/home/top_businesses_model.dart';
import 'package:middle_ware/services/api_service.dart';
import 'package:middle_ware/utils/token_service.dart';

class CategoryBusinessesController extends GetxController {
  var isLoading = false.obs;
  var businesses = <TopBusiness>[].obs;
  var errorMessage = ''.obs;

  Future<void> fetchBusinessesByCategory(String categoryId) async {
    final String normalizedCategoryId = categoryId.trim();
    if (normalizedCategoryId.isEmpty) {
      errorMessage.value = "Invalid category";
      businesses.clear();
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = await TokenService().getToken();
      if (token == null || token.isEmpty) {
        errorMessage.value = "No authentication token";
        businesses.clear();
        return;
      }

      final Uri url = Uri.parse(
        "${ApiService.BASE_URL}/api/user/business-owner-profiles",
      ).replace(queryParameters: {'all': 'true'});

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        try {
          final body = jsonDecode(response.body);
          errorMessage.value =
              body is Map<String, dynamic> && body['message'] != null
              ? body['message'].toString()
              : "Failed to load businesses";
        } catch (_) {
          errorMessage.value = "Failed to load businesses";
        }
        businesses.clear();
        return;
      }

      final dynamic decoded = jsonDecode(response.body);
      final dynamic data = decoded is Map ? decoded['data'] : null;
      final dynamic profiles = data is Map ? data['profiles'] : null;

      if (profiles is! List) {
        businesses.clear();
        return;
      }

      final List<TopBusiness> filtered = profiles
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .where((profile) => _profileHasCategory(profile, normalizedCategoryId))
          .map((profile) => TopBusiness.fromJson(profile))
          .toList();

      businesses.value = filtered;
    } catch (e) {
      errorMessage.value = e.toString();
      businesses.clear();
    } finally {
      isLoading.value = false;
    }
  }

  bool _profileHasCategory(Map<String, dynamic> profile, String categoryId) {
    String? idFromDynamic(dynamic value) {
      if (value == null) return null;
      if (value is String) return value.trim();
      if (value is Map) {
        final dynamic rawId = value['id'] ?? value['_id'] ?? value['categoryId'];
        return rawId?.toString().trim();
      }
      return null;
    }

    // Single business category (businessCategory: { id, name, ... })
    final String? primaryId = idFromDynamic(profile['businessCategory']);
    if (primaryId != null && primaryId == categoryId) return true;

    // Multiple categories (businessProfile.categories: [{ _id, name, ... }, ...])
    final dynamic businessProfile = profile['businessProfile'];
    final dynamic categories =
        businessProfile is Map ? businessProfile['categories'] : null;
    if (categories is List) {
      for (final c in categories) {
        final String? id = idFromDynamic(c);
        if (id != null && id == categoryId) return true;
      }
    }

    return false;
  }
}

