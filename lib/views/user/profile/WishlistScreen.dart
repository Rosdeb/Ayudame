import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:middle_ware/views/components/custom_app_bar.dart';
import '../../../controller/user/profile/wishlist_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../models/user/profile/wishlist_model.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WishlistController());

    return Scaffold(
      backgroundColor: Color(0xFFF3F8F4),
      appBar: CustomAppBar(title: AppTranslations.translateValue("Favorites")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: controller.fetchWishlist,
                  child: Text(AppTranslations.translateValue("Retry")),
                ),
              ],
            ),
          );
        }

        if (controller.items.isEmpty) {
          return Center(
            child: Text(AppTranslations.translateValue("No favorites found.")),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.items.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildWishlistCard(controller.items[index]),
            );
          },
        );
      }),
    );
  }

  Widget _buildWishlistCard(WishlistItem item) {
    final controller = Get.find<WishlistController>();
    final service = item.service;
    final imageUrl = service?.servicePhoto ?? '';
    final title = service?.headline ?? 'Service';
    final categoryName = service?.category?.name ?? 'Category';
    final description = service?.description ?? 'No description available.';
    final rating = (service?.rating ?? 0).toDouble();
    final reviews = service?.totalReviews ?? 0;
    final price = (service?.basePrice ?? 0).toDouble();
    final appointmentEnabled = service?.appointmentEnabled == true;
    final filledStars = rating.round().clamp(0, 5);

    final priceLabel = appointmentEnabled
        ? "Appointment Price: \$${price.toStringAsFixed(0)}"
        : "Service Price: \$${price.toStringAsFixed(0)}";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with close button
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      controller.removeFavorite(service?.serviceId);
                    },
                    icon: const Icon(Icons.close, size: 20),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile and Name
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : null,
                      backgroundColor: Colors.grey[200],
                      child: imageUrl.isEmpty
                          ? const Icon(
                              Icons.image,
                              size: 18,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            categoryName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 12),

                // Rating
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (index) => Icon(
                        index < filledStars ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$rating ($reviews)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Price and Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      priceLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (service?.serviceId == null) {
                          Get.snackbar(
                            AppTranslations.translateValue("Error"),
                            AppTranslations.translateValue(
                              "Service ID not available",
                            ),
                          );
                          return;
                        }

                        Get.toNamed(
                          AppRoutes.providerServiceDetailsScreen,
                          arguments: {
                            'serviceId': service!.serviceId,
                            'providerId': service.providerId,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D5F4C),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppTranslations.translateValue('View Details'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 180,
      color: Colors.grey[200],
      child: const Icon(Icons.image, size: 50, color: Colors.grey),
    );
  }
}
