import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:middle_ware/core/localization/app_translations.dart';
import 'package:middle_ware/viewmodels/event_manager_bank_controller.dart';
import 'package:middle_ware/views/event_manager/profile/event_bank_form_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../components/custom_app_bar.dart';

class EventBankInformation extends StatelessWidget {
  EventBankInformation({super.key});

  final EventManagerBankController bankController = Get.put(EventManagerBankController());
  String t(String value) => AppTranslations.translateValue(value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: CustomAppBar(
        title: t("profile.bank_information"),
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),

              /// Add Bank Account button
              Obx(() => bankController.bankInfo.value == null ? GestureDetector(
                onTap: () {
                  Get.to(() => const EventManagerBankFormScreen());
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.mainAppColor),
                  ),
                  child: Text(
                    t("payment.add_bank_account"),
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainAppColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ) : const SizedBox.shrink()),
              
              Obx(() => bankController.bankInfo.value != null 
                ? SizedBox(height: 10.h) 
                : SizedBox(height: MediaQuery.of(context).size.height * 0.035)),

              /// Payout Information card
              Obx(() {
                if (bankController.isLoading.value && bankController.bankInfo.value == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                final bankInfo = bankController.bankInfo.value;

                if (bankInfo != null) {
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                t("payment.payout"),
                                style: GoogleFonts.inter(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.to(() => EventManagerBankFormScreen(existingBankInfo: bankInfo));
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.mainAppColor.withOpacity(0.3)),
                                    borderRadius: BorderRadius.circular(8.r),
                                    color: AppColors.mainAppColor.withOpacity(0.05),
                                  ),
                                  child: Text(
                                    t("common.edit"),
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.mainAppColor,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 24.h),
                          
                          _buildInfoRow(t("Account Name"), bankInfo.accountHolderName),
                          const Divider(height: 32),
                          _buildInfoRow(t("payment.bank_name"), bankInfo.bankName),
                          const Divider(height: 32),
                          _buildInfoRow(t("payment.account_number"), bankInfo.maskedAccountNumber),
                          const Divider(height: 32),
                          _buildInfoRow(t("payment.routing_number"), bankInfo.routingNumber),
                          const Divider(height: 32),
                          _buildInfoRow(t("Account Type"), bankInfo.accountHolderType),
                        ],
                      ),
                    ),
                  );
                }

                return bankController.isLoading.value 
                  ? const SizedBox.shrink()
                  : Center(
                      child: Column(
                        children: [
                          SizedBox(height: 40.h),
                          Icon(Icons.account_balance_outlined, size: 64, color: Colors.grey[300]),
                          SizedBox(height: 16.h),
                          Text(
                            t("No bank information added yet"),
                            style: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
                          ),
                        ],
                      ),
                    );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: Colors.black54,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
