import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:middle_ware/views/business/profile/widgets/business_profile_card.dart';
import 'package:middle_ware/widgets/custom_appbar.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class BusinessProfileScreen extends StatelessWidget {
  const BusinessProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: CustomAppBar(
        title: AppTranslations.translateValue("Business Profile"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Center(
              child: SizedBox(width: 335.w, child: const BusinessProfileCard()),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
