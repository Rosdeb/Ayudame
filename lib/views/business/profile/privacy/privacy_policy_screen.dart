import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:middle_ware/core/theme/app_colors.dart';
import '../../../../viewmodels/business_auth_viewmodel.dart';
import '../../../../widgets/custom_appbar.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class BusinessPrivacyPolicyScreen extends StatefulWidget {
  const BusinessPrivacyPolicyScreen({super.key});

  @override
  State<BusinessPrivacyPolicyScreen> createState() =>
      _BusinessPrivacyPolicyScreenState();
}

class _BusinessPrivacyPolicyScreenState
    extends State<BusinessPrivacyPolicyScreen> {
  final BusinessAuthViewModel viewModel = Get.find<BusinessAuthViewModel>();

  @override
  void initState() {
    super.initState();
    viewModel.getPrivacyPolicy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: CustomAppBar(
        title: AppTranslations.translateValue('profile.privacy_policy'),
      ),
      body: Obx(() {
        if (viewModel.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final policy = viewModel.privacyPolicy.value;
        if (policy == null) {
          return Center(
            child: Text(
              AppTranslations.translateValue('profile.privacy_policy'),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                policy['title']?.toString() ??
                    AppTranslations.translateValue(
                      'legal.privacy_policy_title',
                    ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                policy['content']?.toString() ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              // If there are specific sections in the API response, they can be mapped here.
              // For now, mapping the main content.
            ],
          ),
        );
      }),
    );
  }
}
