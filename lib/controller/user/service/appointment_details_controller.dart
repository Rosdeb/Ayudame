import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../models/user/orders/order_model.dart';
import '../../../utils/token_service.dart';
import 'package:middle_ware/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:middle_ware/services/stripe_payment_service.dart';

class AppointmentDetailsController extends GetxController {
  var isLoading = false.obs;
  var appointment = Rxn<OrderModel>();
  final RxString _activeSource = OrderSource.provider.obs;

  Future<void> fetchAppointmentDetails(
    String id, {
    String source = OrderSource.provider,
  }) async {
    try {
      isLoading(true);
      _activeSource.value = _normalizeSource(source);

      final token = await TokenService().getToken();
      if (token == null) return;

      final uri = Uri.parse(
        "${ApiService.BASE_URL}${_appointmentBasePath(_activeSource.value)}/$id",
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Appointment Details API [$id]: ${response.statusCode}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          // The API returns { data: { appointment: { ... } } }
          final appointmentData = body['data']['appointment'] ?? body['data'];
          if (appointmentData is Map<String, dynamic>) {
            appointment.value = OrderModel.fromJson({
              ...appointmentData,
              'source': _activeSource.value,
            });
          } else if (appointmentData is Map) {
            appointment.value = OrderModel.fromJson({
              ...Map<String, dynamic>.from(appointmentData),
              'source': _activeSource.value,
            });
          }
        }
      } else {
        Get.snackbar('Error', 'Failed to load appointment details');
      }
    } catch (e) {
      print("Error fetching appointment details: $e");
      Get.snackbar('Error', 'Something went wrong');
    } finally {
      isLoading(false);
    }
  }

  Future<void> payAppointment(String id) async {
    try {
      isLoading(true);

      final token = await TokenService().getToken();
      if (token == null || token.isEmpty) {
        Get.snackbar('Error', 'Authorization token not found');
        return;
      }

      final response = await http.get(
        Uri.parse(
          "${ApiService.BASE_URL}${_appointmentBasePath(_activeSource.value)}/$id/checkout-session",
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
       print(response.body);
      if (response.statusCode != 200) {
        final message = _extractMessage(
          response.body,
          'Payment is not available yet. Please wait for provider acceptance.',
        );
        if (response.statusCode == 404 || response.statusCode == 409) {
          await fetchAppointmentDetails(id, source: _activeSource.value);
        }
        final bool alreadyPaid = response.statusCode == 409 &&
            message.toLowerCase().contains('already paid');
        final bool processing = response.statusCode == 409 &&
            message.toLowerCase().contains('processing');
        Get.snackbar(
          alreadyPaid
              ? 'Info'
              : (processing ? 'Processing' : 'Payment Pending'),
          message,
          backgroundColor: alreadyPaid
              ? Colors.blueGrey
              : (processing ? Colors.blueGrey : Colors.orange),
          colorText: Colors.white,
        );
        return;
      }

      final body = jsonDecode(response.body);
      final clientSecret = _extractClientSecret(body);
      if (clientSecret == null || clientSecret.isEmpty) {
        Get.snackbar('Error', 'Payment client secret not found');
        return;
      }

      final paid = await StripePaymentService.instance.payWithClientSecret(
        clientSecret: clientSecret,
        merchantDisplayName: 'Ayudame',
      );

      if (paid) {
        Get.snackbar('Success', 'Appointment payment completed');
        await fetchAppointmentDetails(id, source: _activeSource.value);
      } else {
        Get.snackbar('Cancelled', 'Payment was cancelled');
      }
    } catch (e) {
      print("Error paying appointment: $e");
      Get.snackbar('Error', 'Unable to process payment right now');
    } finally {
      isLoading(false);
    }
  }

  String? _extractClientSecret(dynamic responseBody) {
    final data = responseBody['data'];
    if (data is Map<String, dynamic>) {
      final direct = data['clientSecret'];
      if (direct is String && direct.isNotEmpty) {
        return direct;
      }
      final checkout = data['checkout'];
      if (checkout is Map<String, dynamic>) {
        final nested = checkout['clientSecret'];
        if (nested is String && nested.isNotEmpty) {
          return nested;
        }
      }
    }
    return null;
  }

  String _extractMessage(String rawBody, String fallback) {
    try {
      final body = jsonDecode(rawBody);
      final message = body['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    } catch (_) {}
    return fallback;
  }

  String _normalizeSource(String source) {
    final normalized = source
        .toLowerCase()
        .replaceAll('_', '')
        .replaceAll('-', '')
        .replaceAll(' ', '');
    if (normalized == 'businessowner') {
      return OrderSource.businessOwner;
    }
    return OrderSource.provider;
  }

  String _appointmentBasePath(String source) {
    return _normalizeSource(source) == OrderSource.businessOwner
        ? '/api/business-owner-appointments'
        : '/api/appointments';
  }
}
