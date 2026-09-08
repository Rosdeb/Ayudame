import 'dart:convert';
import 'package:get/get.dart';
import 'package:middle_ware/services/api_service.dart';
import '../../../models/provider/payment_history_model.dart';

class ProviderPaymentHistoryController extends GetxController {
  var isLoading = false.obs;
  var transactions = <ProviderTransaction>[].obs;
  var errorMessage = ''.obs;

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

      final response = await ApiService.get(
        endpoint: '/api/providers/bookings/transactions',
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
