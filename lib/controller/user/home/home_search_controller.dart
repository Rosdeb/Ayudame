import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:middle_ware/models/user/home/home_search_model.dart';
import 'package:middle_ware/services/api_service.dart';
import 'package:middle_ware/utils/token_service.dart';

class HomeSearchController extends GetxController {
  final isSearchActive = false.obs;
  final isSearching = false.obs;
  final errorMessage = ''.obs;
  final currentQuery = ''.obs;
  final results = <HomeSearchServiceItem>[].obs;

  Timer? _debounce;

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  void searchServices(String query) {
    final String trimmedQuery = query.trim();
    currentQuery.value = trimmedQuery;

    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    if (trimmedQuery.isEmpty) {
      clearSearch();
      return;
    }

    isSearchActive.value = true;
    errorMessage.value = '';

    if (trimmedQuery.length < 2) {
      isSearching.value = false;
      results.clear();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 450), () async {
      await _performSearch(trimmedQuery);
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      isSearching.value = true;
      errorMessage.value = '';

      final token = await TokenService().getToken();
      final uri = Uri.parse("${ApiService.BASE_URL}/api/services").replace(
        queryParameters: {
          'search': query,
          'page': '1',
          'limit': '20',
        },
      );

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final parsed = HomeSearchResponse.fromJson(decoded);
        final filtered = parsed.services
            .where((item) => item.isValidProviderService)
            .toList();
        results.assignAll(filtered);
        return;
      }

      errorMessage.value = _extractMessage(
        rawBody: response.body,
        fallback: 'Failed to search services',
      );
      results.clear();
    } catch (e) {
      errorMessage.value = e.toString();
      results.clear();
    } finally {
      isSearching.value = false;
    }
  }

  void clearSearch() {
    currentQuery.value = '';
    isSearchActive.value = false;
    isSearching.value = false;
    errorMessage.value = '';
    results.clear();
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
