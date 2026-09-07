import 'dart:convert';
import 'package:get/get.dart';
import '../../../models/user/categories/category_model.dart';
import '../../../services/api_service.dart';

class CategoryController extends GetxController {
  var isLoading = false.obs;
  var categories = <CategoryModel>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories({String? query}) async {
    try {
      isLoading(true);
      errorMessage('');

      String endpoint = '/api/user/categories';
      if (query != null && query.trim().isNotEmpty) {
        endpoint += '?q=${Uri.encodeComponent(query.trim())}';
      }

      final response = await ApiService.get(
        endpoint: endpoint,
        requireAuth: true,
      );

      print("Category API Status: ${response.statusCode}");
      print("Category API Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData["success"] == true) {
          final List list = jsonData["data"]["categories"];
          categories.value = list.map((e) => CategoryModel.fromJson(e)).toList();
        } else {
          errorMessage.value = "Failed to load categories";
        }
      } else {
        errorMessage.value = "Server Error: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading(false);
    }
  }

  Future<void> searchCategories(String query) async {
    await fetchCategories(query: query);
  }
}
