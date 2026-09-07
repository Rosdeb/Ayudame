import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/token_service.dart';
import '../routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!TokenService().hasValidSessionSync()) {
      debugPrint("🔒 AuthMiddleware: Access Denied to $route. Redirecting to Login.");
      return const RouteSettings(name: AppRoutes.userTypeSelection);
    }
    return null; // allow access
  }
}
