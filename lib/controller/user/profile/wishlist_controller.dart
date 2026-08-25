import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../models/user/profile/wishlist_model.dart';
import '../../../utils/token_service.dart';
import 'package:middle_ware/services/api_service.dart';

class WishlistController extends GetxController {
  var isLoading = false.obs;
  var items = <WishlistItem>[].obs;
  var errorMessage = ''.obs;
  var favoriteServiceIds = <String>{}.obs;

  final String wishlistUrl = "${ApiService.BASE_URL}/api/wishlist";
  final String wishlistServiceUrl = "${ApiService.BASE_URL}/api/wishlist/services";

  @override
  void onInit() {
    fetchWishlist();
    super.onInit();
  }

  Future<void> fetchWishlist() async {
    try {
      isLoading(true);
      errorMessage('');
      items.clear();
      favoriteServiceIds.clear();

      final token = await TokenService().getToken();
      if (token == null || token.isEmpty) {
        errorMessage.value = "No authentication token";
        return;
      }

      final response = await http.get(
        Uri.parse(wishlistUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final wishlistResponse = WishlistResponse.fromJson(body);
        items.value = wishlistResponse.data?.services ?? [];

        final ids = <String>{};
        for (final item in items) {
          final id = item.service?.serviceId;
          if (id != null && id.isNotEmpty) {
            ids.add(id);
          }
        }
        favoriteServiceIds.addAll(ids);
      } else {
        errorMessage.value = "Failed to load favorites";
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading(false);
    }
  }

  bool isFavorite(String? serviceId) {
    // Touch the Rx set so Obx can track updates even when serviceId is null/empty.
    favoriteServiceIds.length;
    if (serviceId == null || serviceId.isEmpty) return false;
    return favoriteServiceIds.contains(serviceId);
  }

  Future<void> toggleFavorite(String? serviceId, {String notes = ""}) async {
    if (serviceId == null || serviceId.isEmpty) {
      Get.snackbar("Error", "Service ID not available");
      return;
    }

    if (isFavorite(serviceId)) {
      await removeFavorite(serviceId);
      return;
    }

    try {
      final token = await TokenService().getToken();
      if (token == null || token.isEmpty) {
        Get.snackbar("Error", "No authentication token");
        return;
      }

      final response = await http.post(
        Uri.parse("$wishlistServiceUrl/$serviceId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'notes': notes}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchWishlist();
      } else {
        Get.snackbar("Error", "Failed to update favorites");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> removeFavorite(String? serviceId) async {
    if (serviceId == null || serviceId.isEmpty) {
      Get.snackbar("Error", "Service ID not available");
      return;
    }

    try {
      final token = await TokenService().getToken();
      if (token == null || token.isEmpty) {
        Get.snackbar("Error", "No authentication token");
        return;
      }

      final response = await http.delete(
        Uri.parse("$wishlistServiceUrl/$serviceId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await fetchWishlist();
      } else {
        Get.snackbar("Error", "Failed to remove favorite");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}
