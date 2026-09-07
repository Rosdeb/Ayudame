import 'package:flutter/material.dart';
import 'package:middle_ware/core/theme/app_colors.dart';
import 'package:middle_ware/views/components/custom_app_bar.dart';
import 'package:get/get.dart';
import '../../../controller/user/orders/order_controller.dart';
import '../../../models/user/orders/order_model.dart';
import 'AppointmentDetailsScreen.dart';
import 'BookingDetailsScreen.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final OrderController _controller = Get.put(
    OrderController(),
    permanent: false,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: CustomAppBar(
        onBackTap: (){
          Navigator.pop(context);
        },
        title: AppTranslations.translateValue("Order History",),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // Tabs
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildTab('Appointment'),
                const SizedBox(width: 8),
                _buildTab('Pending'),
                const SizedBox(width: 8),
                _buildTab('Accepted'),
                const SizedBox(width: 8),
                _buildTab('Confirmed'),
                const SizedBox(width: 8),
                _buildTab('Completed'),
                const SizedBox(width: 8),
                _buildTab('Cancelled'),
                const SizedBox(width: 8),
                _buildTab('Rejected'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Order List
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2D5F4C)),
                );
              }

              if (_controller.orderList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No ${_controller.currentTab.value.toLowerCase()} found",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _controller.orderList.length,
                itemBuilder: (context, index) {
                  final order = _controller.orderList[index];
                  return GestureDetector(
                    onTap: () => _navigateToDetails(order),
                    child: _buildOrderCard(order),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title) {
    return Obx(() {
      final isSelected = _controller.currentTab.value == title;
      return GestureDetector(
        onTap: () {
          _controller.changeTab(title);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2D5F4C) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2D5F4C)
                  : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildOrderCard(OrderModel order) {
    final String status = order.overallStatus;
    final String normalizedStatus = _normalizeStatus(status);
    Color statusBgColor = Colors.grey;

    if (normalizedStatus == 'pending') {
      statusBgColor = const Color(0xFFD9824B); // Muted orange from image
    } else if (normalizedStatus == 'confirmed' ||
        normalizedStatus == 'accepted' ||
        normalizedStatus == 'ongoing' ||
        normalizedStatus == 'in_progress') {
      statusBgColor = const Color(0xFF2D5F4C);
    } else if (normalizedStatus == 'completed') {
      statusBgColor = Colors.green;
    } else if (normalizedStatus == 'cancelled' ||
        normalizedStatus == 'rejected' ||
        normalizedStatus == 'no_show') {
      statusBgColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar, Name/Rating, Date
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    (order.provider?.user?.profilePicture != null &&
                        order.provider!.user!.profilePicture!.isNotEmpty)
                    ? NetworkImage(order.provider!.user!.profilePicture!)
                    : null,
                child:
                    (order.provider?.user?.profilePicture == null ||
                        order.provider!.user!.profilePicture!.isEmpty)
                    ? const Icon(Icons.person, color: Colors.grey, size: 30)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.provider?.user?.fullName ?? 'Provider Name',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 20, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          "${order.provider?.rating ?? 0.0}(${order.provider?.totalReviews ?? 0})",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                order.overallDate?.split('T')[0] ?? '',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Service Name
          Text(
            order.serviceSnapshot?.serviceName ?? 'Service Name',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),

          // Bottom Row: Price and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.isAppointment ? "Appointment Price" : "Service Price"}:\$${order.totalAmount ?? 0}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E4F), // Dark green for price
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _formatStatusLabel(normalizedStatus),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToDetails(OrderModel order) {
    if (order.isAppointment) {
      Get.to(() => const AppointmentDetailsScreen(), arguments: order);
    } else {
      Get.to(() => const BookingDetailsScreen(), arguments: order);
    }
  }

  String _normalizeStatus(String status) {
    return status
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_')
        .trim();
  }

  String _formatStatusLabel(String status) {
    final normalized = status.replaceAll('_', ' ').trim();
    if (normalized.isEmpty) return 'Pending';
    return normalized
        .split(' ')
        .where((word) => word.trim().isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}
