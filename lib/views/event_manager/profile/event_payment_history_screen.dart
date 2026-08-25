import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:middle_ware/core/localization/app_translations.dart';
import 'package:middle_ware/core/theme/app_colors.dart';
import 'package:middle_ware/models/event_manager_payment_history_model.dart';
import 'package:middle_ware/viewmodels/event_manager_payment_history_viewmodel.dart';
import 'package:middle_ware/widgets/custom_appbar.dart';

class EventPaymentHistoryScreen extends StatelessWidget {
  const EventPaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventManagerPaymentHistoryViewModel());

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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
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
          padding: const EdgeInsets.all(16),
          itemCount: controller.transactions.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _transactionCard(controller.transactions[index]),
            );
          },
        );
      }),
    );
  }

  Widget _transactionCard(EventManagerTransaction transaction) {
    final status = transaction.paymentStatus ?? 'unknown';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Event', transaction.event?.name ?? 'Unknown'),
          _infoRow('Buyer', transaction.buyerName ?? 'Unknown'),
          _infoRow('Quantity', _formatNumber(transaction.quantity)),
          _infoRow('Ticket Price', _formatCurrency(transaction.ticketPrice)),
          _infoRow('Amount', _formatCurrency(transaction.amount)),
          _infoRow('Platform Fee', _formatCurrency(transaction.platformFee)),
          _infoRow('Payout', _formatCurrency(transaction.payout)),
          _infoRow('Created At', _formatDate(transaction.createdAt)),
          _infoRow('Paid At', _formatDate(transaction.paidAt)),
          _infoRow(
            'Status',
            _toLabel(status),
            valueColor: _statusColor(status),
          ),
          _infoRow('Transaction ID', _shortId(transaction.transactionId)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color valueColor = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                color: valueColor,
                fontWeight: FontWeight.w600,
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

  String _formatNumber(num? value) {
    if (value == null) return '-';
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  String _toLabel(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  String _shortId(String? value) {
    if (value == null || value.isEmpty) return '-';
    if (value.length <= 18) return value;
    return '${value.substring(0, 8)}...${value.substring(value.length - 6)}';
  }

  Color _statusColor(String status) {
    final normalized = status.toLowerCase().trim();
    switch (normalized) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'refunded':
        return Colors.red;
      default:
        return Colors.black87;
    }
  }
}
