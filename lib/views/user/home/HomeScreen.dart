import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:middle_ware/views/user/categories/widgets/custom_provider_card.dart';
import 'package:middle_ware/views/user/home/widgets/custom_bussiness_card.dart';
import 'package:middle_ware/views/user/home/widgets/custom_events_card.dart';
import 'package:middle_ware/views/user/home/widgets/custom_featured_provider_card.dart';
import 'package:middle_ware/views/user/home/widgets/custom_top_businesses_card.dart';
import 'package:middle_ware/views/user/profile/my_events.dart';
import '../../../controller/user/home/event_controller.dart';
import '../../../controller/user/home/home_search_controller.dart';
import '../../../controller/user/home/nearby_providers_controller.dart';
import '../../../controller/user/home/recent_providers_controller.dart';
import '../../../controller/user/home/featured_providers_controller.dart';
import '../../../controller/user/home/top_businesses_controller.dart';
import '../../../controller/user/profile/profile_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user/home/home_search_model.dart';
import 'UserNotificationPage.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProfileController profileController = Get.put(ProfileController());
  final EventController eventController = Get.put(EventController());
  final RecentProviderController recentController = Get.put(
    RecentProviderController(),
  );
  final NearbyProvidersController nearbyController = Get.put(
    NearbyProvidersController(),
  );
  final TopBusinessesController topBusinessesController = Get.put(
    TopBusinessesController(),
  );
  final FeaturedProvidersController featuredProvidersController = Get.put(
    FeaturedProvidersController(),
  );
  final HomeSearchController homeSearchController = Get.put(
    HomeSearchController(),
  );
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor1,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header Section
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF2D6A4F),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 15.h,
              bottom: 16.h,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Profile Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoutes.userProfile);
                        },
                        child: Row(
                          children: [
                            Obx(() {
                              final user = profileController.user.value;
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 30.r,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage:
                                      (user?.profilePicture != null &&
                                          user!.profilePicture!.isNotEmpty)
                                      ? NetworkImage(user.profilePicture!)
                                      : null,
                                  child:
                                      (user?.profilePicture == null ||
                                          user!.profilePicture!.isEmpty)
                                      ? Icon(
                                          Icons.person,
                                          color: Colors.grey,
                                          size: 30.r,
                                        )
                                      : null,
                                ),
                              );
                            }),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppTranslations.translateValue(
                                    'home.welcome_back',
                                  ),
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Obx(() {
                                  final user = profileController.user.value;
                                  return Text(
                                    user?.fullName ??
                                        AppTranslations.translateValue(
                                          'home.user_name',
                                        ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => userNotificationPage());
                        },
                        child: SvgPicture.asset(
                          "assets/icons/NotificationIcon.svg",
                          width: 34.w,
                          height: 34.h,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: homeSearchController.searchServices,
                      onSubmitted: homeSearchController.searchServices,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: AppTranslations.translateValue(
                          'home.search_hint',
                        ),
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey[400],
                          size: 28,
                        ),
                        suffixIcon: Obx(
                          () => homeSearchController.isSearchActive.value
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    homeSearchController.clearSearch();
                                    FocusScope.of(context).unfocus();
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.grey[500],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Content Section
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),
                        _buildSearchResultsSection(),

                        /// ---------------------------- Recent provider section ------------------------------
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppTranslations.translateValue(
                                "home.recent_providers",
                              ),
                              style: GoogleFonts.inter(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            InkWell(
                              onTap: () {},
                              child: Text(
                                AppTranslations.translateValue(
                                  "common.view_all",
                                ),
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.mainAppColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),

                        SizedBox(
                          height: 400.h,
                          child: Obx(() {
                            if (recentController.isLoading.value) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (recentController.errorMessage.isNotEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.w,
                                      ),
                                      child: Text(
                                        recentController.errorMessage.value,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    ElevatedButton(
                                      onPressed: () => recentController
                                          .fetchRecentProviders(),
                                      child: Text(
                                        AppTranslations.translateValue("Retry"),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            if (recentController.providerList.isEmpty) {
                              return Center(
                                child: Text(
                                  AppTranslations.translateValue(
                                    "home.no_recent_providers",
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.zero,
                              itemCount: recentController.providerList.length,
                              itemBuilder: (context, index) {
                                final provider =
                                    recentController.providerList[index];

                                return Padding(
                                  padding: EdgeInsets.only(right: 8.w),
                                  child: SizedBox(
                                    width: 320.w,
                                    child: CustomProviderCard(
                                      providerName: provider.fullName,
                                      location: provider.location.address,
                                      activeStatus: provider.isAvailable
                                          ? AppTranslations.translateValue(
                                              "common.available",
                                            )
                                          : AppTranslations.translateValue(
                                              "common.unavailable",
                                            ),
                                      serviceTitle:
                                          provider.lastService.service.name,
                                      serviceDescription: provider
                                          .lastService
                                          .service
                                          .description,
                                      reviews:
                                          "${provider.rating} (${provider.totalReviews})",
                                      appointmentPrice:
                                          provider.lastService.type ==
                                              'appointment'
                                          ? provider
                                                .lastService
                                                .service
                                                .basePrice
                                                .toDouble()
                                          : null,
                                      servicePrice: provider
                                          .lastService
                                          .service
                                          .basePrice
                                          .toDouble(),
                                      serviceImage:
                                          provider.lastService.service.photo,
                                      providerImage: provider.profilePicture,
                                      serviceId:
                                          provider.lastService.service.id,
                                      providerId: provider.id,
                                      appointmentEnabled:
                                          provider.lastService.type ==
                                          'appointment',
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                        ),

                        SizedBox(height: 18.h),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppTranslations.translateValue(
                                "home.top_businesses",
                              ),
                              style: GoogleFonts.inter(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Get.toNamed(AppRoutes.allTopBusinesses);
                              },
                              child: Text(
                                AppTranslations.translateValue(
                                  "common.view_all",
                                ),
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.mainAppColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),

                        Obx(() {
                          if (topBusinessesController.isLoading.value) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (topBusinessesController.errorMessage.isNotEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  topBusinessesController.errorMessage.value,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            );
                          }

                          if (topBusinessesController.businesses.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  AppTranslations.translateValue(
                                    "home.no_top_businesses",
                                  ),
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount:
                                topBusinessesController.businesses.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final business =
                                  topBusinessesController.businesses[index];
                              return CustomTopbusinessesCard(
                                title:
                                    business.businessName ??
                                    AppTranslations.translateValue(
                                      "business.business_name",
                                    ),
                                ownerName: business.businessOwnerName,
                                review: (business.businessRating ?? 0.0)
                                    .toStringAsFixed(1),
                                location:
                                    business.businessAddress ??
                                    AppTranslations.translateValue(
                                      "service.address_not_available",
                                    ),
                                numberEmployees: business.employeeCount ?? 0,
                                numberOfServices: business.serviceCount ?? 0,
                                businessPhoto: business.businessPhoto,
                                businessOwnerId: business.businessOwnerId,
                              );
                            },
                          );
                        }),
                        SizedBox(height: 10.h),

                        Text(
                          AppTranslations.translateValue(
                            "home.recommended_services",
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10.h),

                        /// -------------- Recommended Services ----------------------------------- ///
                        Obx(() {
                          if (featuredProvidersController.isLoading.value) {
                            return SizedBox(
                              height: 400.h,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (featuredProvidersController
                              .allFeaturedServices
                              .isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return SizedBox(
                            height: 370.h,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.zero,
                              itemCount: featuredProvidersController
                                  .allFeaturedServices
                                  .length,
                              itemBuilder: (context, index) {
                                final item = featuredProvidersController
                                    .allFeaturedServices[index];
                                final provider = item.provider;
                                final service = item.service;

                                return Padding(
                                  padding: EdgeInsets.only(right: 8.w),
                                  child: SizedBox(
                                    width: 310.w,
                                    child: CustomFeaturedProviderCard(
                                      providerName:
                                          provider.name ??
                                          AppTranslations.translateValue(
                                            'common.unknown',
                                          ),
                                      location:
                                          provider.address ??
                                          AppTranslations.translateValue(
                                            'service.address_not_available',
                                          ),
                                      activeStatus: provider.activityTime ?? '',
                                      serviceTitle:
                                          service.serviceName ??
                                          AppTranslations.translateValue(
                                            'common.not_available',
                                          ),
                                      serviceDescription:
                                          service.serviceDetail ??
                                          AppTranslations.translateValue(
                                            'common.not_available',
                                          ),
                                      reviews:
                                          "${service.rating?.toStringAsFixed(1) ?? '0.0'} (${service.totalReviews ?? 0})",
                                      appointmentPrice:
                                          service.appointmentEnabled == true
                                          ? (service.appointmentSlots != null &&
                                                    service
                                                        .appointmentSlots!
                                                        .isNotEmpty
                                                ? (service.appointmentSlots![0]['price']
                                                          ?.toDouble() ??
                                                      0.0)
                                                : 0.0)
                                          : null,
                                      servicePrice: service.basePrice
                                          ?.toDouble(),
                                      providerImage: provider.profileImage,
                                      serviceImage: service.servicePhoto,
                                      serviceId: service.serviceId,
                                      providerId: provider.providerId,
                                      appointmentEnabled:
                                          service.appointmentEnabled,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                        SizedBox(height: 18.h),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppTranslations.translateValue(
                                "home.providers_near_you",
                              ),
                              style: GoogleFonts.inter(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                           
                          ],
                        ),
                        SizedBox(height: 10.h),

                        Obx(() {
                          if (nearbyController.isLoading.value) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (nearbyController.errorMessage.isNotEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  nearbyController.errorMessage.value,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            );
                          }

                          if (nearbyController.providers.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  AppTranslations.translateValue(
                                    "home.no_nearby_providers",
                                  ),
                                ),
                              ),
                            );
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(0),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 0.95,
                                ),
                            itemCount: nearbyController.providers.length,
                            itemBuilder: (context, index) {
                              final provider =
                                  nearbyController.providers[index];

                              // Parse distance from string or use the numeric value if available
                              double distanceKm = 0.0;
                              if (provider.distanceKm != null) {
                                distanceKm =
                                    double.tryParse(provider.distanceKm!) ??
                                    0.0;
                              } else if (provider.distance != null) {
                                // If we only have meters (assuming numeric distance is meters), convert to km
                                distanceKm =
                                    (provider.distance!.toDouble()) / 1000;
                              }

                              final subtitle =
                                  (provider.occupation != null &&
                                      provider.occupation!.isNotEmpty)
                                  ? provider.occupation!
                                  : AppTranslations.translateValue(
                                      "onboarding.provider",
                                    );

                              return BusinessCard(
                                name:
                                    provider.name ??
                                    AppTranslations.translateValue(
                                      'common.unknown',
                                    ),
                                category: subtitle,
                                distance: distanceKm,
                                showDistance: distanceKm > 0,
                                image: provider.profileImage ?? '',
                                categoryId: provider.providerId ?? '',
                                onTap: provider.providerId == null
                                    ? () {}
                                    : () {
                                        Get.toNamed(
                                          AppRoutes.userProviderProfile,
                                          arguments: provider.providerId,
                                        );
                                      },
                              );
                            },
                          );
                        }),
                        SizedBox(height: 20.h),

                        /// ------------------------ Events Section --------------------------------------
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppTranslations.translateValue("home.events"),
                              style: GoogleFonts.inter(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Get.to(() => MyEvents());
                              },
                              child: Text(
                                AppTranslations.translateValue(
                                  "common.view_all",
                                ),
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.mainAppColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 260.h,
                          child: Obx(() {
                            if (eventController.isLoading.value) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (eventController.errorMessage.isNotEmpty) {
                              return Center(
                                child: Text(
                                  eventController.errorMessage.value,
                                  style: TextStyle(color: Colors.red),
                                ),
                              );
                            }

                            if (eventController.eventList.isEmpty) {
                              return Center(
                                child: Text(
                                  AppTranslations.translateValue(
                                    "event.no_events_found",
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.only(top: 10.h),
                              itemCount: eventController.eventList.length,
                              itemBuilder: (context, index) {
                                final event = eventController.eventList[index];

                                return Padding(
                                  padding: EdgeInsets.only(right: 10.w),
                                  child: SizedBox(
                                    width: 300.w,
                                    child: CustomEventCard(
                                      title: event.eventType,
                                      eventName: event.eventName,
                                      eventImage: event.eventImage,
                                      date: event.formattedDate,
                                      timeRange: event.formattedTime,
                                      location: event.eventLocation,
                                      attendingCount: event.ticketsSold,
                                      eventId: event.eventId,
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                        ),
                        SizedBox(height: 18.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsSection() {
    return Obx(() {
      if (!homeSearchController.isSearchActive.value) {
        return const SizedBox.shrink();
      }

      if (homeSearchController.currentQuery.value.length < 2) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Text(
            AppTranslations.translateValue(
              "Type at least 2 characters to search",
            ),
            style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
          ),
        );
      }

      if (homeSearchController.isSearching.value) {
        return Padding(
          padding: EdgeInsets.only(top: 6.h, bottom: 20.h),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      if (homeSearchController.errorMessage.value.isNotEmpty) {
        return Padding(
          padding: EdgeInsets.only(bottom: 20.h),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.red.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  homeSearchController.errorMessage.value,
                  style: TextStyle(color: Colors.red, fontSize: 13.sp),
                ),
                SizedBox(height: 10.h),
                ElevatedButton(
                  onPressed: () => homeSearchController.searchServices(
                    homeSearchController.currentQuery.value,
                  ),
                  child: Text(AppTranslations.translateValue("Retry")),
                ),
              ],
            ),
          ),
        );
      }

      if (homeSearchController.results.isEmpty) {
        return Padding(
          padding: EdgeInsets.only(bottom: 20.h),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              AppTranslations.translateValue("No services found"),
              style: TextStyle(color: Colors.grey[700], fontSize: 13.sp),
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTranslations.translateValue("Search results"),
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: homeSearchController.results.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              final item = homeSearchController.results[index];
              return _buildSearchResultCard(item);
            },
          ),
          SizedBox(height: 18.h),
        ],
      );
    });
  }

  Widget _buildSearchResultCard(HomeSearchServiceItem item) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => _openSearchResult(item),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child:
                    (item.serviceImage != null && item.serviceImage!.isNotEmpty)
                    ? Image.network(
                        item.serviceImage!,
                        width: 56.w,
                        height: 56.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 56.w,
                          height: 56.w,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.image_outlined,
                            size: 22.sp,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Container(
                        width: 56.w,
                        height: 56.w,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image_outlined,
                          size: 22.sp,
                          color: Colors.grey,
                        ),
                      ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      item.providerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                    if (item.description.isNotEmpty) ...[
                      SizedBox(height: 3.h),
                      Text(
                        item.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    SizedBox(height: 4.h),
                    Text(
                      "\$${item.price.toStringAsFixed(2)}",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mainAppColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.sp,
                color: Colors.grey[500],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSearchResult(HomeSearchServiceItem item) {
    final String serviceId = item.serviceId.trim();
    final String providerId = item.providerId.trim();

    if (serviceId.isEmpty) {
      Get.snackbar(
        AppTranslations.translateValue("Error"),
        AppTranslations.translateValue("Service ID not available"),
      );
      return;
    }

    Get.toNamed(
      AppRoutes.providerServiceDetailsScreen,
      arguments: {
        'serviceId': serviceId,
        'providerId': providerId.isEmpty ? null : providerId,
      },
    );

    _searchController.clear();
    homeSearchController.clearSearch();
  }
}
