import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:middle_ware/services/api_service.dart';
import 'package:middle_ware/services/stripe_payment_service.dart';
import 'package:middle_ware/core/routes/app_routes.dart';
import '../../../models/user/home/ticket_purchase_model.dart';
import '../../../utils/token_service.dart';

class BuyTicketController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> purchaseTicket(
    String eventId,
    int quantity,
    List<TicketOwner> owners,
  ) async {
    if (eventId.isEmpty) {
      Get.snackbar("Error", "Event ID is missing");
      return;
    }

    final token = await TokenService().getToken();
    if (token == null || token.isEmpty) {
      errorMessage.value = "No authentication token";
      return;
    }

    try {
      isLoading(true);

      final purchaseRequest = TicketPurchaseRequest(
        quantity: quantity,
        ticketOwners: owners,
      );

      final response = await http.post(
        Uri.parse("${ApiService.BASE_URL}/api/events/$eventId/buy-tickets"),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(purchaseRequest.toJson()),
      );

      print("Purchase Response Status: ${response.statusCode}");
      print("Purchase Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final model = TicketPurchaseResponse.fromJson(body);

        if (model.success && model.data != null) {
          final clientSecret = model.data!.checkout.clientSecret.trim();
          if (clientSecret.isEmpty) {
            Get.snackbar("Error", "Payment client secret not found");
            return;
          }

          final paid = await StripePaymentService.instance.payWithClientSecret(
            clientSecret: clientSecret,
            merchantDisplayName: "Ayudame",
          );

          if (paid) {
            final TicketPurchaseDetail? detail =
                await _fetchTicketPurchaseDetail(
                  purchaseId: model.data!.purchaseId,
                  token: token,
                );

            if (detail != null) {
              Get.offNamed(AppRoutes.userInstantTicket, arguments: detail);
            } else {
              Get.offNamed(AppRoutes.paymentSuccess);
            }
          } else {
            Get.snackbar("Cancelled", "Payment was cancelled");
          }
        } else {
          Get.snackbar("Error", model.message);
        }
      } else {
        String failureMessage = "Purchase failed: ${response.statusCode}";
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic> &&
              decoded['message'] != null &&
              decoded['message'].toString().trim().isNotEmpty) {
            failureMessage = decoded['message'].toString().trim();
          }
        } catch (_) {}
        Get.snackbar("Error", failureMessage);
      }
    } catch (e, stackTrace) {
      print("Error in purchaseTicket: $e");
      print(stackTrace);
      Get.snackbar("Error", "An error occurred: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<TicketPurchaseDetail?> _fetchTicketPurchaseDetail({
    required String purchaseId,
    required String token,
  }) async {
    if (purchaseId.trim().isEmpty) {
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse("${ApiService.BASE_URL}/api/events/tickets/$purchaseId"),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        return null;
      }

      final body = jsonDecode(response.body);
      final detailResponse = TicketPurchaseDetailResponse.fromJson(body);
      if (!detailResponse.success) {
        return null;
      }
      return detailResponse.data?.purchase;
    } catch (_) {
      return null;
    }
  }
}
