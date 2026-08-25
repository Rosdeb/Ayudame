import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../models/user/orders/order_model.dart';
import '../../../utils/token_service.dart';
import 'package:middle_ware/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:middle_ware/services/stripe_payment_service.dart';

class BookingDetailsController extends GetxController {
  var isLoading = false.obs;
  var booking = Rxn<OrderModel>();
  final RxString _activeSource = OrderSource.provider.obs;

  void _logApiRequest(String method, Uri uri, {Object? body}) {
    print("[BookingDetails][API][REQ] $method $uri");
    if (body != null) {
      print("[BookingDetails][API][REQ_BODY] $body");
    }
  }

  void _logApiResponse(String method, Uri uri, http.Response response) {
    print(
      "[BookingDetails][API][RES] $method $uri -> ${response.statusCode}",
    );
    print("[BookingDetails][API][RES_BODY] ${response.body}");
  }

  Future<void> fetchBookingDetails(
    String id, {
    String source = OrderSource.provider,
  }) async {
    try {
      isLoading(true);
      _activeSource.value = _normalizeSource(source);

      final token = await TokenService().getToken();
      if (token == null) return;

      final uri = Uri.parse(
        "${ApiService.BASE_URL}${_bookingBasePath(_activeSource.value)}/$id",
      );
      _logApiRequest('GET', uri);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      _logApiResponse('GET', uri, response);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final dynamic bookingData = body['data'];
          if (bookingData is Map<String, dynamic>) {
            booking.value = OrderModel.fromJson({
              ...bookingData,
              'source': _activeSource.value,
            });
          } else if (bookingData is Map) {
            booking.value = OrderModel.fromJson({
              ...Map<String, dynamic>.from(bookingData),
              'source': _activeSource.value,
            });
          }
        }
      } else {
        Get.snackbar('Error', 'Failed to load booking details');
      }
    } catch (e) {
      print("Error fetching booking details: $e");
      Get.snackbar('Error', 'Something went wrong');
    } finally {
      isLoading(false);
    }
  }

  Future<void> cancelBooking(String id) async {
    try {
      isLoading(true);

      final token = await TokenService().getToken();
      if (token == null) return;

      final uri = Uri.parse(
        "${ApiService.BASE_URL}${_bookingBasePath(_activeSource.value)}/$id/cancel",
      );
      _logApiRequest('PATCH', uri);

      final response = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      _logApiResponse('PATCH', uri, response);

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Booking cancelled successfully',
          backgroundColor: const Color(0xFF1E523F),
          colorText: Colors.white,
        );
        // Refresh details to update UI status
        fetchBookingDetails(id, source: _activeSource.value);
      } else {
        final body = jsonDecode(response.body);
        Get.snackbar(
          'Error',
          body['message'] ?? 'Failed to cancel booking',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error cancelling booking: $e");
      Get.snackbar('Error', 'Something went wrong');
    } finally {
      isLoading(false);
    }
  }

  Future<void> payDue(String id) async {
    try {
      isLoading(true);

      final token = await TokenService().getToken();
      if (token == null || token.isEmpty) {
        Get.snackbar('Error', 'Authorization token not found');
        return;
      }

      final statusUri = Uri.parse(
        "${ApiService.BASE_URL}${_bookingBasePath(_activeSource.value)}/$id/payment-status",
      );
      _logApiRequest('GET', statusUri);
      final statusRes = await http.get(
        statusUri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      _logApiResponse('GET', statusUri, statusRes);

      if (statusRes.statusCode != 200) {
        final msg = _extractMessage(
          statusRes.body,
          'Failed to fetch payment status',
        );
        Get.snackbar(
          'Error',
          msg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final statusBody = _decodeMap(statusRes.body);
      if (statusBody == null) {
        Get.snackbar(
          'Error',
          'Unexpected payment status response from server',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      final paymentStatus = (statusBody['data']?['paymentStatus'] ?? '')
          .toString()
          .toLowerCase();
      final paymentIntentStatus =
          (statusBody['data']?['paymentIntentStatus'] ?? '')
              .toString()
              .toLowerCase();

      if (paymentStatus == 'completed' || paymentStatus == 'offline_paid') {
        Get.snackbar('Info', 'This booking is already fully paid');
        return;
      }

      if (paymentStatus == 'due_requested') {
        await _payDueAmount(id, token, _activeSource.value);
        return;
      }

      final bool downPaymentAlreadySettled =
          paymentStatus == 'authorized' ||
          (paymentStatus == 'partial' &&
              (paymentIntentStatus == 'succeeded' ||
                  paymentIntentStatus == 'requires_capture' ||
                  paymentIntentStatus == 'processing'));

      if (downPaymentAlreadySettled) {
        Get.snackbar(
          'Info',
          'Down payment is already completed. Wait for provider due request.',
        );
        return;
      }

      await _payDownPayment(id, token, _activeSource.value);
    } catch (e) {
      print("Error processing payment: $e");
      Get.snackbar(
        'Payment Error',
        _humanizeError(e, fallback: 'Unable to process payment right now'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> _payDownPayment(
    String bookingId,
    String token,
    String source,
  ) async {
    final checkoutUri = Uri.parse(
      "${ApiService.BASE_URL}${_bookingBasePath(source)}/$bookingId/checkout-session",
    );
    _logApiRequest('GET', checkoutUri);
    final response = await http.get(
      checkoutUri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    _logApiResponse('GET', checkoutUri, response);

    if (response.statusCode != 200) {
      final msg = _extractMessage(
        response.body,
        'Payment is not available yet. Please wait for provider acceptance.',
      );
      if (response.statusCode == 409) {
        await fetchBookingDetails(bookingId, source: source);
        Get.snackbar('Info', msg);
        return;
      }
      if (response.statusCode == 404) {
        await fetchBookingDetails(bookingId, source: source);
      }
      Get.snackbar(
        'Payment Pending',
        msg,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final body = _decodeMap(response.body);
    if (body == null) {
      Get.snackbar(
        'Error',
        'Unexpected payment response from server',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final intentStatus = (body['data']?['status'] ?? '').toString().toLowerCase();
    if (intentStatus == 'succeeded' ||
        intentStatus == 'requires_capture' ||
        intentStatus == 'processing') {
      Get.snackbar('Info', 'Down payment is already completed');
      await fetchBookingDetails(bookingId, source: source);
      return;
    }

    final clientSecret = _extractClientSecret(body);
    if (clientSecret == null || clientSecret.isEmpty) {
      Get.snackbar('Error', 'Payment client secret not found');
      return;
    }

    bool paid = false;
    try {
      paid = await StripePaymentService.instance.payWithClientSecret(
        clientSecret: clientSecret,
        merchantDisplayName: 'Ayudame',
      );
    } catch (e) {
      Get.snackbar(
        'Payment Error',
        _humanizeError(e, fallback: 'Unable to start Stripe payment'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (paid) {
      Get.snackbar('Success', 'Down payment completed');
      await fetchBookingDetails(bookingId, source: source);
    } else {
      Get.snackbar('Cancelled', 'Payment was cancelled');
    }
  }

  Future<void> _payDueAmount(
    String bookingId,
    String token,
    String source,
  ) async {
    final dueIntentUri = Uri.parse(
      "${ApiService.BASE_URL}${_bookingBasePath(source)}/$bookingId/due/intent",
    );
    _logApiRequest('GET', dueIntentUri);
    final intentRes = await http.get(
      dueIntentUri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    _logApiResponse('GET', dueIntentUri, intentRes);

    if (intentRes.statusCode != 200) {
      final msg = _extractMessage(
        intentRes.body,
        'Due payment is not available',
      );
      if (intentRes.statusCode == 404 ||
          intentRes.statusCode == 400 ||
          intentRes.statusCode == 409) {
        await fetchBookingDetails(bookingId, source: source);
      }
      Get.snackbar(
        'Error',
        msg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final body = _decodeMap(intentRes.body);
    if (body == null) {
      Get.snackbar(
        'Error',
        'Unexpected due payment response from server',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final intentStatus = (body['data']?['status'] ?? '').toString().toLowerCase();
    if (intentStatus == 'succeeded' || intentStatus == 'processing') {
      await _confirmDuePayment(bookingId, token, source);
      return;
    }

    final clientSecret = _extractClientSecret(body);
    if (clientSecret == null || clientSecret.isEmpty) {
      Get.snackbar('Error', 'Due payment client secret not found');
      return;
    }

    bool paid = false;
    try {
      paid = await StripePaymentService.instance.payWithClientSecret(
        clientSecret: clientSecret,
        merchantDisplayName: 'Ayudame',
      );
    } catch (e) {
      Get.snackbar(
        'Payment Error',
        _humanizeError(e, fallback: 'Unable to start Stripe payment'),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!paid) {
      Get.snackbar('Cancelled', 'Payment was cancelled');
      return;
    }

    await _confirmDuePayment(bookingId, token, source);
  }

  Future<void> _confirmDuePayment(
    String bookingId,
    String token,
    String source,
  ) async {
    final dueConfirmUri = Uri.parse(
      "${ApiService.BASE_URL}${_bookingBasePath(source)}/$bookingId/due/confirm",
    );
    _logApiRequest('POST', dueConfirmUri);
    final confirmRes = await http.post(
      dueConfirmUri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    _logApiResponse('POST', dueConfirmUri, confirmRes);

    if (confirmRes.statusCode == 200) {
      Get.snackbar('Success', 'Due payment completed');
      await fetchBookingDetails(bookingId, source: source);
      return;
    }

    final msg = _extractMessage(confirmRes.body, 'Payment confirmation failed');
    if (confirmRes.statusCode == 400 &&
        msg.toLowerCase().contains('not completed')) {
      await fetchBookingDetails(bookingId, source: source);
      Get.snackbar(
        'Processing',
        'Payment is processing. Status will update shortly.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    if (confirmRes.statusCode == 409) {
      await fetchBookingDetails(bookingId, source: source);
      Get.snackbar(
        'Info',
        msg,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    Get.snackbar(
      'Error',
      msg,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
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

  Map<String, dynamic>? _decodeMap(String rawBody) {
    try {
      final dynamic decoded = jsonDecode(rawBody);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    return null;
  }

  String _humanizeError(Object error, {required String fallback}) {
    String message = error.toString().trim();
    if (message.isEmpty) return fallback;

    if (message.startsWith('Exception:')) {
      message = message.replaceFirst('Exception:', '').trim();
    }

    if (message.isEmpty || message.toLowerCase() == 'null') {
      return fallback;
    }

    return message;
  }

  Future<void> submitReview(String id, int rating, String comment) async {
    try {
      isLoading(true);
      final currentBooking = booking.value;
      final String bookingStatus = (currentBooking?.bookingStatus ?? '')
          .toString()
          .toLowerCase();
      final bool alreadyReviewed =
          (currentBooking?.reviewedAt ?? '').toString().trim().isNotEmpty;
      final String trimmedComment = comment.trim();

      if (bookingStatus != 'completed') {
        Get.snackbar(
          'Review Unavailable',
          'You can review only after booking completion.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      if (alreadyReviewed) {
        Get.snackbar(
          'Info',
          'Review already submitted for this booking.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      if (trimmedComment.isEmpty) {
        Get.snackbar(
          'Validation',
          'Please write a short review comment.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final token = await TokenService().getToken();
      if (token == null) return;

      final uri = Uri.parse(
        "${ApiService.BASE_URL}${_bookingBasePath(_activeSource.value)}/$id/review",
      );
      final reqBody = jsonEncode({"rating": rating, "comment": trimmedComment});
      _logApiRequest('POST', uri, body: reqBody);

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: reqBody,
      );
      _logApiResponse('POST', uri, response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back(); // Close dialog
        Get.snackbar(
          'Success',
          'Review submitted successfully',
          backgroundColor: const Color(0xFF1E523F),
          colorText: Colors.white,
        );
        fetchBookingDetails(id, source: _activeSource.value); // Refresh
      } else {
        final body = jsonDecode(response.body);
        Get.snackbar(
          'Error',
          body['message'] ?? 'Failed to submit review',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error submitting review: $e");
      Get.snackbar('Error', 'Something went wrong');
    } finally {
      isLoading(false);
    }
  }

  void showRatingDialog(String bookingId, String providerName) {
    int selectedRating = 5;
    final TextEditingController commentController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(Icons.close, color: Colors.black54),
                    ),
                  ),
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFFE8F5EE),
                    child: Icon(
                      Icons.check,
                      color: Color(0xFF2D6E5C),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Task Completed",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Average Rating and Feedback\n$providerName",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Avg. Rating",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRatingItem(
                        1,
                        "Bad",
                        selectedRating,
                        (val) => setState(() => selectedRating = val),
                      ),
                      _buildRatingItem(
                        2,
                        "Average",
                        selectedRating,
                        (val) => setState(() => selectedRating = val),
                      ),
                      _buildRatingItem(
                        3,
                        "Good",
                        selectedRating,
                        (val) => setState(() => selectedRating = val),
                      ),
                      _buildRatingItem(
                        4,
                        "Great",
                        selectedRating,
                        (val) => setState(() => selectedRating = val),
                      ),
                      _buildRatingItem(
                        5,
                        "Amazing",
                        selectedRating,
                        (val) => setState(() => selectedRating = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Feedback Note",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Type here...",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF1E523F)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => submitReview(
                        bookingId,
                        selectedRating,
                        commentController.text,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E523F),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Done",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRatingItem(
    int value,
    String label,
    int currentRating,
    Function(int) onTap,
  ) {
    bool isSelected = currentRating == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.star,
                size: 40,
                color: isSelected
                    ? const Color(0xFFFF9D5C)
                    : Colors.grey.shade200,
              ),
              Text(
                "$value",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? Colors.black : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
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

  String _bookingBasePath(String source) {
    return _normalizeSource(source) == OrderSource.businessOwner
        ? '/api/business-owner-bookings'
        : '/api/bookings';
  }
}
