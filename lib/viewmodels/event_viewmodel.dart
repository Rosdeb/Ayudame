import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:middle_ware/models/event_model.dart';
import 'package:middle_ware/services/event_manager_service.dart';

class EventViewModel extends GetxController {
  final EventManagerService _eventService = EventManagerService();

  final isLoading = false.obs;
  final events = <EventModel>[].obs;
  final selectedEvent = Rxn<EventModel>();
  final stats = <String, dynamic>{}.obs;

  final currentPage = 1.obs;
  final hasNextPage = true.obs;
  final currentStatus = 'all'.obs;

  final salesOverview = <String, dynamic>{
    'totalRevenue': 0.0,
    'totalTicketsSold': 0,
    'totalSalesCount': 0,
  }.obs;
  final salesPeriod = 'monthly'.obs;
  final salesMonth = DateTime.now().month.obs;
  final salesYear = DateTime.now().year.obs;

  void _handleError(dynamic e) {
    final errorMsg = e.toString().replaceAll('Exception: ', '');
    if (errorMsg.toLowerCase().contains('token') &&
        (errorMsg.toLowerCase().contains('expired') ||
            errorMsg.toLowerCase().contains('expaired') ||
            errorMsg.toLowerCase().contains('unauthorized'))) {
      Get.snackbar(
        'Session Expired',
        'Please login again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Get.offAllNamed('../event-login');
      return;
    }

    Get.snackbar(
      'Error',
      errorMsg,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  Future<void> createEvent({
    required Map<String, dynamic> fields,
    String? imagePath,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    try {
      isLoading.value = true;
      final response = await _eventService.createEvent(fields, imagePath);
      Get.snackbar(
        'Success',
        response['message']?.toString() ?? 'Event created successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      onSuccess();
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        errorMsg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      onError(errorMsg);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchEvents({
    String status = 'all',
    bool refresh = false,
  }) async {
    if (refresh) {
      currentPage.value = 1;
      events.clear();
      hasNextPage.value = true;
    }
    if (!hasNextPage.value) return;

    try {
      isLoading.value = true;
      final response = await _eventService.getEvents(
        page: currentPage.value,
        limit: 10,
        status: status,
      );

      final data = (response['data'] as Map<String, dynamic>?) ?? {};
      final eventList = (data['events'] as List?) ?? const [];
      final pagination = (data['pagination'] as Map<String, dynamic>?) ?? {};

      final newEvents = eventList
          .whereType<Map>()
          .map((e) => EventModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      if (refresh) {
        events.assignAll(newEvents);
      } else {
        events.addAll(newEvents);
      }

      final int totalPages =
          int.tryParse((pagination['totalPages'] ?? 1).toString()) ?? 1;
      final int current =
          int.tryParse((pagination['currentPage'] ?? currentPage.value).toString()) ??
              currentPage.value;

      hasNextPage.value = current < totalPages;
      currentPage.value = current + 1;
      currentStatus.value = status;
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchEventDetails(String eventId) async {
    try {
      isLoading.value = true;
      final response = await _eventService.getEventById(eventId);
      final data = (response['data'] as Map<String, dynamic>?) ?? {};
      final eventData = data['event'] ?? data;
      if (eventData is Map<String, dynamic>) {
        selectedEvent.value = EventModel.fromJson(eventData);
      } else if (eventData is Map) {
        selectedEvent.value =
            EventModel.fromJson(Map<String, dynamic>.from(eventData));
      }
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateEvent(
    String eventId,
    Map<String, dynamic> fields,
    String? imagePath, {
    VoidCallback? onSuccess,
  }) async {
    try {
      isLoading.value = true;
      await _eventService.updateEvent(eventId, fields, imagePath);
      Get.snackbar(
        'Success',
        'Event updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      if (onSuccess != null) {
        onSuccess();
      } else {
        await fetchEventDetails(eventId);
      }
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> publishEvent(String eventId) async {
    try {
      isLoading.value = true;
      await _eventService.publishEvent(eventId);
      Get.snackbar(
        'Success',
        'Event published successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      if (selectedEvent.value?.id == eventId) {
        selectedEvent.value?.status = 'published';
        selectedEvent.refresh();
      }

      final index = events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        events[index].status = 'published';
        events.refresh();
      }

      await fetchStats();
      await fetchSalesOverview(
        period: salesPeriod.value,
        month: salesPeriod.value == 'monthly' ? salesMonth.value : null,
        year: salesPeriod.value == 'monthly' ? salesYear.value : null,
      );
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelEvent(String eventId, String reason) async {
    try {
      isLoading.value = true;
      await _eventService.cancelEvent(eventId, reason);
      Get.snackbar(
        'Success',
        'Event cancelled',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      if (selectedEvent.value?.id == eventId) {
        selectedEvent.value?.status = 'cancelled';
        selectedEvent.refresh();
      }

      events.removeWhere((e) => e.id == eventId);
      events.refresh();

      await fetchStats();
      await fetchSalesOverview(
        period: salesPeriod.value,
        month: salesPeriod.value == 'monthly' ? salesMonth.value : null,
        year: salesPeriod.value == 'monthly' ? salesYear.value : null,
      );
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStats() async {
    try {
      final response = await _eventService.getStats();
      final data = (response['data'] as Map<String, dynamic>?) ?? {};
      final statsData = data['stats'] ?? data;
      if (statsData is Map<String, dynamic>) {
        stats.value = statsData;
      } else if (statsData is Map) {
        stats.value = Map<String, dynamic>.from(statsData);
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> fetchSalesOverview({
    String period = 'monthly',
    int? month,
    int? year,
  }) async {
    try {
      final now = DateTime.now();
      final safePeriod = period == 'all_time' ? 'all_time' : 'monthly';
      final effectiveMonth = month ?? salesMonth.value;
      final effectiveYear = year ?? salesYear.value;

      final response = await _eventService.getSalesOverview(
        period: safePeriod,
        month: safePeriod == 'monthly' ? effectiveMonth : null,
        year: safePeriod == 'monthly' ? effectiveYear : null,
        monthOffset: 0,
      );

      final data = (response['data'] as Map<String, dynamic>?) ?? {};
      final overview = (data['overview'] as Map<String, dynamic>?) ?? {};

      salesPeriod.value = safePeriod;
      if (safePeriod == 'monthly') {
        salesMonth.value =
            int.tryParse((data['month'] ?? effectiveMonth).toString()) ??
                now.month;
        salesYear.value =
            int.tryParse((data['year'] ?? effectiveYear).toString()) ??
                now.year;
      }

      salesOverview.value = {
        'totalRevenue':
            double.tryParse((overview['totalRevenue'] ?? 0).toString()) ?? 0.0,
        'totalTicketsSold':
            int.tryParse((overview['totalTicketsSold'] ?? 0).toString()) ?? 0,
        'totalSalesCount':
            int.tryParse((overview['totalSalesCount'] ?? 0).toString()) ?? 0,
      };
    } catch (e) {
      _handleError(e);
    }
  }
}
