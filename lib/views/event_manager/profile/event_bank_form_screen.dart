import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:middle_ware/core/localization/app_translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../components/custom_app_bar.dart';
import '../../components/custom_text_field.dart';
import '../../../viewmodels/event_manager_bank_controller.dart';
import '../../../models/event_bank_model.dart';

class EventManagerBankFormScreen extends StatefulWidget {
  final EventBankModel? existingBankInfo;
  const EventManagerBankFormScreen({super.key, this.existingBankInfo});

  @override
  State<EventManagerBankFormScreen> createState() => _EventManagerBankFormScreenState();
}

class _EventManagerBankFormScreenState extends State<EventManagerBankFormScreen> {
  final EventManagerBankController controller = Get.find<EventManagerBankController>();
  String t(String value) => AppTranslations.translateValue(value);

  @override
  void initState() {
    super.initState();
    if (widget.existingBankInfo != null) {
      controller.loadBankInfo();
    } else {
      controller.clearFields();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: CustomAppBar(
        title: widget.existingBankInfo != null
            ? t("Edit Bank Information")
            : t("payment.add_bank_account"),
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldLabel(t("Account Holder Name")),
            CustomTextField(
              textEditingController: controller.accountHolderCtrl,
              hintText: t('Account Holder Name'),
              hintStyle: TextStyle(
                fontFamily: 'Montserrat-Regular',
                fontWeight: FontWeight.w400,
                fontSize: 12.sp,
                color: AppColors.grey,
              ),
            ),

            _fieldLabel(t("payment.bank_name")),
            CustomTextField(
              textEditingController: controller.bankNameCtrl,
              hintText: t('payment.bank_name'),
              hintStyle: TextStyle(
                fontFamily: 'Montserrat-Regular',
                fontWeight: FontWeight.w400,
                fontSize: 12.sp,
                color: AppColors.grey,
              ),
            ),

            _fieldLabel(t("Enter Your Bank Account Number")),
            CustomTextField(
              textEditingController: controller.accountNumberCtrl,
              hintText: t('Enter Your Bank Account Number'),
              hintStyle: TextStyle(
                fontFamily: 'Montserrat-Regular',
                fontWeight: FontWeight.w400,
                fontSize: 12.sp,
                color: AppColors.grey,
              ),
            ),

            _fieldLabel(t("payment.routing_number")),
            CustomTextField(
              textEditingController: controller.routingNumberCtrl,
              hintText: t('Enter Your Routing Number'),
              hintStyle: TextStyle(
                fontFamily: 'Montserrat-Regular',
                fontWeight: FontWeight.w400,
                fontSize: 12.sp,
                color: AppColors.grey,
              ),
            ),

            _fieldLabel(t("Account Holder Type")),
            Obx(() => Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.mainAppColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.accountHolderType.value,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.mainAppColor),
                  items: <String>['Personal', 'Business'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value == 'Business'
                            ? t('onboarding.business')
                            : t(value),
                        style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    controller.accountHolderType.value = newValue!;
                  },
                ),
              ),
            )),

            SizedBox(height: 25.h),
            _buildSecurityBox(),

            SizedBox(height: 40.h),

            // Save Changes button
            Obx(() => SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainAppColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  elevation: 0,
                ),
                onPressed: controller.isLoading.value 
                  ? null 
                  : () => controller.addOrUpdateBank(isEdit: widget.existingBankInfo != null),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.existingBankInfo != null
                            ? t("Save Changes")
                            : t("Save Bank Information"),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                      ),
              ),
            )),
             SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
    padding: EdgeInsets.only(bottom: 8.h, top: 16.h),
    child: Text(text, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp, color: Colors.black87)),
  );

  Widget _buildSecurityBox() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.mainAppColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.mainAppColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined, color: AppColors.mainAppColor, size: 24),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t("Your information is secure"),
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                SizedBox(height: 2.h),
                Text(
                  t("Secure bank-level encryption to protect your data."),
                  style: TextStyle(fontSize: 11.sp, color: Colors.black54),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
