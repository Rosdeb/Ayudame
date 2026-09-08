import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:middle_ware/services/api_service.dart';
import 'package:middle_ware/services/storage_service.dart';
import 'package:middle_ware/utils/token_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:middle_ware/core/routes/app_routes.dart';
import 'local_notifications_service.dart';


class FirebaseMessagingService {
  FirebaseMessagingService._internal();

  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();


  factory FirebaseMessagingService.instance() => _instance;

  LocalNotificationsService? _localNotificationsService;

  Future<void> init({required LocalNotificationsService localNotificationsService}) async {
    _localNotificationsService = localNotificationsService;

    _handlePushNotificationsToken();

    _requestPermission();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Check for initial message that opened the app from terminated state
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage);
    }
  }

  /// Retrieves and manages the FCM token for push notifications
  Future<void> _handlePushNotificationsToken() async {
    // Get the FCM token for the device
    final token = await FirebaseMessaging.instance.getToken();
    print('Push notifications token: $token');

    if (token != null) {
      _sendTokenToServer(token);
    }

    // Listen for token refresh events
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      print('FCM token refreshed: $fcmToken');
      _sendTokenToServer(fcmToken);
    }).onError((error) {
      // Handle errors during token refresh
      print('Error refreshing FCM token: $error');
    });
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      final authToken = await TokenService().getToken();
      if (authToken == null) return;

      final url = Uri.parse("${ApiService.BASE_URL}/api/notifications/token");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'token': token,
          'platform': Platform.isIOS ? 'ios' : 'android'
        }),
      );

      print("Token Sync Status: ${response.statusCode} - ${response.body}");
    } catch (e) {
      print("Error sending FCM token to server: $e");
    }
  }

  /// Removes the device token on logout
  Future<void> removeTokenOnLogout() async {
    try {
      final authToken = await TokenService().getToken();
      if (authToken == null) return;

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      final url = Uri.parse("${ApiService.BASE_URL}/api/notifications/token");

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'token': token}),
      );

      print("Token Remove Status: ${response.statusCode}");
    } catch (e) {
      print("Error removing FCM token: $e");
    }
  }

  /// Requests notification permission from the user
  Future<void> _requestPermission() async {
    // Request permission for alerts, badges, and sounds
    final result = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Log the user's permission decision
    print('User granted permission: ${result.authorizationStatus}');
  }

  /// Handles messages received while the app is in the foreground
  void _onForegroundMessage(RemoteMessage message) {
    print('Foreground message received: ${message.data.toString()}');
    final notificationData = message.notification;
    if (notificationData != null) {
      // Display a local notification using the service
      _localNotificationsService?.showNotification(
          notificationData.title ?? '', notificationData.body ?? '', jsonEncode(message.data)
        );
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    print('Notification caused the app to open: ${message.data.toString()}');
    _handleDeepLink(message.data);
  }
  
  void _handleDeepLink(Map<String, dynamic> data) async {
    try {
      if (data.isEmpty) return;
      
      final type = data['type']?.toString();
      final entityId = data['entityId']?.toString() ?? 
                       data['bookingId']?.toString() ?? 
                       data['appointmentId']?.toString() ?? 
                       data['eventId']?.toString();
      
      final role = await StorageService.getUserRole();

      // Determine route based on type
      if (type != null) {
        if (type.startsWith('booking') || type == 'business_owner_booking_payment' || type == 'booking_payment') {
          // If we had a specific detail screen we would pass entityId:
          // Get.toNamed(AppRoutes.userOrderDetails, arguments: {'id': entityId});
          if (role == 'business') {
            Get.toNamed(AppRoutes.businessOrders);
          } else if (role == 'provider') {
            Get.toNamed(AppRoutes.providerOrders);
          } else {
            Get.toNamed(AppRoutes.userBooking);
          }
        } else if (type.startsWith('appointment') || type == 'business_owner_appointment_payment' || type == 'appointment_payment') {
          if (role == 'business') {
            Get.toNamed(AppRoutes.businessOrders);
          } else if (role == 'provider') {
            Get.toNamed(AppRoutes.providerOrders);
          } else {
            Get.toNamed(AppRoutes.userAppointment);
          }
        } else if (type == 'event_ticket_sold') {
          if (role == 'event_manager') {
            Get.toNamed(AppRoutes.eventHome); // Navigate to event home or event orders
          }
        } else {
          // General notifications
          if (role == 'business') {
            Get.toNamed(AppRoutes.notifications); // Business notification page
          } else {
            Get.toNamed(AppRoutes.userNotification); // User notification page
          }
        }
      }
    } catch (e) {
      print("Deep link error: $e");
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.data.toString()}');
}