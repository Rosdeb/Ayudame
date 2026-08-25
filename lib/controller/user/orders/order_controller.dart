import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../models/user/orders/order_model.dart';
import '../../../utils/token_service.dart';
import 'package:middle_ware/services/api_service.dart';

class OrderController extends GetxController {
  var isLoading = false.obs;
  var orderList = <OrderModel>[].obs;
  var currentTab = 'Appointment'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders(); // Initial fetch
  }

  void changeTab(String tab) {
    currentTab.value = tab;
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading(true);
      orderList.clear();

      final token = await TokenService().getToken();
      if (token == null) {
        isLoading(false);
        return;
      }

      if (currentTab.value == 'Appointment') {
        final providerAppointments = await _fetchOrderFamily(
          token: token,
          endpoint: '/api/appointments/my-appointments?page=1&limit=50',
          source: OrderSource.provider,
        );

        final businessOwnerAppointments = await _fetchOrderFamily(
          token: token,
          endpoint:
              '/api/business-owner-appointments/my-appointments?page=1&limit=50',
          source: OrderSource.businessOwner,
        );

        final merged = [...providerAppointments, ...businessOwnerAppointments];
        merged.sort((a, b) => _compareByDateDesc(a, b));
        orderList.assignAll(merged);
      } else {
        final providerBookings = await _fetchOrderFamily(
          token: token,
          endpoint: '/api/bookings/my-bookings?page=1&limit=100',
          source: OrderSource.provider,
        );

        final businessOwnerBookings = await _fetchOrderFamily(
          token: token,
          endpoint: '/api/business-owner-bookings/my-bookings?page=1&limit=100',
          source: OrderSource.businessOwner,
        );

        final merged = [...providerBookings, ...businessOwnerBookings];
        final filtered = merged
            .where((order) => _matchesBookingTabStatus(order, currentTab.value))
            .toList();
        filtered.sort((a, b) => _compareByDateDesc(a, b));
        orderList.assignAll(filtered);
      }
    } catch (e) {
      print("Error fetching orders: $e");
      Get.snackbar('Error', 'Something went wrong');
    } finally {
      isLoading(false);
    }
  }

  Future<List<OrderModel>> _fetchOrderFamily({
    required String token,
    required String endpoint,
    required String source,
  }) async {
    try {
      final uri = Uri.parse("${ApiService.BASE_URL}$endpoint");
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Orders API [$source][$endpoint]: ${response.statusCode}");
      print("Orders API Body [$source]: ${response.body}");

      if (response.statusCode != 200) {
        return <OrderModel>[];
      }

      final body = jsonDecode(response.body);
      final List<dynamic> rawData = _extractOrderList(body);
      if (rawData.isEmpty) return <OrderModel>[];

      return rawData
          .whereType<Map>()
          .map(
            (orderJson) => OrderModel.fromJson({
              ...Map<String, dynamic>.from(orderJson),
              'source': source,
            }),
          )
          .toList();
    } catch (e) {
      print("Error fetching order family [$source][$endpoint]: $e");
      return <OrderModel>[];
    }
  }

  List<dynamic> _extractOrderList(dynamic body) {
    if (body is! Map) return <dynamic>[];

    final dynamic rawData = body['data'];
    if (rawData is List) return rawData;

    if (rawData is Map) {
      final dynamic nested =
          rawData['bookings'] ??
          rawData['appointments'] ??
          rawData['items'] ??
          rawData['results'];
      if (nested is List) {
        return nested;
      }
    }

    return <dynamic>[];
  }

  int _compareByDateDesc(OrderModel a, OrderModel b) {
    DateTime? da = _parseDate(a.overallDate);
    DateTime? db = _parseDate(b.overallDate);

    da ??= DateTime.fromMillisecondsSinceEpoch(0);
    db ??= DateTime.fromMillisecondsSinceEpoch(0);

    return db.compareTo(da);
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value);
  }

  bool _matchesBookingTabStatus(OrderModel order, String tab) {
    final String normalized = _normalizeStatus(order.overallStatus);
    switch (tab) {
      case 'Pending':
        return normalized == 'pending';
      case 'Accepted':
        return normalized == 'accepted';
      case 'Confirmed':
        return normalized == 'confirmed' || normalized == 'in_progress';
      case 'Completed':
        return normalized == 'completed';
      case 'Cancelled':
        return normalized == 'cancelled';
      case 'Rejected':
        return normalized == 'rejected';
      default:
        return normalized == 'pending';
    }
  }

  String _normalizeStatus(String status) {
    return status
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_')
        .trim();
  }
}
