import 'dart:convert';

import 'package:get/get.dart';
import 'package:middle_ware/models/user/home/notification_model.dart';
import 'package:middle_ware/services/api_service.dart';

class EventManagerNotificationController extends GetxController {
  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;
  final unreadCount = 0.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final hasNextPage = true.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications({bool refresh = true}) async {
    if (isLoading.value) return;

    if (refresh) {
      currentPage.value = 1;
      totalPages.value = 1;
      hasNextPage.value = true;
      notifications.clear();
      errorMessage.value = '';
    } else if (!hasNextPage.value) {
      return;
    }

    try {
      isLoading.value = true;

      final response = await ApiService.get(
        endpoint:
            '/api/event-managers/notifications?page=${currentPage.value}&limit=20',
        requireAuth: true,
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200 || body['success'] != true) {
        errorMessage.value =
            (body['message'] ?? 'Failed to load notifications').toString();
        return;
      }

      final payload = (body['data'] as Map<String, dynamic>?) ?? {};
      final rawList = (payload['notifications'] as List?) ?? const [];

      final pageItems = rawList
          .whereType<Map>()
          .map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      unreadCount.value = _toInt(payload['unreadCount']);
      totalPages.value = _toInt(payload['totalPages'], fallback: 1);

      if (refresh) {
        notifications.assignAll(pageItems);
      } else {
        notifications.addAll(pageItems);
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

  Future<void> markAsRead(String notificationId) async {
    if (notificationId.trim().isEmpty) return;
    try {
      final response = await ApiService.patch(
        endpoint: '/api/event-managers/notifications/$notificationId/read',
        body: const {},
        requireAuth: true,
      );
      if (response.statusCode == 200) {
        final index =
            notifications.indexWhere((notification) => notification.id == notificationId);
        if (index != -1 && notifications[index].isRead == false) {
          final old = notifications[index];
          notifications[index] = NotificationModel(
            id: old.id,
            userId: old.userId,
            title: old.title,
            body: old.body,
            type: old.type,
            isRead: true,
            createdAt: old.createdAt,
          );
          if (unreadCount.value > 0) {
            unreadCount.value -= 1;
          }
        }
      }
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await ApiService.patch(
        endpoint: '/api/event-managers/notifications/read-all',
        body: const {},
        requireAuth: true,
      );

      if (response.statusCode == 200) {
        final updated = notifications.map((old) {
          return NotificationModel(
            id: old.id,
            userId: old.userId,
            title: old.title,
            body: old.body,
            type: old.type,
            isRead: true,
            createdAt: old.createdAt,
          );
        }).toList();
        notifications.assignAll(updated);
        unreadCount.value = 0;
      }
    } catch (_) {}
  }

  Future<void> deleteNotification(String notificationId) async {
    if (notificationId.trim().isEmpty) return;
    try {
      NotificationModel? existing;
      for (final notification in notifications) {
        if (notification.id == notificationId) {
          existing = notification;
          break;
        }
      }
      final response = await ApiService.delete(
        endpoint: '/api/event-managers/notifications/$notificationId',
        requireAuth: true,
      );
      if (response.statusCode == 200) {
        notifications.removeWhere(
          (notification) => notification.id == notificationId,
        );
        if (existing != null && !existing.isRead && unreadCount.value > 0) {
          unreadCount.value -= 1;
        }
      }
    } catch (_) {}
  }

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }
}
