import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:middle_ware/widgets/custom_appbar.dart';
import 'package:middle_ware/core/localization/app_translations.dart';
import 'package:middle_ware/controller/user/home/notification_controller.dart';

class ProviderNotificationPage extends StatelessWidget {
  const ProviderNotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inject the notification controller
    final NotificationController controller = Get.put(NotificationController());

    return Scaffold(
      appBar: CustomAppBar(
        title: AppTranslations.translateValue("Notifications"),
      ),
      body: SafeArea(
        child: Container(
          color: const Color(0xFFF3F8F4),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF1E5631),
                ),
              );
            }

            if (controller.errorMessage.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.errorMessage.value,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => controller.fetchNotifications(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E5631),
                      ),
                      child: Text(
                        AppTranslations.translateValue("Retry"),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (controller.notificationList.isEmpty) {
              return Center(
                child: Text(
                  AppTranslations.translateValue("No notifications found"),
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.fetchNotifications(),
              color: const Color(0xFF1E5631),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: controller.notificationList.length,
                itemBuilder: (context, index) {
                  final notification = controller.notificationList[index];
                  
                  // Helper variables
                  final avatarUrl = 'https://ui-avatars.com/api/?name=Notification&background=random';
                  final title = notification.title.isNotEmpty ? notification.title : 'New Notification';
                  final message = notification.body;
                  
                  // Simple time formatting
                  final duration = DateTime.now().difference(notification.createdAt);
                  String time = '';
                  if (duration.inDays > 0) {
                    time = '${duration.inDays} days ago';
                  } else if (duration.inHours > 0) {
                    time = '${duration.inHours} hours ago';
                  } else if (duration.inMinutes > 0) {
                    time = '${duration.inMinutes} minutes ago';
                  } else {
                    time = 'Just now';
                  }

                  return _buildNotificationItem(
                    avatarUrl,
                    title,
                    message,
                    time,
                    notification.id,
                    controller,
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    String avatarUrl,
    String title,
    String message,
    String time,
    String id,
    NotificationController controller,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage(avatarUrl),
            backgroundColor: Colors.grey[300],
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        // Options menu like Delete
                        Get.bottomSheet(
                          Container(
                            color: Colors.white,
                            child: SafeArea(
                              child: Wrap(
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.delete, color: Colors.red),
                                    title: Text(
                                      AppTranslations.translateValue('Delete Notification'),
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                    onTap: () {
                                      Get.back();
                                      controller.deleteNotification(id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      child: Icon(Icons.more_vert, size: 18, color: Colors.grey[400]),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
