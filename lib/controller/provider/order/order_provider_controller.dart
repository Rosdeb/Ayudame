import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:middle_ware/models/provider/provider_booking_model.dart';
import 'package:middle_ware/models/provider/provider_appointment_model.dart';

import '../../../services/api_service.dart';

class OrderProviderController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var bookingActionInProgressIds = <String>{}.obs;
  var appointmentActionInProgressIds = <String>{}.obs;

  // Lists corresponding to tabs
  var appointmentList = <ProviderAppointment>[].obs;
  var pendingList = <ProviderBooking>[].obs;
  var confirmedList = <ProviderBooking>[].obs;
  var inProgressList = <ProviderBooking>[].obs;
  var completedList = <ProviderBooking>[].obs;
  var cancelledList = <ProviderBooking>[].obs;
  var rejectedList = <ProviderBooking>[].obs;

  var allBookings = <ProviderBooking>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    isLoading(true);
    errorMessage('');
    try {
      await Future.wait([fetchAppointments(), fetchBookings()]);
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchAppointments() async {
    try {
      var response = await ApiService.get(
        endpoint: '/api/providers/appointments',
      );

      if (response.statusCode == 200) {
        var jsonResponse = _decodeMap(response.body) ?? json.decode(response.body);
        var model = ProviderAppointmentModel.fromJson(jsonResponse);
        if (model.data != null && model.data!.isNotEmpty) {
          appointmentList.assignAll(model.data!);
        } else {
          appointmentList.clear();
        }
      } else {
        appointmentList.clear();
        final body = _decodeMap(response.body);
        _appendError(
          _extractMessage(
            body,
            'Failed to fetch appointments (${response.statusCode})',
          ),
        );
      }
    } catch (e) {
      appointmentList.clear();
      _appendError('Error fetching appointments');
    }
  }

  Future<void> fetchBookings() async {
    try {
      var response = await ApiService.get(
        endpoint: '/api/providers/bookings',
      );

      if (response.statusCode == 200) {
        var jsonResponse = _decodeMap(response.body) ?? json.decode(response.body);
        var model = ProviderBookingModel.fromJson(jsonResponse);
        if (model.data != null && model.data!.isNotEmpty) {
          allBookings.assignAll(model.data!);
        } else {
          allBookings.clear();
        }
        filterBookings();
      } else {
        allBookings.clear();
        filterBookings();
        final body = _decodeMap(response.body);
        _appendError(
          _extractMessage(body, 'Failed to fetch bookings (${response.statusCode})'),
        );
      }
    } catch (e) {
      allBookings.clear();
      filterBookings();
      _appendError('Error fetching bookings');
    }
  }

  void filterBookings() {
    pendingList.value = allBookings.where((e) {
      final status = _effectiveStatus(e);
      return status == 'pending';
    }).toList();

    confirmedList.value = allBookings.where((e) {
      final status = _effectiveStatus(e);
      return status == 'accepted' || status == 'confirmed';
    }).toList();

    inProgressList.value = allBookings.where((e) {
      final status = _effectiveStatus(e);
      return status == 'in_progress' || status == 'on_going' || status == 'ongoing';
    }).toList();

    completedList.value = allBookings.where((e) {
      final status = _effectiveStatus(e);
      return status == 'completed';
    }).toList();

    cancelledList.value = allBookings.where((e) {
      final status = _effectiveStatus(e);
      return status == 'cancelled';
    }).toList();

    rejectedList.value = allBookings.where((e) {
      final status = _effectiveStatus(e);
      return status == 'rejected';
    }).toList();
  }

  String _effectiveStatus(ProviderBooking booking) {
    final flowStatus = _normalizeStatus(booking.bookingFlowStatus);
    if (flowStatus.isNotEmpty) {
      return flowStatus;
    }
    return _normalizeStatus(booking.bookingStatus);
  }

  String _normalizeStatus(String? status) {
    return (status ?? '')
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
  }

  bool isBookingActionInProgress(String? bookingId) {
    if (bookingId == null || bookingId.isEmpty) {
      return false;
    }
    return bookingActionInProgressIds.contains(bookingId);
  }

  bool isAppointmentActionInProgress(String? appointmentId) {
    if (appointmentId == null || appointmentId.isEmpty) {
      return false;
    }
    return appointmentActionInProgressIds.contains(appointmentId);
  }

  Future<bool> acceptBooking(String bookingId) => _bookingAction(
    bookingId: bookingId,
    endpoint: '/api/providers/bookings/$bookingId/accept',
    method: 'PATCH',
    fallbackSuccess: 'Booking accepted successfully',
  );

  Future<bool> rejectBooking(String bookingId) => _bookingAction(
    bookingId: bookingId,
    endpoint: '/api/providers/bookings/$bookingId/reject',
    method: 'PATCH',
    fallbackSuccess: 'Booking rejected successfully',
  );

  Future<bool> startBooking(String bookingId) => _bookingAction(
    bookingId: bookingId,
    endpoint: '/api/providers/bookings/$bookingId/start',
    method: 'PATCH',
    fallbackSuccess: 'Booking started successfully',
  );

  Future<bool> completeBooking(String bookingId) => _bookingAction(
    bookingId: bookingId,
    endpoint: '/api/providers/bookings/$bookingId/complete',
    method: 'PATCH',
    fallbackSuccess: 'Booking completed successfully',
  );

  Future<bool> requestDuePayment(String bookingId) => _bookingAction(
    bookingId: bookingId,
    endpoint: '/api/providers/bookings/$bookingId/request-due',
    method: 'POST',
    fallbackSuccess: 'Due payment requested successfully',
  );

  Future<bool> acceptAppointment(
    String appointmentId, {
    String? providerNotes,
  }) =>
      _appointmentAction(
        appointmentId: appointmentId,
        endpoint: '/api/providers/appointments/$appointmentId/accept',
        body: {
          if (providerNotes != null && providerNotes.trim().isNotEmpty)
            'providerNotes': providerNotes.trim(),
        },
        fallbackSuccess: 'Appointment accepted successfully',
      );

  Future<bool> rejectAppointment(
    String appointmentId, {
    String? cancellationReason,
  }) =>
      _appointmentAction(
        appointmentId: appointmentId,
        endpoint: '/api/providers/appointments/$appointmentId/reject',
        body: {
          if (cancellationReason != null &&
              cancellationReason.trim().isNotEmpty)
            'cancellationReason': cancellationReason.trim(),
        },
        fallbackSuccess: 'Appointment rejected successfully',
      );

  Future<bool> rescheduleAppointment(
    String appointmentId, {
    required DateTime appointmentDate,
    required String startTime,
    required String endTime,
    String? providerNotes,
  }) =>
      _appointmentAction(
        appointmentId: appointmentId,
        endpoint: '/api/providers/appointments/$appointmentId/reschedule',
        body: {
          'appointmentDate': appointmentDate.toIso8601String(),
          'timeSlot': {'startTime': startTime, 'endTime': endTime},
          if (providerNotes != null && providerNotes.trim().isNotEmpty)
            'providerNotes': providerNotes.trim(),
        },
        fallbackSuccess: 'Appointment rescheduled successfully',
      );

  Future<bool> startAppointment(String appointmentId) => _appointmentAction(
    appointmentId: appointmentId,
    endpoint: '/api/providers/appointments/$appointmentId/start',
    body: {},
    fallbackSuccess: 'Appointment started',
  );

  Future<bool> completeAppointment(String appointmentId) => _appointmentAction(
    appointmentId: appointmentId,
    endpoint: '/api/providers/appointments/$appointmentId/complete',
    body: {},
    fallbackSuccess: 'Appointment completed successfully',
  );

  Future<bool> markNoShow(String appointmentId) => _appointmentAction(
    appointmentId: appointmentId,
    endpoint: '/api/providers/appointments/$appointmentId/no-show',
    body: {},
    fallbackSuccess: 'Appointment marked as no-show',
  );

  Future<bool> _bookingAction({
    required String bookingId,
    required String endpoint,
    required String method,
    required String fallbackSuccess,
  }) async {
    if (bookingId.isEmpty || bookingActionInProgressIds.contains(bookingId)) {
      return false;
    }

    try {
      bookingActionInProgressIds.add(bookingId);

      late http.Response response;

      if (method == 'POST') {
        response = await ApiService.post(
          endpoint: endpoint,
          body: {},
        );
      } else {
        response = await ApiService.patch(
          endpoint: endpoint,
          body: {},
        );
      }

      final body = _decodeMap(response.body);
      final bool requestOk =
          response.statusCode >= 200 &&
          response.statusCode < 300 &&
          (body?['success'] != false);

      if (requestOk) {
        Get.snackbar('Success', _extractMessage(body, fallbackSuccess));
        await fetchBookings();
        return true;
      }

      Get.snackbar(
        'Error',
        _extractMessage(body, 'Failed to process booking action'),
      );
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to process booking action');
      return false;
    } finally {
      bookingActionInProgressIds.remove(bookingId);
    }
  }

  Future<bool> _appointmentAction({
    required String appointmentId,
    required String endpoint,
    required Map<String, dynamic> body,
    required String fallbackSuccess,
  }) async {
    if (appointmentId.isEmpty ||
        appointmentActionInProgressIds.contains(appointmentId)) {
      return false;
    }

    try {
      appointmentActionInProgressIds.add(appointmentId);

      final response = await ApiService.patch(
        endpoint: endpoint,
        body: body,
      );

      final decodedBody = _decodeMap(response.body);
      final bool requestOk =
          response.statusCode >= 200 &&
          response.statusCode < 300 &&
          (decodedBody?['success'] != false);

      if (requestOk) {
        Get.snackbar('Success', _extractMessage(decodedBody, fallbackSuccess));
        await fetchAppointments();
        return true;
      }

      Get.snackbar(
        'Error',
        _extractMessage(decodedBody, 'Failed to process appointment action'),
      );
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to process appointment action');
      return false;
    } finally {
      appointmentActionInProgressIds.remove(appointmentId);
    }
  }

  Map<String, dynamic>? _decodeMap(String rawBody) {
    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    return null;
  }

  String _extractMessage(Map<String, dynamic>? body, String fallback) {
    final message = body?['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }
    return fallback;
  }

  void _appendError(String message) {
    final text = message.trim();
    if (text.isEmpty) return;

    if (errorMessage.value.isEmpty) {
      errorMessage.value = text;
      return;
    }

    if (!errorMessage.value.contains(text)) {
      errorMessage.value = '${errorMessage.value}\n$text';
    }
  }
}
