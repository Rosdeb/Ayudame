import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:middle_ware/core/theme/app_colors.dart';
import 'package:middle_ware/core/localization/app_translations.dart';
import 'package:middle_ware/views/business/profile/business_profile_details.dart';
import 'package:middle_ware/viewmodels/business_auth_viewmodel.dart';

class BusinessProfileCard extends StatelessWidget {
  const BusinessProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BusinessAuthViewModel>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final business = controller.businessProfile.value;
      if (business == null) {
        return Center(
          child: Text(
            AppTranslations.translateValue("Business data not found"),
          ),
        );
      }

      final String businessName = business.businessName ?? AppTranslations.translateValue("Business Name");
      final String email = business.email ?? "";
      final String? logo = business.logo;

      return GestureDetector(
        onTap: () => Get.to(() => const BusinessProfileViewPage()),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFFE3E6F0),
              width: 0.6,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                offset: const Offset(0, 2),
                blurRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              // ----------- Profile Image ----------

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Color(0xFFE3E6F0),
                    width: 0.6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      offset: const Offset(0, 2),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.grey[200],
                      child: ClipOval(
                        child: logo == null || logo.isEmpty || !logo.startsWith('http')
                            ? Image.asset(
                          "assets/images/b_logo.png",
                          width: 50,
                          height: 60,
                          fit: BoxFit.contain,
                        )
                            : CachedNetworkImage(
                          imageUrl: logo,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            "assets/images/b_logo.png",
                            width: 50,
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          businessName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                  ],
                ),
              ),

              const SizedBox(width: 16),


            ],
          ),
        ),
      );
    });
  }
}
