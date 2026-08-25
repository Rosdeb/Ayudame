import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:middle_ware/models/business_booking_model.dart';
import 'package:middle_ware/services/api_service.dart';

class BusinessBookingService {
  Future<List<BusinessBookingModel>> getBookings() async {
    try {
      final response = await ApiService.get(
        endpoint: '/api/business-owners/bookings',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> bookingsJson =
            data['data'] ?? data['bookings'] ?? [];
        return bookingsJson
            .map((json) => BusinessBookingModel.fromJson(json))
            .toList();
      }

      debugPrint('Failed to fetch bookings: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('Error in getBookings: $e');
      return [];
    }
  }

  Future<BusinessBookingModel?> getBookingById(String bookingId) async {
    try {
      final response = await ApiService.get(
        endpoint: '/api/business-owners/bookings/$bookingId',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final bookingJson = data['data'] ?? data['booking'] ?? data;
        return BusinessBookingModel.fromJson(bookingJson);
      }

      debugPrint('Failed to fetch booking detail: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Error in getBookingById: $e');
      return null;
    }
  }

  Future<String?> acceptBooking(String bookingId) async {
    return _patchAction(
      endpoint: '/api/business-owners/bookings/$bookingId/accept',
      fallbackError: 'Failed to accept booking',
    );
  }

  Future<String?> rejectBooking(String bookingId) async {
    return _patchAction(
      endpoint: '/api/business-owners/bookings/$bookingId/reject',
      fallbackError: 'Failed to reject booking',
    );
  }

  Future<String?> startBooking(String bookingId) async {
    return _patchAction(
      endpoint: '/api/business-owners/bookings/$bookingId/start',
      fallbackError: 'Failed to start booking',
    );
  }

  Future<String?> completeBooking(String bookingId) async {
    return _patchAction(
      endpoint: '/api/business-owners/bookings/$bookingId/complete',
      fallbackError: 'Failed to complete booking',
    );
  }

  Future<String?> requestDuePayment(String bookingId) async {
    return _postAction(
      endpoint: '/api/business-owners/bookings/$bookingId/request-due',
      fallbackError: 'Failed to request due payment',
    );
  }

  Future<String?> _patchAction({
    required String endpoint,
    required String fallbackError,
  }) async {
    try {
      final response = await ApiService.patch(
        endpoint: endpoint,
        body: {},
        requireAuth: true,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return null;
      }

      return _extractMessage(response.body, fallbackError);
    } catch (e) {
      return 'Network error: $e';
    }
  }

  Future<String?> _postAction({
    required String endpoint,
    required String fallbackError,
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: endpoint,
        body: {},
        requireAuth: true,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return null;
      }

      return _extractMessage(response.body, fallbackError);
    } catch (e) {
      return 'Network error: $e';
    }
  }

  String _extractMessage(String rawBody, String fallback) {
    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map) {
        final message = decoded['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
    } catch (_) {}
    return fallback;
  }
}
