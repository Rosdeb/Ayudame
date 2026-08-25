import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:middle_ware/core/theme/app_colors.dart';
import 'package:middle_ware/models/business_payment_history_model.dart';
import 'package:middle_ware/viewmodels/business_payment_history_viewmodel.dart';
import 'package:middle_ware/widgets/custom_appbar.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BusinessPaymentHistoryViewModel());

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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 12.h),
                  TextButton(
                    onPressed: controller.fetchTransactions,
                    child: Text(AppTranslations.translateValue('Retry')),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.transactions.isEmpty) {
          return Center(
            child: Text(
              AppTranslations.translateValue('No payment history found.'),
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

  Widget _paymentCard(BuildContext context, BusinessTransaction transaction) {
    final bookingDate = _formatDate(transaction.bookingDate);
    final createdDate = _formatDate(transaction.createdAt);
    final paidAt = _formatDate(transaction.paidAt);
    final paymentStatus = transaction.paymentStatus ?? 'unknown';
    final orderStatus = transaction.status ?? 'unknown';

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _infoRow('Source', _normalizeLabel(transaction.source)),
          SizedBox(height: 5.h),
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
          _infoRow('Paid At', paidAt),
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
            _normalizeLabel(paymentStatus),
            valueColor: _statusColor(paymentStatus),
          ),
          SizedBox(height: 5.h),
          _infoRow(
            'Order Status',
            _normalizeLabel(orderStatus),
            valueColor: _statusColor(orderStatus),
          ),
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
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '-';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return '-';
    return DateFormat('dd MMM, yyyy').format(parsed.toLocal());
  }

  String _formatCurrency(num? value) {
    if (value == null) return '-';
    return '\$${value.toStringAsFixed(2)}';
  }

  String _normalizeLabel(String? value) {
    if (value == null || value.trim().isEmpty) return '-';
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((word) {
          final lower = word.toLowerCase();
          return lower[0].toUpperCase() + lower.substring(1);
        })
        .join(' ');
  }

  Color _statusColor(String value) {
    final normalized = value.toLowerCase().replaceAll('-', '_');
    switch (normalized) {
      case 'completed':
      case 'offline_paid':
        return Colors.green;
      case 'pending':
      case 'authorized':
      case 'partial':
      case 'due_requested':
        return Colors.orange;
      case 'rejected':
      case 'cancelled':
      case 'refunded':
        return Colors.red;
      default:
        return AppColors.dark;
    }
  }
}
