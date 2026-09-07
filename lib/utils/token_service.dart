import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../core/routes/app_routes.dart';
import '../services/storage_service.dart';

class TokenService {
  static final TokenService _instance = TokenService._internal();
  factory TokenService() => _instance;
  TokenService._internal();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  SharedPreferences? _prefs;
  Future<String?>? _refreshFuture;

  /// Initialize SharedPreferences before using
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Save Token
  Future<void> saveToken(String token) async {
    await _ensurePrefs();
    await _prefs?.setString(_accessTokenKey, token);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _ensurePrefs();
    await _prefs?.setString(_refreshTokenKey, token);
  }

  /// Save both access and refresh tokens at once
  Future<void> saveSession({
    required String accessToken,
    String? refreshToken,
  }) async {
    await saveToken(accessToken);
    if (refreshToken != null && refreshToken.trim().isNotEmpty) {
      await saveRefreshToken(refreshToken.trim());
    }
  }

  /// Read access token and refresh it if expired/near expiry
  Future<String?> getToken() async {
    await _ensurePrefs();
    final String? accessToken = _prefs?.getString(_accessTokenKey);
    if (accessToken == null || accessToken.isEmpty) {
      return null;
    }

    if (!_shouldRefresh(accessToken)) {
      return accessToken;
    }

    final String? refreshedToken = await _refreshAccessToken();
    
    // Check if token was cleared during refresh (e.g., due to 400/401)
    final String? currentToken = _prefs?.getString(_accessTokenKey);
    if (currentToken == null || currentToken.isEmpty) {
      return null;
    }
    
    return refreshedToken ?? accessToken;
  }

  Future<String?> getRefreshToken() async {
    await _ensurePrefs();
    return _prefs?.getString(_refreshTokenKey);
  }

  bool _shouldRefresh(String accessToken) {
    final int? expirySeconds = _extractExpSeconds(accessToken);
    if (expirySeconds == null) {
      return false;
    }
    final int nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    // Refresh if token expires within next 60 seconds.
    return expirySeconds <= (nowSeconds + 60);
  }

  int? _extractExpSeconds(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;
      final normalizedPayload = base64Url.normalize(parts[1]);
      final payloadMap = jsonDecode(
        utf8.decode(base64Url.decode(normalizedPayload)),
      );
      if (payloadMap is Map<String, dynamic>) {
        final exp = payloadMap['exp'];
        if (exp is int) return exp;
        return int.tryParse(exp?.toString() ?? '');
      }
    } catch (_) {}
    return null;
  }

  Future<String?> _refreshAccessToken() async {
    if (_refreshFuture != null) {
      return _refreshFuture;
    }

    final completer = Completer<String?>();
    _refreshFuture = completer.future;

    try {
      await _ensurePrefs();
      final String refreshToken = (_prefs?.getString(_refreshTokenKey) ?? '')
          .trim();

      if (refreshToken.isEmpty) {
        await clearToken();
        completer.complete(null);
      } else {
        final response = await http.post(
          Uri.parse("${ApiService.BASE_URL}/api/auth/refresh-token"),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'refreshToken': refreshToken}),
        );

        if (response.statusCode == 200) {
          final dynamic decoded = jsonDecode(response.body);
          final Map<String, dynamic> body = decoded is Map<String, dynamic>
              ? decoded
              : <String, dynamic>{};
          final Map<String, dynamic>? data =
              body['data'] is Map<String, dynamic>
              ? body['data'] as Map<String, dynamic>
              : null;

          final String newAccessToken =
              data?['accessToken']?.toString().trim() ??
              body['accessToken']?.toString().trim() ??
              '';
          final String newRefreshToken =
              data?['refreshToken']?.toString().trim() ??
              body['refreshToken']?.toString().trim() ??
              '';

          if (newAccessToken.isNotEmpty) {
            await saveToken(newAccessToken);
            if (newRefreshToken.isNotEmpty) {
              await saveRefreshToken(newRefreshToken);
            }
            completer.complete(newAccessToken);
          } else {
            completer.complete(null);
          }
        } else if (response.statusCode == 400 || response.statusCode == 401) {
          // Refresh token invalid/expired -> clear local session
          await clearToken();
          completer.complete(null);
        } else {
          completer.complete(null);
        }
      }
    } catch (_) {
      completer.complete(null);
    } finally {
      _refreshFuture = null;
    }

    return completer.future;
  }

  /// Delete Token (Logout)
  Future<void> clearToken() async {
    await _ensurePrefs();
    await _prefs?.remove(_accessTokenKey);
    await _prefs?.remove(_refreshTokenKey);
    
    try {
      await StorageService.clearAll();
      Get.offAllNamed(AppRoutes.userTypeSelection);
    } catch (e) {
      print("Navigation error on clearToken: $e");
    }
  }
}
