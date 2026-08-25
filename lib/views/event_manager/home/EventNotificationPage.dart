
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:middle_ware/core/localization/app_translations.dart';
import '../../../viewmodels/event_manager_notification_controller.dart';
import '../../../models/user/home/notification_model.dart';

class EventNotificationPage extends StatelessWidget {
  EventNotificationPage({super.key});

  final EventManagerNotificationController controller = Get.put(EventManagerNotificationController());
  String t(String value) => AppTranslations.translateValue(value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F4),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            // Notifications List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.notifications.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          t("notifications.no_notifications"),
                          style: TextStyle(color: Colors.grey[500], fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: controller.notifications.length,
                    itemBuilder: (context, index) {
                      final notification = controller.notifications[index];
                      return _buildNotificationItem(context, notification);
                    },
                  ),
                );
              }),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2D6A4F),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          ),
          Expanded(
            child: Text(
              t('profile.notification'),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Obx(() => controller.unreadCount.value > 0
              ? TextButton(
                  onPressed: controller.markAllAsRead,
                  child: Text(
                    t('notifications.mark_all_read'),
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationModel notification) {
    return GestureDetector(
      onTap: () {
        if (!notification.isRead) {
          controller.markAsRead(notification.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead ? Colors.transparent : Colors.green.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon based on type or just a bell
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: notification.isRead ? Colors.grey[100] : Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getNotificationIcon(notification.type),
                size: 20,
                color: notification.isRead ? Colors.grey[600] : const Color(0xFF2D6A4F),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      _buildMoreOptions(context, notification),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(notification.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreOptions(BuildContext context, NotificationModel notification) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'delete') {
          controller.deleteNotification(notification.id);
        } else if (value == 'read' && !notification.isRead) {
          controller.markAsRead(notification.id);
        }
      },
      itemBuilder: (context) => [
        if (!notification.isRead)
          PopupMenuItem(
            value: 'read',
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, size: 18),
                SizedBox(width: 8),
                Text(t('Mark as read')),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete_outline, size: 18, color: Colors.red),
              const SizedBox(width: 8),
              Text(t('common.delete'), style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      child: Icon(Icons.more_vert, size: 18, color: Colors.grey[400]),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'event': return Icons.event;
      case 'payment': return Icons.payments_outlined;
      case 'message': return Icons.message_outlined;
      default: return Icons.notifications_none;
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${t('mins ago')}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${t('hours ago')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${t('days ago')}';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }
}
