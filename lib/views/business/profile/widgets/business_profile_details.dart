import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:middle_ware/views/business/profile/edit_buisness_info/edit_business_profile_screen.dart';
import 'package:middle_ware/viewmodels/business_auth_viewmodel.dart';
import 'package:middle_ware/widgets/custom_appbar.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class BusinessProfileViewPage extends StatelessWidget {
  const BusinessProfileViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BusinessAuthViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xffF4F8F5),
      appBar: CustomAppBar(
        //onBackTap: ,
        title: AppTranslations.translateValue("Business Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Get.to(() => const EditBusinessProfileScreen());
            },
          ),
        ],
      ),
      body: Obx(() {
        final business = controller.businessProfile.value;
        final businessName = business?.businessName ?? "Business Name";
        final category = business?.businessType ?? "Category";
        final location = business?.address ?? "Location";
        final about = business?.description ?? "No description provided.";
        final logo = business?.logo;
        final cover = business?.coverPhoto;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: cover != null && cover.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: controller.getImageUrl(cover),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/images/b_cover.png',
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        'assets/images/b_cover.png',
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: 20),
              _infoField(AppTranslations.translateValue("Business name"), businessName),
              _infoField(AppTranslations.translateValue("Business category"), category),
              _infoField(AppTranslations.translateValue("Business location"), location),
              _infoField(AppTranslations.translateValue("About"), about),
              const SizedBox(height: 20),
              Text(
                AppTranslations.translateValue("Business photo"),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: logo != null && logo.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: controller.getImageUrl(logo),
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/images/b_logo.png',
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        'assets/images/b_logo.png',
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _infoField(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
