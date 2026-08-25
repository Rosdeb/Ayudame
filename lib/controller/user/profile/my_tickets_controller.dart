import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:middle_ware/core/localization/app_translations.dart';
import 'package:middle_ware/services/api_service.dart';

import '../../../models/user/home/ticket_purchase_model.dart';
import '../../../utils/token_service.dart';

class MyTicketsController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var purchases = <TicketPurchaseDetail>[].obs;
  String t(String value) => AppTranslations.translateValue(value);

  Future<void> fetchMyTickets() async {
    final token = await TokenService().getToken();
    if (token == null || token.isEmpty) {
      errorMessage.value = t("No authentication token");
      purchases.clear();
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await http.get(
        Uri.parse("${ApiService.BASE_URL}/api/events/my-tickets?page=1&limit=100"),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        errorMessage.value =
            "${t("Failed to load tickets")}: ${response.statusCode}";
        purchases.clear();
        return;
      }

      final decoded = jsonDecode(response.body);
      final model = TicketPurchaseListResponse.fromJson(decoded);
      if (!model.success || model.data == null) {
        errorMessage.value = model.message.isNotEmpty
            ? model.message
            : t('Failed to load tickets');
        purchases.clear();
        return;
      }

      purchases.assignAll(model.data!.purchases);
    } catch (e) {
      errorMessage.value = t("Failed to load tickets");
      purchases.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
