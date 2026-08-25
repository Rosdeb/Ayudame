import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:middle_ware/core/theme/app_colors.dart';
import 'package:middle_ware/models/user/categories/category_model.dart';
import 'package:middle_ware/widgets/custom_appbar.dart';

import '../../../controller/user/category_controller/category_businesses_controller.dart';
import '../home/widgets/custom_top_businesses_card.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class CategoryBusinessesScreen extends StatefulWidget {
  const CategoryBusinessesScreen({super.key});

  @override
  State<CategoryBusinessesScreen> createState() =>
      _CategoryBusinessesScreenState();
}

class _CategoryBusinessesScreenState extends State<CategoryBusinessesScreen> {
  final CategoryBusinessesController controller = Get.put(
    CategoryBusinessesController(),
  );

  String _categoryId = '';
  String _categoryName = '';

  @override
  void initState() {
    super.initState();

    final dynamic args = Get.arguments;
    if (args is CategoryModel) {
      _categoryId = args.id;
      _categoryName = args.name;
    } else if (args is Map) {
      _categoryId = (args['id'] ?? args['categoryId'] ?? '').toString();
      _categoryName = (args['name'] ?? '').toString();
    } else if (args is String) {
      _categoryId = args;
    }

    if (_categoryId.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchBusinessesByCategory(_categoryId);
      });
    } else {
      controller.errorMessage.value = "Invalid category";
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title =
        _categoryName.trim().isNotEmpty ? _categoryName : 'Top Businesses';

    return Scaffold(
      backgroundColor: AppColors.bgColor1,
      appBar: CustomAppBar(title: title),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.isNotEmpty) {
            return Center(child: Text(controller.errorMessage.value));
          }

          if (controller.businesses.isEmpty) {
            return Center(
              child: Text(
                AppTranslations.translateValue("No businesses found"),
              ),
            );
          }

          return ListView.builder(
            itemCount: controller.businesses.length,
            itemBuilder: (context, index) {
              final business = controller.businesses[index];
              return CustomTopbusinessesCard(
                title: business.businessName ?? "Business Name",
                ownerName: business.businessOwnerName,
                review: (business.businessRating ?? 0.0).toStringAsFixed(1),
                location: business.businessAddress ?? "Address not available",
                numberEmployees: business.employeeCount ?? 0,
                numberOfServices: business.serviceCount ?? 0,
                businessPhoto: business.businessPhoto,
                businessOwnerId: business.businessOwnerId,
              );
            },
          );
        }),
      ),
    );
  }
}

