import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../models/provider/portfolio_model.dart';
import '../../services/api_service.dart';

class PortfolioController extends GetxController {
  var isLoading = false.obs;
  var portfolioList = <PortfolioModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getAllPortfolios();
  }

  Future<void> getAllPortfolios() async {
    try {
      isLoading(true);
      
      var response = await ApiService.get(
        endpoint: '/api/providers/portfolio',
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          List<dynamic> list = [];
          if (jsonResponse['data'] != null && jsonResponse['data']['portfolio'] != null) {
             list = jsonResponse['data']['portfolio'];
          }

          portfolioList.value = list.map((e) => PortfolioModel.fromJson(e)).toList();
        }
      } else {
        Get.snackbar("Error", "Failed to fetch portfolios");
      }
    } catch (e) {
      print("Error fetching portfolios: $e");
      Get.snackbar("Error", "An error occurred while fetching portfolios");
    } finally {
      isLoading(false);
    }
  }

  Future<bool> addPortfolio({
    required String title,
    required String about,
    required String serviceType,
    required File beforeImage,
    required File afterImage,
  }) async {
    try {
      isLoading(true);
      
      var streamedResponse = await ApiService.postMultipart(
        endpoint: '/api/providers/portfolio',
        fields: {
          'title': title,
          'about': about,
          'serviceType': serviceType,
        },
        files: {
          'beforeImage': beforeImage.path,
          'afterImage': afterImage.path,
        },
      );
      
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
           getAllPortfolios(); // Refresh list
           return true;
        }
      }
      
      var errorMsg = "Failed to add portfolio";
      try {
        var jsonResponse = json.decode(response.body);
        errorMsg = jsonResponse['message'] ?? errorMsg;
      } catch (_) {}
      
      Get.snackbar("Error", errorMsg);
      return false;
      
    } catch (e) {
      print("Error adding portfolio: $e");
      Get.snackbar("Error", "An error occurred");
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<bool> editPortfolio({
    required String id,
    required String title,
    required String about,
    required String serviceType,
    File? beforeImage,
    File? afterImage,
  }) async {
    try {
      isLoading(true);
      
      var streamedResponse = await ApiService.postMultipart(
        endpoint: '/api/providers/portfolio/$id',
        method: 'PUT',
        fields: {
          'title': title,
          'about': about,
          'serviceType': serviceType,
        },
        files: {
          if (beforeImage != null) 'beforeImage': beforeImage.path,
          if (afterImage != null) 'afterImage': afterImage.path,
        },
      );
      
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
           getAllPortfolios();
           return true;
        }
      }
      
      var errorMsg = "Failed to update portfolio";
      try {
        var jsonResponse = json.decode(response.body);
        errorMsg = jsonResponse['message'] ?? errorMsg;
      } catch (_) {}
      
      Get.snackbar("Error", errorMsg);
      return false;

    } catch (e) {
      print("Error updating portfolio: $e");
      Get.snackbar("Error", "An error occurred");
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<bool> deletePortfolio(String id) async {
    try {
      isLoading(true);
      
      var response = await ApiService.delete(
        endpoint: '/api/providers/portfolio/$id',
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          getAllPortfolios();
          return true;
        }
      }
      
      Get.snackbar("Error", "Failed to delete portfolio");
      return false;

    } catch (e) {
      print("Error deleting portfolio: $e");
      Get.snackbar("Error", "An error occurred");
      return false;
    } finally {
      isLoading(false);
    }
  }
}
