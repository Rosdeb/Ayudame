import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:middle_ware/core/theme/app_colors.dart';
import 'package:middle_ware/widgets/custom_appbar.dart';
import '../../../controller/provider/profile/payment_history_controller.dart';
import '../../../models/provider/payment_history_model.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class provider_PaymentHistoryScreen extends StatelessWidget {
  const provider_PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProviderPaymentHistoryController());

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: CustomAppBar(
        title: AppTranslations.translateValue('Payment History'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: controller.fetchTransactions,
                  child: Text(AppTranslations.translateValue("Retry")),
                ),
              ],
            ),
          );
        }

        if (controller.transactions.isEmpty) {
          return Center(
            child: Text(
              AppTranslations.translateValue("No payment history found."),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.transactions.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _paymentCard(context, controller.transactions[index]),
            );
          },
        );
      }),
    );
  }

  Widget _paymentCard(BuildContext context, ProviderTransaction transaction) {
    final bookingDate = _formatDate(transaction.bookingDate);
    final createdDate = _formatDate(transaction.createdAt);
    final paymentStatus = transaction.paymentStatus ?? 'unknown';
    final status = transaction.status ?? 'unknown';

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _infoRow('Service', transaction.serviceName ?? 'Unknown'),
          SizedBox(height: 5.h),
          _infoRow(
            'Customer',
            transaction.customerName?.isNotEmpty == true
                ? transaction.customerName!
                : 'Unknown',
          ),
          SizedBox(height: 5.h),
          _infoRow('Booking Date', bookingDate),
          SizedBox(height: 5.h),
          _infoRow('Created At', createdDate),
          SizedBox(height: 5.h),
          _infoRow('Amount', _formatCurrency(transaction.amount)),
          SizedBox(height: 5.h),
          _infoRow('Down Payment', _formatCurrency(transaction.downPayment)),
          SizedBox(height: 5.h),
          _infoRow('Due Amount', _formatCurrency(transaction.dueAmount)),
          SizedBox(height: 5.h),
          _infoRow('Remaining', _formatCurrency(transaction.remainingAmount)),
          SizedBox(height: 5.h),
          _infoRow(
            'Payment Status',
            paymentStatus,
            valueColor: _statusColor(paymentStatus),
          ),
          SizedBox(height: 5.h),
          _infoRow('Order Status', status, valueColor: _statusColor(status)),
        ],
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    Color valueColor = Colors.black,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return '-';
    return DateFormat('dd MMM, yyyy').format(parsed.toLocal());
  }

  String _formatCurrency(num? value) {
    if (value == null) return '-';
    return '\$${value.toStringAsFixed(0)}';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'partial':
        return Colors.deepOrange;
      default:
        return Colors.black;
    }
  }
}
