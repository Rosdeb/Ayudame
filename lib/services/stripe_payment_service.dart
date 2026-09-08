import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import 'api_service.dart';

class StripePaymentService {
  StripePaymentService._internal();

  static final StripePaymentService instance = StripePaymentService._internal();

  bool _isConfigured = false;
  String _merchantCountryCode = 'US';
  bool _isTestMode = true;

  Future<void> _configure() async {
    if (_isConfigured) return;

    final response = await http.get(
      Uri.parse('${ApiService.BASE_URL}/api/payments/config'),
      headers: const {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to load payment configuration');
    }

    final body = jsonDecode(response.body);
    final success = body['success'] == true;
    final data = body['data'] as Map<String, dynamic>?;

    if (!success || data == null) {
      throw Exception(body['message'] ?? 'Invalid payment configuration');
    }

    final publishableKey = (data['publishableKey'] ?? '').toString().trim();
    if (publishableKey.isEmpty) {
      throw Exception('Stripe publishable key is missing');
    }

    _merchantCountryCode =
        (data['merchantCountryCode'] ?? 'US').toString().toUpperCase();
    _isTestMode = data['isTestMode'] != false;

    Stripe.publishableKey = publishableKey;
    Stripe.merchantIdentifier = (data['merchantIdentifier'] ?? 'merchant.com.ayudame').toString();
    await Stripe.instance.applySettings();
    _isConfigured = true;
  }

  Future<bool> payWithClientSecret({
    required String clientSecret,
    String merchantDisplayName = 'Ayudame',
  }) async {
    if (kIsWeb) {
      throw Exception('Payment is not supported on web');
    }

    if (clientSecret.trim().isEmpty) {
      throw Exception('Payment client secret is missing');
    }

    await _configure();

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: merchantDisplayName,
          style: ThemeMode.light,
          allowsDelayedPaymentMethods: false,
          googlePay: defaultTargetPlatform == TargetPlatform.android
              ? PaymentSheetGooglePay(
                  merchantCountryCode: _merchantCountryCode,
                  testEnv: _isTestMode,
                )
              : null,
          applePay: defaultTargetPlatform == TargetPlatform.iOS
              ? PaymentSheetApplePay(
                  merchantCountryCode: _merchantCountryCode,
                )
              : null,
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return false;
      }
      throw Exception(e.error.localizedMessage ?? 'Payment failed');
    }
  }
}
