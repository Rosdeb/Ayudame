import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:middle_ware/core/theme/app_colors.dart';
import 'package:middle_ware/widgets/custom_appbar.dart';
import '../../../viewmodels/business_auth_viewmodel.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class BusinessTermsConditionScreen extends StatefulWidget {
  const BusinessTermsConditionScreen({super.key});

  @override
  State<BusinessTermsConditionScreen> createState() =>
      _BusinessTermsConditionScreenState();
}

class _BusinessTermsConditionScreenState
    extends State<BusinessTermsConditionScreen> {
  final BusinessAuthViewModel viewModel = Get.find<BusinessAuthViewModel>();

  @override
  void initState() {
    super.initState();
    viewModel.getTermsConditions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: CustomAppBar(
        title: AppTranslations.translateValue('profile.terms_condition'),
      ),
      body: Obx(() {
        if (viewModel.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final terms = viewModel.termsConditions.value;
        if (terms == null) {
          return Center(
            child: Text(
              AppTranslations.translateValue('profile.terms_condition'),
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  terms['title']?.toString() ??
                      AppTranslations.translateValue('legal.terms_title'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  terms['content']?.toString() ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }
}
