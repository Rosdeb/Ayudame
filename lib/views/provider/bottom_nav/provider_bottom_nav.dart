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

class ProviderBottomNavScreen extends StatefulWidget {
  const ProviderBottomNavScreen({super.key});

  @override
  State<ProviderBottomNavScreen> createState() =>
      _ProviderBottomNavScreenState();
}

class _ProviderBottomNavScreenState extends State<ProviderBottomNavScreen> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final resolved = _resolveInitialIndex(Get.arguments);
    if (resolved != null) {
      selectedIndex = resolved;
    }
  }

  void navigationItemTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    HomeProviderScreen(),
    ProviderCreateServicePage(),
    OrderHistoryProviderScreen(),
    ProviderProfilePage(),
  ];

  // Create nav items in a getter
  List<BottomNavigationBarItem> get _navItems => [
    _navItem(
      AppIcons.userHomeIcon,
      AppIcons.userHomeIconS,
      AppTranslations.translateValue("bottom_nav.home"),
      0,
    ),
    _navItem(
      AppIcons.createIcon,
      AppIcons.crateIconS,
      AppTranslations.translateValue("provider.create_service"),
      1,
    ),
    _navItem(
      AppIcons.userOrderIcon,
      AppIcons.userOrderS,
      AppTranslations.translateValue("order.order_history"),
      2,
    ),
    _navItem(
      AppIcons.userProfile,
      AppIcons.userProfileS,
      AppTranslations.translateValue("bottom_nav.profile"),
      3,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(0xFFE7F4F6),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
          // boxShadow: [
          //   BoxShadow(
          //     color: const Color(0xFF000000).withOpacity(0.08),
          //     offset: const Offset(4, 0),
          //     blurRadius: 4,
          //     spreadRadius: 0,
          //   ),
          // ],
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
            fontSize: 12.sp,
            color: AppColors.mainAppColor,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'SegeoUi_bold',
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
            color: AppColors.grey,
          ),
          showSelectedLabels: true,
          unselectedItemColor: AppColors.grey,
          backgroundColor: Colors.transparent,
          onTap: navigationItemTap,
          items: _navItems,
        ),
      ),
    );
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
