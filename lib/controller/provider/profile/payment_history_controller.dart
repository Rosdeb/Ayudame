import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:middle_ware/services/api_service.dart';
import 'package:middle_ware/utils/token_service.dart';
import '../../../models/provider/payment_history_model.dart';

class ProviderPaymentHistoryController extends GetxController {
  var isLoading = false.obs;
  var transactions = <ProviderTransaction>[].obs;
  var errorMessage = ''.obs;

  final String transactionsUrl =
      "${ApiService.BASE_URL}/api/providers/bookings/transactions";

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      isLoading(true);
      errorMessage('');
      transactions.clear();

      await TokenService().init();
      final token = await TokenService().getToken();
      if (token == null || token.isEmpty) {
        errorMessage.value = "No authentication token";
        return;
      }

      final response = await http.get(
        Uri.parse(transactionsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final model = ProviderPaymentHistoryResponse.fromJson(body);
        transactions.value = model.data?.transactions ?? [];
      } else {
        errorMessage.value =
            "Failed to load payment history (${response.statusCode}).";
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading(false);
    }
  }
}
