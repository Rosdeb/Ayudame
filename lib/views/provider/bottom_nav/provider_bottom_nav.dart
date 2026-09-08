import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:middle_ware/views/provider/home/CreateServiceProvider.dart';
import 'package:middle_ware/views/provider/home/HomeProviderScreen.dart';
import 'package:middle_ware/views/provider/orders/OrderProvider.dart';
import 'package:middle_ware/views/provider/profile/ProviderProfilePage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../utils/app_icons.dart';
import 'package:middle_ware/core/localization/app_translations.dart';
import '../../../controller/provider/bottom_nav_controller.dart';

class ProviderBottomNavScreen extends StatelessWidget {
  ProviderBottomNavScreen({super.key}) {
    final resolved = _resolveInitialIndex(Get.arguments);
    if (resolved != null) {
      controller.selectedIndex.value = resolved;
    }
  }

  final ProviderBottomNavController controller = Get.put(ProviderBottomNavController());

  final List<Widget> _pages = [
    HomeProviderScreen(),
    ProviderCreateServicePage(),
    OrderHistoryProviderScreen(),
    ProviderProfilePage(),
  ];

  // Create nav items in a getter
  List<BottomNavigationBarItem> _navItems(int selectedIndex) => [
    _navItem(
      AppIcons.userHomeIcon,
      AppIcons.userHomeIconS,
      AppTranslations.translateValue("bottom_nav.home"),
      0,
      selectedIndex,
    ),
    _navItem(
      AppIcons.createIcon,
      AppIcons.crateIconS,
      AppTranslations.translateValue("provider.create_service"),
      1,
      selectedIndex,
    ),
    _navItem(
      AppIcons.userOrderIcon,
      AppIcons.userOrderS,
      AppTranslations.translateValue("order.order_history"),
      2,
      selectedIndex,
    ),
    _navItem(
      AppIcons.userProfile,
      AppIcons.userProfileS,
      AppTranslations.translateValue("bottom_nav.profile"),
      3,
      selectedIndex,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedIndex = controller.selectedIndex.value;
      
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (selectedIndex != 0) {
            controller.changeTabIndex(0);
          }
        },
        child: Scaffold(
          body: _pages[selectedIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE7F4F6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
              border: const Border(
                top: BorderSide(color: Color(0xFFE3E6F0), width: 1),
              ),
            ),
            height: MediaQuery.of(context).size.height * 0.12,
            child: BottomNavigationBar(
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              currentIndex: selectedIndex,
              selectedItemColor: AppColors.mainAppColor,
              selectedLabelStyle: TextStyle(
                fontFamily: 'SegeoUi_bold',
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: AppColors.mainAppColor,
              ),
              unselectedLabelStyle: TextStyle(
                fontFamily: 'SegeoUi_bold',
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: AppColors.grey,
              ),
              showSelectedLabels: true,
              unselectedItemColor: AppColors.grey,
              backgroundColor: Colors.transparent,
              onTap: controller.changeTabIndex,
              items: _navItems(selectedIndex),
            ),
          ),
        ),
      );
    });
  }

  // 🎯 FIX: Simplified _navItem and added color logic for SVG
  int? _resolveInitialIndex(dynamic args) {
    int? idx;
    if (args is int) {
      idx = args;
    } else if (args is Map) {
      final dynamic v = args['index'];
      if (v is int) {
        idx = v;
      } else if (v is String) {
        idx = int.tryParse(v);
      }
    }

    if (idx == null) return null;
    if (idx < 0) return 0;
    if (idx >= _pages.length) return _pages.length - 1;
    return idx;
  }

  BottomNavigationBarItem _navItem(
    String unselected,
    String selected, // Only one path needed
    String label,
    int index,
    int selectedIndex,
  ) {
    return BottomNavigationBarItem(
      // 🎯 FIX: Removed the unnecessary Column and SizedBox(height: 10.h)
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(selectedIndex == index ? selected : unselected),
          SizedBox(height: 10.h),
        ],
      ),
      label: label,
    );
  }
}
