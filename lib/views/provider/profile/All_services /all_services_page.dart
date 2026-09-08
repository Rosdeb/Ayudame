import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:middle_ware/core/theme/app_colors.dart';
import 'package:middle_ware/views/provider/profile/All_services%20/edit_service.dart';
import 'package:middle_ware/widgets/custom_appbar.dart';
import 'package:middle_ware/core/localization/app_translations.dart';
import '../../../../controller/provider/profile/all_services_controller.dart';
import '../../../../controller/provider/profile/provider_profile_controller.dart';
import '../../../../models/provider/provider_service_model.dart';

class AllServicesPage extends StatelessWidget {
  AllServicesPage({super.key});

  final AllServicesController controller = Get.put(AllServicesController());
  final ProviderProfileController profileController = Get.isRegistered<ProviderProfileController>() 
      ? Get.find<ProviderProfileController>() 
      : Get.put(ProviderProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: CustomAppBar(
        title: AppTranslations.translateValue("All Services"),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        if (controller.services.isEmpty) {
          return Center(
            child: Text(AppTranslations.translateValue("No services found")),
          );
        }

        return RefreshIndicator(
          color: Colors.green,
          onRefresh: ()=> controller.loadFromCacheAndFetch(),
          backgroundColor: Colors.white,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.services.length,
            itemBuilder: (context, index) {
              final service = controller.services[index];

              bool canEdit = false;
              final myProfile = profileController.providerProfile.value;
              if (myProfile != null) {
                if (service.providerId == myProfile.id || service.providerUserId == myProfile.userId.id) {
                  canEdit = true;
                }
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: Image.network(
                            service.servicePhoto,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 150,
                                width: double.infinity,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: canEdit ? () async {
                              await Get.to(
                                () => const EditServicePage(),
                                arguments: service.toArgs(),
                              );
                              // Refresh list when coming back from Edit page silently
                              controller.fetchServices(background: true);
                            } : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: canEdit ? AppColors.mainAppColor : Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                AppTranslations.translateValue("Edit Service"),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: canEdit ? Colors.white : Colors.white70,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    service.providerProfilePicture != null &&
                                            service.providerProfilePicture!.isNotEmpty
                                        ? NetworkImage(service.providerProfilePicture!)
                                        : const AssetImage("assets/images/emptyUser.png")
                                            as ImageProvider,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      service.providerName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2D2D2D),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            service.providerLocation,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            service.headline,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            service.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 18,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    service.rating.toStringAsFixed(2),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "(${service.totalReviews} reviews)",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              // Price Display
                              _buildPriceDisplay(service),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildPriceDisplay(ProviderService service) {
    if (service.appointmentEnabled && service.appointmentSlots.isNotEmpty) {
      // Get price range from appointment slots
      final prices = service.appointmentSlots
          .whereType<Map>()
          .map((slot) => (slot['price'] ?? 0) as num)
          .toList();

      if (prices.isEmpty) {
        return Text(
          AppTranslations.translateValue("Appointment price: N/A"),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C5F4F),
          ),
        );
      }

      final minPrice = prices.reduce((a, b) => a < b ? a : b);

      return Text(
        AppTranslations.translateValue(
          "Appointment price: \$${minPrice.toStringAsFixed(0)}",
        ),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2C5F4F),
        ),
      );
    } else {
      // Show base price
      return Text(
        AppTranslations.translateValue(
          "Service price: \$${service.basePrice.toStringAsFixed(0)}",
        ),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2C5F4F),
        ),
      );
    }
  }
}
