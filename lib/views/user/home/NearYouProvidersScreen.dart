import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:middle_ware/widgets/custom_appbar.dart';
import 'package:middle_ware/core/routes/app_routes.dart';
import '../../../controller/user/profile/wishlist_controller.dart';
import '../../../controller/user/home/category_providers_controller.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class NearYouProvidersScreen extends StatefulWidget {
  const NearYouProvidersScreen({Key? key}) : super(key: key);

  @override
  State<NearYouProvidersScreen> createState() => _NearYouProvidersScreenState();
}

class _NearYouProvidersScreenState extends State<NearYouProvidersScreen> {
  final CategoryProvidersController controller = Get.put(
    CategoryProvidersController(),
  );
  String categoryName = "Providers";

  // Helper methods for safe type conversion
  double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }

  String _buildPriceString(dynamic service) {
    try {
      final price = service.price ?? 0;
      final isAppointment = service.appointmentEnabled == true || service.serviceType == 'appointment';
      if (isAppointment) {
        return "Appointment Price: \$${price}";
      } else {
        return "Service Price: \$${price}";
      }
    } catch (e) {
      print('DEBUG: Error building price string: $e');
      return "Price: N/A";
    }
  }

  void _navigateToDetails(dynamic service, dynamic provider) {
    final serviceId = service.serviceId?.toString() ?? service.id?.toString();
    final providerId = provider.providerId?.toString() ?? provider.id?.toString();

    print('DEBUG: Navigating to service details - serviceId: $serviceId, providerId: $providerId');

    if (serviceId != null && serviceId.isNotEmpty) {
      Get.toNamed(
        AppRoutes.providerServiceDetailsScreen,
        arguments: {
          'serviceId': serviceId,
          'providerId': providerId,
        },
      );
    } else {
      Get.snackbar(
        AppTranslations.translateValue("Error"),
        AppTranslations.translateValue("Service ID not available"),
      );
    }
  }


  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    print('DEBUG: NearYouProvidersScreen received arguments: $args');

    if (args != null) {
      if (args['categoryId'] != null) {
        print('DEBUG: Fetching providers for category: ${args['categoryId']}');
        controller.fetchCategoryProviders(args['categoryId']);
      }
      if (args['categoryName'] != null) {
        categoryName = args['categoryName'];
        print('DEBUG: Category name set to: $categoryName');
      }
    } else {
      print('DEBUG: No arguments received');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CustomAppBar(title: categoryName),
      body: Obx(() {
        if (controller.isLoading.value) {
          print('DEBUG: Screen is loading...');
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          print('DEBUG: Error occurred: ${controller.errorMessage.value}');
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final args = Get.arguments;
                      if (args != null && args['categoryId'] != null) {
                        controller.fetchCategoryProviders(args['categoryId']);
                      }
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Debug logging
        print('DEBUG: Providers count: ${controller.providers.length}');
        controller.providers.forEach((provider) {
          print('DEBUG: Provider ${provider.name} has ${provider.services?.length ?? 0} services');
        });

        if (controller.providers.isEmpty) {
          return Center(
            child: Text(
              AppTranslations.translateValue(
                "No providers found in this category",
              ),
            ),
          );
        }

        // Flatten providers and services with proper typing
        final List<Map<String, dynamic>> allServices = [];
        for (var provider in controller.providers) {
          if (provider.services != null && provider.services!.isNotEmpty) {
            for (var service in provider.services!) {
              allServices.add({
                'provider': provider,
                'service': service,
              });
            }
          }
        }

        print('DEBUG: Total services to display: ${allServices.length}');

        if (allServices.isEmpty) {
          return SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      AppTranslations.translateValue("No services available"),
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(20.w),
          itemCount: allServices.length,
          itemBuilder: (context, index) {
            try {
              final item = allServices[index];
              final provider = item['provider'];
              final service = item['service'];

              return ProviderCard(
                imageUrl: service.image?.toString() ?? '',
                profileUrl: provider.profileImage?.toString() ?? '',
                name: provider.name?.toString() ?? "Unknown",
                location: provider.address?.toString() ?? 'Unknown Location',
                postedTime: "${provider.distanceKm?.toString() ?? '0'} km away",
                title: service.title?.toString() ?? 'No Title',
                description: service.description?.toString() ?? 'No description',
                rating: _safeDouble(service.rating),
                reviewCount: _safeInt(service.totalReviews),
                price: _buildPriceString(service),
                showOnlineIndicator: false,
                serviceId: service.serviceId?.toString() ?? service.id?.toString(),
                onViewDetails: () => _navigateToDetails(service, provider),
              );
            } catch (e) {
              print('DEBUG: Error rendering service at index $index: $e');
              return Container(
                padding: EdgeInsets.all(16),
                child: Text('Error loading service: $e'),
              );
            }
          },
        );
      }),
    );
  }
}

class ProviderCard extends StatelessWidget {
  final String imageUrl;
  final String profileUrl;
  final String name;
  final String location;
  final String postedTime;
  final String title;
  final String description;
  final double rating;
  final int reviewCount;
  final String price;
  final bool showOnlineIndicator;
  final VoidCallback onViewDetails;
  final String? serviceId;

  const ProviderCard({
    Key? key,
    required this.imageUrl,
    required this.profileUrl,
    required this.name,
    required this.location,
    required this.postedTime,
    required this.title,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.showOnlineIndicator,
    required this.onViewDetails,
    this.serviceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wishlistController = Get.isRegistered<WishlistController>()
        ? Get.find<WishlistController>()
        : Get.put(WishlistController(), permanent: true);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Obx(() {
                  final isFavorite = wishlistController.isFavorite(serviceId);
                  return GestureDetector(
                    onTap: () {
                      wishlistController.toggleFavorite(serviceId);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: const Color(0xFFFF6B9D),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          // Content section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: ClipOval(
                            child: profileUrl.isNotEmpty
                                ? Image.network(
                                    profileUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.person,
                                          size: 24,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.person, size: 24),
                                  ),
                          ),
                        ),
                        if (showOnlineIndicator)
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF212121),
                                ),
                              ),
                              Text(
                                postedTime,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF4CAF50),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF424242),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: Icon(
                          Icons.star,
                          size: 16,
                          color: index < rating.round()
                              ? const Color(0xFFFFC107)
                              : const Color(0xFFE0E0E0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$rating ($reviewCount)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF212121),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onViewDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E4E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        AppTranslations.translateValue('View Details'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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
}
