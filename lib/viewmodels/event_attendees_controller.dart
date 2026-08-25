import 'dart:convert';

import 'package:get/get.dart';
import 'package:middle_ware/models/event_attendee_model.dart';
import 'package:middle_ware/services/api_service.dart';

class EventAttendeesController extends GetxController {
  final attendees = <Attendee>[].obs;
  final isLoading = false.obs;
  final hasNextPage = true.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalBuyers = 0.obs;
  final totalTicketsSold = 0.obs;
  final eventName = ''.obs;
  final errorMessage = ''.obs;

  Future<void> fetchAttendees(
    String eventId, {
    bool isRefresh = false,
  }) async {
    if (eventId.trim().isEmpty) return;
    if (isLoading.value) return;

    if (isRefresh) {
      currentPage.value = 1;
      totalPages.value = 1;
      hasNextPage.value = true;
      attendees.clear();
      errorMessage.value = '';
    } else if (!hasNextPage.value) {
      return;
    }

    try {
      isLoading.value = true;

      final response = await ApiService.get(
        endpoint:
            '/api/event-managers/events/$eventId/attendees?page=${currentPage.value}&limit=20',
        requireAuth: true,
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200 || body['success'] != true) {
        errorMessage.value =
            (body['message'] ?? 'Failed to load attendees').toString();
        return;
      }

      final parsed = EventAttendeeResponse.fromJson(body);
      eventName.value = parsed.data.event.eventName;
      totalBuyers.value = parsed.data.summary.totalBuyers;
      totalTicketsSold.value = parsed.data.summary.totalTicketsSold;
      totalPages.value = parsed.data.pagination.totalPages;

      if (isRefresh) {
        attendees.assignAll(parsed.data.attendees);
      } else {
        attendees.addAll(parsed.data.attendees);
      }

      hasNextPage.value = currentPage.value < totalPages.value;
      if (hasNextPage.value) {
        currentPage.value += 1;
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore(String eventId) async {
    if (isLoading.value || !hasNextPage.value) return;
    await fetchAttendees(eventId, isRefresh: false);
  }
}
