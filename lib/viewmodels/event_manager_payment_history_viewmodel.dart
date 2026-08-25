import 'dart:convert';
import 'package:get/get.dart';
import 'package:middle_ware/models/event_manager_payment_history_model.dart';
import 'package:middle_ware/services/api_service.dart';

class EventManagerPaymentHistoryViewModel extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<EventManagerTransaction> transactions =
      <EventManagerTransaction>[].obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      transactions.clear();

      final response = await ApiService.get(
        endpoint: '/api/event-managers/transactions',
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final model = EventManagerPaymentHistoryResponse.fromJson(decoded);
          transactions.assignAll(
            model.data?.transactions ?? <EventManagerTransaction>[],
          );
          return;
        }
        errorMessage.value = 'Invalid response format';
        return;
      }

      String message = 'Failed to load payment history (${response.statusCode}).';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final rawMessage = decoded['message'];
          if (rawMessage is String && rawMessage.trim().isNotEmpty) {
            message = rawMessage.trim();
          }
        }
      } catch (_) {}
      errorMessage.value = message;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
