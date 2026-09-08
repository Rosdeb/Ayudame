import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../core/app_icons.dart';
import '../core/theme/app_colors.dart';
import '../views/business/activities/activities_page.dart';
import '../views/business/employee/all_employee.dart';
import '../views/business/home/business_home_page_screen.dart';
import '../views/business/profile/business_profile.dart';
import '../controller/business/bottom_nav_controller.dart';

class BottomNavScreen extends StatelessWidget {
  BottomNavScreen({super.key});

  final BusinessBottomNavController controller = Get.put(BusinessBottomNavController());

  final List<Widget> _pages = [
     BusinessHomePageScreen(),
     BusinessEmployeeListScreen(),
    const ActivitiesPage(),
    const Businessprofile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return PopScope(
        canPop: controller.selectedIndex.value == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          controller.changeTabIndex(0);
        },
        child: Scaffold(
          body: _pages[controller.selectedIndex.value],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE7F4F6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF000000).withOpacity(0.08),
                  offset: const Offset(4, 0),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
              border: const Border(
                top: BorderSide(color: Color(0xFFE3E6F0), width: 1),
              ),
            ),
            height: 95.h,
            child: BottomNavigationBar(
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              currentIndex: controller.selectedIndex.value,
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
              onTap: controller.changeTabIndex,
              items: [
                _navItem(AppIcons.home, AppIcons.homes, "bottom_nav.home".tr, 0, controller.selectedIndex.value),
                _navItem(AppIcons.employee, AppIcons.employees, "bottom_nav.employees".tr, 1, controller.selectedIndex.value),
                _navItem(AppIcons.activity, AppIcons.activitys, "bottom_nav.activities".tr, 2, controller.selectedIndex.value),
                _navItem(AppIcons.profile, AppIcons.profiles, "bottom_nav.profile".tr, 3, controller.selectedIndex.value),
              ],
            ),
          ),
        ),
      );
    });
  }

  BottomNavigationBarItem _navItem(
    String unselected,
    String selected,
    String label,
    int index,
    int currentIndex,
  ) {
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(currentIndex == index ? selected : unselected),
          SizedBox(height: 10.h),
        ],
      ),
      label: label,
    );
  }
}
