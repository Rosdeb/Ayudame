import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:middle_ware/core/theme/app_colors.dart';
import 'package:middle_ware/views/provider/profile/edit_service.dart';
import 'package:middle_ware/widgets/custom_appbar.dart';
import 'package:middle_ware/utils/token_service.dart';
import 'package:middle_ware/services/api_service.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class ProviderService {
  final String id;
  final String headline;
  final String description;
  final String servicePhoto;
  final String categoryName;
  final String categoryId;
  final num basePrice;
  final num rating;
  final int totalReviews;
  final bool appointmentEnabled;
  final Map<String, dynamic> whyChooseUs;
  final List<dynamic> appointmentSlots;
  final String providerName;
  final String providerLocation;
  final String? providerProfilePicture;

  ProviderService({
    required this.id,
    required this.headline,
    required this.description,
    required this.servicePhoto,
    required this.categoryName,
    required this.categoryId,
    required this.basePrice,
    required this.rating,
    required this.totalReviews,
    required this.appointmentEnabled,
    required this.whyChooseUs,
    required this.appointmentSlots,
    required this.providerName,
    required this.providerLocation,
    this.providerProfilePicture,
  });

  factory ProviderService.fromJson(Map<String, dynamic> json) {
    final dynamic categoryRaw = json['category'] ?? json['categories'];
    String categoryName = '';
    String categoryId = '';
    if (categoryRaw is Map) {
      categoryName = (categoryRaw['name'] ?? '').toString();
      categoryId = (categoryRaw['id'] ?? categoryRaw['_id'] ?? '').toString();
    } else if (categoryRaw is List && categoryRaw.isNotEmpty) {
      final dynamic first = categoryRaw.first;
      if (first is Map) {
        categoryName = (first['name'] ?? '').toString();
        categoryId = (first['id'] ?? first['_id'] ?? '').toString();
      } else {
        categoryName = first.toString();
      }
    } else if (categoryRaw != null) {
      categoryName = categoryRaw.toString();
    }

    final dynamic providerLocationRaw =
        json['providerLocation'] ??
        json['providerId']?['userId']?['location'] ??
        json['employeeId']?['location'] ??
        {};
    final Map<String, dynamic> providerLocation = providerLocationRaw is Map
        ? Map<String, dynamic>.from(providerLocationRaw)
        : <String, dynamic>{};
    final String address = (providerLocation['address'] ?? '').toString();

    final dynamic providerUserRaw =
        json['providerId']?['userId'] ?? json['employeeId']?['userId'];
    final Map<String, dynamic> providerUser = providerUserRaw is Map
        ? Map<String, dynamic>.from(providerUserRaw)
        : <String, dynamic>{};

    final dynamic whyChooseRaw =
        json['whyChooseUs'] ?? json['whyChooseService'] ?? {};
    final Map<String, dynamic> whyChoose = whyChooseRaw is Map
        ? Map<String, dynamic>.from(whyChooseRaw)
        : <String, dynamic>{};

    final dynamic slotsRaw = json['appointmentSlots'] ?? <dynamic>[];
    final List<dynamic> slots = slotsRaw is List ? slotsRaw : <dynamic>[];

    return ProviderService(
      id: (json['id'] ?? json['_id'] ?? json['serviceId'] ?? '').toString(),
      headline: (json['headline'] ?? json['title'] ?? '').toString(),
      description: (json['description'] ?? json['about'] ?? '').toString(),
      servicePhoto: (json['servicePhoto'] ?? json['image'] ?? '').toString(),
      categoryName: categoryName,
      categoryId: categoryId,
      basePrice: json['basePrice'] ?? json['price'] ?? 0,
      rating: json['rating'] ?? 0,
      totalReviews: json['totalReviews'] ?? 0,
      appointmentEnabled: json['appointmentEnabled'] == true,
      whyChooseUs: whyChoose,
      appointmentSlots: slots,
      providerName:
          (json['providerName'] ??
                  json['employeeName'] ??
                  providerUser['fullName'] ??
                  '')
              .toString(),
      providerLocation: address,
      providerProfilePicture:
          (json['providerProfilePicture'] ?? providerUser['profilePicture'])
              ?.toString(),
    );
  }

  Map<String, dynamic> toArgs() {
    return {
      'id': id,
      'headline': headline,
      'description': description,
      'servicePhoto': servicePhoto,
      'categoryName': categoryName,
      'categoryId': categoryId,
      'basePrice': basePrice,
      'appointmentEnabled': appointmentEnabled,
      'whyChooseUs': whyChooseUs,
      'appointmentSlots': appointmentSlots,
    };
  }
}

class AllServicesPage extends StatefulWidget {
  const AllServicesPage({super.key});

  @override
  State<AllServicesPage> createState() => _AllServicesPageState();
}

class _AllServicesPageState extends State<AllServicesPage> {
  bool _isLoading = false;
  String _errorMessage = '';
  List<ProviderService> _services = [];

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await TokenService().init();
      final token = await TokenService().getToken();
      if (token == null || token.isEmpty) {
        setState(() {
          _errorMessage = 'Please log in again.';
        });
        return;
      }

      final List<String> endpoints = <String>[
        "/api/services?includeEmployeeServices=true",
        "/api/services",
        "/api/providers/services",
      ];

      bool loaded = false;
      for (final endpoint in endpoints) {
        final response = await http.get(
          Uri.parse("${ApiService.BASE_URL}$endpoint"),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode != 200) {
          continue;
        }

        final data = json.decode(response.body);
        List<dynamic> list = <dynamic>[];

        if (data is Map && data['data'] is Map) {
          final Map<String, dynamic> dataMap = Map<String, dynamic>.from(
            data['data'],
          );
          if (dataMap['services'] is List) {
            list = dataMap['services'] as List<dynamic>;
          } else if (dataMap['items'] is List) {
            list = dataMap['items'] as List<dynamic>;
          } else if (dataMap['service'] is Map) {
            list = <dynamic>[dataMap['service']];
          }
        } else if (data is Map && data['services'] is List) {
          list = data['services'] as List<dynamic>;
        } else if (data is List) {
          list = data;
        }

        _services = list
            .whereType<Map>()
            .map((e) => ProviderService.fromJson(Map<String, dynamic>.from(e)))
            .where((service) => service.id.isNotEmpty)
            .toList();

        if (_services.isNotEmpty || endpoint == endpoints.last) {
          loaded = true;
          break;
        }
      }

      if (!loaded) {
        _errorMessage = 'Failed to load services.';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: CustomAppBar(
        title: AppTranslations.translateValue("All Services"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : _services.isEmpty
          ? Center(
              child: Text(AppTranslations.translateValue("No services found")),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _services.length,
              itemBuilder: (context, index) {
                final service = _services[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service Image + Edit Button
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              service.servicePhoto,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 160,
                                  color: Colors.grey[200],
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.image,
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
                              onTap: () {
                                Get.to(
                                  () => EditServicePage(),
                                  arguments: service.toArgs(),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  AppTranslations.translateValue(
                                    "Edit Service",
                                  ),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
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
                                          service
                                              .providerProfilePicture!
                                              .isNotEmpty
                                      ? NetworkImage(
                                          service.providerProfilePicture!,
                                        )
                                      : const AssetImage(
                                              "assets/images/emptyUser.png",
                                            )
                                            as ImageProvider,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
  }

  Widget _buildPriceDisplay(ProviderService service) {
    if (service.appointmentEnabled && service.appointmentSlots.isNotEmpty) {
      // Get price range from appointment slots
      final prices = service.appointmentSlots
          .map((slot) => slot['price'] as num)
          .toList();

      if (prices.isEmpty) {
        return Text(
          AppTranslations.translateValue("Appointment price: N/A"),
          style: TextStyle(
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
