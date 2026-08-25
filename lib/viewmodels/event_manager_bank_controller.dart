import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:middle_ware/core/localization/app_translations.dart';
import 'package:middle_ware/models/event_bank_model.dart';
import 'package:middle_ware/services/api_service.dart';
import 'package:middle_ware/utils/token_service.dart';

class EventManagerBankController extends GetxController {
  final TextEditingController accountHolderCtrl = TextEditingController();
  final TextEditingController bankNameCtrl = TextEditingController();
  final TextEditingController accountNumberCtrl = TextEditingController();
  final TextEditingController routingNumberCtrl = TextEditingController();

  final RxString accountHolderType = 'Personal'.obs;
  final RxBool isLoading = false.obs;
  final Rxn<EventBankModel> bankInfo = Rxn<EventBankModel>();

  String t(String value) => AppTranslations.translateValue(value);

  @override
  void onInit() {
    super.onInit();
    fetchBankInfo();
  }

  @override
  void onClose() {
    accountHolderCtrl.dispose();
    bankNameCtrl.dispose();
    accountNumberCtrl.dispose();
    routingNumberCtrl.dispose();
    super.onClose();
  }

  Future<void> fetchBankInfo() async {
    isLoading.value = true;
    try {
      final String? token = await TokenService().getToken();
      if (token == null || token.isEmpty) {
        bankInfo.value = null;
        return;
      }

      final Uri url = Uri.parse(
        '${ApiService.BASE_URL}/api/event-managers/bank-information',
      );
      final http.Response response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        bankInfo.value = null;
        return;
      }

      final dynamic decoded = jsonDecode(response.body);
      final dynamic data = decoded is Map<String, dynamic>
          ? decoded['data']
          : null;
      final dynamic rawInfo = data is Map<String, dynamic>
          ? (data['bankInformation'] ?? data['bankInfo'] ?? data)
          : null;

      if (rawInfo is Map<String, dynamic>) {
        bankInfo.value = EventBankModel.fromJson(rawInfo);
        _fillControllers(bankInfo.value!);
      } else {
        bankInfo.value = null;
      }
    } catch (_) {
      bankInfo.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  void _fillControllers(EventBankModel info) {
    accountHolderCtrl.text = info.accountHolderName;
    bankNameCtrl.text = info.bankName;
    accountNumberCtrl.text = info.accountNumber;
    routingNumberCtrl.text = info.routingNumber;
    accountHolderType.value = _normalizeAccountHolderType(
      info.accountHolderType,
    );
  }

  String _normalizeAccountHolderType(String rawType) {
    final String normalized = rawType.trim().toLowerCase();
    if (normalized == 'business') return 'Business';
    return 'Personal';
  }

  void loadBankInfo() {
    if (bankInfo.value != null) {
      _fillControllers(bankInfo.value!);
    } else {
      fetchBankInfo();
    }
  }

  void clearFields() {
    accountHolderCtrl.clear();
    bankNameCtrl.clear();
    accountNumberCtrl.clear();
    routingNumberCtrl.clear();
    accountHolderType.value = 'Personal';
  }

  Future<void> addOrUpdateBank({required bool isEdit}) async {
    final String accountHolderName = accountHolderCtrl.text.trim();
    final String bankName = bankNameCtrl.text.trim();
    final String accountNumber = accountNumberCtrl.text.trim();
    final String routingNumber = routingNumberCtrl.text.trim();

    if (accountHolderName.isEmpty ||
        bankName.isEmpty ||
        accountNumber.isEmpty ||
        routingNumber.isEmpty) {
      Get.snackbar(
        t('common.error'),
        t('common.required'),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final String? token = await TokenService().getToken();
      if (token == null || token.isEmpty) {
        Get.snackbar(
          t('common.error'),
          t('No authentication token'),
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final Uri url = Uri.parse(
        '${ApiService.BASE_URL}/api/event-managers/bank-information',
      );
      final Map<String, dynamic> payload = <String, dynamic>{
        'accountHolderName': accountHolderName,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'routingNumber': routingNumber,
        'accountHolderType': accountHolderType.value,
      };

      final http.Response response = isEdit
          ? await http.put(
              url,
              headers: <String, String>{
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(payload),
            )
          : await http.post(
              url,
              headers: <String, String>{
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(payload),
            );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        Get.snackbar(
          t('common.error'),
          t('Failed to save bank information'),
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final dynamic decoded = jsonDecode(response.body);
      final dynamic data = decoded is Map<String, dynamic>
          ? decoded['data']
          : null;
      final dynamic rawInfo = data is Map<String, dynamic>
          ? (data['bankInformation'] ?? data['bankInfo'] ?? data)
          : null;

      if (rawInfo is Map<String, dynamic>) {
        bankInfo.value = EventBankModel.fromJson(rawInfo);
        _fillControllers(bankInfo.value!);
      } else {
        bankInfo.value = EventBankModel(
          accountHolderName: accountHolderName,
          bankName: bankName,
          accountNumber: accountNumber,
          routingNumber: routingNumber,
          accountHolderType: accountHolderType.value,
        );
      }

      Get.back();
      Get.snackbar(
        t('common.success'),
        t('Bank information saved successfully'),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        t('common.error'),
        t('Failed to save bank information'),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
