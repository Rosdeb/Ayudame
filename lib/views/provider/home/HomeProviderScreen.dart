import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:middle_ware/core/app_icons.dart';
import 'package:middle_ware/core/routes/app_routes.dart';
import 'package:middle_ware/core/theme/app_colors.dart';
import 'package:middle_ware/views/provider/profile/ProviderNotificationPage.dart';
import '../../../models/provider/provider_appointment_model.dart';
import '../../../models/provider/provider_booking_model.dart';
import '../orders/OrderProvider.dart';
import 'package:intl/intl.dart';
import '../../../controller/provider/profile/provider_profile_controller.dart';
import '../../../controller/provider/home_provider_controller.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class HomeProviderScreen extends StatefulWidget {
  const HomeProviderScreen({Key? key}) : super(key: key);

  @override
  State<HomeProviderScreen> createState() => _HomeProviderScreenState();
}

class _HomeProviderScreenState extends State<HomeProviderScreen> {
  final HomeProviderController controller = Get.put(HomeProviderController());
  final ProviderProfileController profileController = Get.put(
    ProviderProfileController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: AppColors.mainAppColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
            child: Obx(() {
              var user = profileController.providerProfile.value?.userId;
              return Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFD4B896),
                    backgroundImage:
                        user?.profilePicture != null &&
                            user!.profilePicture!.isNotEmpty
                        ? NetworkImage(user.profilePicture!)
                        : const AssetImage('assets/images/emptyUser.png')
                              as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppTranslations.translateValue('home.welcome_back'),
                          style: TextStyle(
                            fontFamily: "Inter",
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.fullName ??
                              AppTranslations.translateValue('common.unknown'),
                          style: const TextStyle(
                            fontFamily: "Inter",
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProviderNotificationPage(),
                        ),
                      );
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: SvgPicture.asset(
                        AppIcons.notification,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF2D6A4F),
                          BlendMode.srcIn,
                        ),
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),

      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.fetchBookingStats();
            await controller.fetchRecentBookings();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //  <----- end of appbar  ------>
                const SizedBox(height: 16),
                // Stats Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Obx(
                    () => Row(
                      children: [
                        _buildStatCard(
                          AppTranslations.translateValue(
                            'provider_home.total_bookings',
                          ),
                          '${controller.totalBookings.value}',
                        ),
                        const SizedBox(width: 8),
                        _buildStatCard(
                          AppTranslations.translateValue('order.completed'),
                          '${controller.completedBookings.value}',
                        ),
                        const SizedBox(width: 8),
                        _buildStatCard(
                          AppTranslations.translateValue('order.cancelled'),
                          '${controller.cancelledBookings.value}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Recent Bookings Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppTranslations.translateValue(
                          'provider_home.recent_bookings',
                        ),
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.offAllNamed(
                          AppRoutes.providerBottomNavScreen,
                          arguments: 2,
                        ),
                        child: Text(
                          AppTranslations.translateValue('common.view_all'),
                          style: TextStyle(
                            fontFamily: "Inter",
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.mainAppColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Booking Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Obx(() {
                    if (controller.pendingItems.isEmpty) {
                      return SizedBox(
                        height: 100,
                        child: Center(
                          child: Text(
                            AppTranslations.translateValue(
                              "provider_home.no_pending_bookings",
                            ),
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: controller.pendingItems.map((item) {
                        if (item is ProviderBooking) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildBookingCard(item: item),
                          );
                        } else if (item is ProviderAppointment) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildAppointmentCard(item: item),
                          );
                        }
                        return const SizedBox.shrink();
                      }).toList(),
                    );
                  }),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.mainAppColor),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: "Inter",
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontFamily: "Inter",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard({required ProviderAppointment item}) {
    String status = item.appointmentStatus?.toLowerCase() ?? 'pending';
    String dateStr = item.appointmentDate ?? '';
    try {
      if (dateStr.isNotEmpty) {
        dateStr = DateFormat('dd MMMM, yyyy').format(DateTime.parse(dateStr));
      }
    } catch (_) {}

    String timeStr = item.timeSlot?.startTime ?? '';
    if (timeStr.isNotEmpty) {
      try {
        final dt = DateFormat('HH:mm').parse(timeStr);
        timeStr = DateFormat('h:mm a').format(dt);
      } catch (_) {}
    }

    return GestureDetector(
      onTap: () {
        Get.to(() => OrderDetailsScreen(item: item, initialStatus: status));
      },
      child: _cardContainer(
        userImage: item.user?.profilePicture,
        userName: item.user?.fullName,
        dateStr: dateStr,
        timeStr: timeStr,
        note: item.userNotes,
        content: Column(
          children: [
            Row(
              children: [
                Text(
                  "${AppTranslations.translateValue('provider_home.appointment_price')}: \$${item.totalAmount ?? 0}",
                  style: const TextStyle(
                    color: Color(0xFF2C5F4F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCardButtons(status, appointmentEnabled: true),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard({required ProviderBooking item}) {
    String status = item.bookingStatus?.toLowerCase() ?? 'pending';
    String dateStr = item.bookingDate ?? '';
    try {
      if (dateStr.isNotEmpty) {
        dateStr = DateFormat('dd MMMM, yyyy').format(DateTime.parse(dateStr));
      }
    } catch (_) {}

    String timeStr = "";

    return GestureDetector(
      onTap: () {
        Get.to(() => OrderDetailsScreen(item: item, initialStatus: status));
      },
      child: _cardContainer(
        userImage: item.user?.profilePicture,
        userName: item.user?.fullName,
        dateStr: dateStr,
        timeStr: timeStr,
        note: item.userNotes,
        content: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${AppTranslations.translateValue('provider_home.total_price')}: \$${item.totalAmount ?? 0}",
                  style: const TextStyle(
                    color: Color(0xFF2C5F4F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (item.downPayment != null && item.downPayment! > 0)
                  Text(
                    "${AppTranslations.translateValue('booking.down_payment')}: \$${item.downPayment}",
                    style: const TextStyle(
                      color: Color(0xFF2C5F4F),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCardButtons(
              status,
              appointmentEnabled: false,
              bookingId: item.id,
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardContainer({
    String? userImage,
    String? userName,
    String? dateStr,
    String? timeStr,
    String? note,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: (userImage != null && userImage.isNotEmpty)
                    ? NetworkImage(userImage)
                    : const AssetImage('assets/images/emptyUser.png')
                          as ImageProvider,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName ??
                          AppTranslations.translateValue("onboarding.user"),
                      style: const TextStyle(
                        fontFamily: "Inter",
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              if (timeStr != null && timeStr.isNotEmpty)
                Text(
                  timeStr,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${AppTranslations.translateValue('common.address')}: ',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: "Inter",
                  ),
                ),
                TextSpan(
                  text: 'service.address_not_available'
                      .tr, // Real data not available yet in model
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF666666),
                    fontFamily: "Inter",
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${AppTranslations.translateValue('common.date')}: ',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: "Inter",
                  ),
                ),
                TextSpan(
                  text: dateStr ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF666666),
                    fontFamily: "Inter",
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${AppTranslations.translateValue('provider_home.problem_note')}:',
            style: TextStyle(
              fontFamily: "Inter",
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            note ?? AppTranslations.translateValue("booking.no_notes_provided"),
            style: const TextStyle(
              fontFamily: "Inter",
              fontSize: 12,
              color: Color(0xFF666666),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildCardButtons(
    String status, {
    bool appointmentEnabled = false,
    String? bookingId,
  }) {
    status = status.toLowerCase();

    if (appointmentEnabled) {
      if (status == "confirmed") {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C5F4F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              AppTranslations.translateValue("order.confirmed"),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontFamily: "Inter",
              ),
            ),
          ),
        );
      }

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    side: const BorderSide(color: AppColors.mainAppColor),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    AppTranslations.translateValue("common.reschedule"),
                    style: const TextStyle(
                      color: AppColors.mainAppColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Inter",
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C5F4F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    AppTranslations.translateValue("common.accept"),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Inter",
                    ),
                  ),
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () => _showConfirmationDialog(
              context,
              AppTranslations.translateValue(
                "provider_home.cancel_appointment_action",
              ),
            ),
            child: Text(
              AppTranslations.translateValue("common.cancel"),
              style: const TextStyle(
                color: Color(0xFFE74C3C),
                fontWeight: FontWeight.w600,
                fontFamily: "Inter",
              ),
            ),
          ),
        ],
      );
    } else if (status == "pending") {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    side: const BorderSide(color: AppColors.mainAppColor),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    AppTranslations.translateValue("common.reschedule"),
                    style: const TextStyle(
                      color: AppColors.mainAppColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Inter",
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() {
                  final bool isAccepting =
                      bookingId != null &&
                      bookingId.isNotEmpty &&
                      controller.acceptingBookingIds.contains(bookingId);
                  return ElevatedButton(
                    onPressed:
                        (bookingId == null || bookingId.isEmpty || isAccepting)
                        ? null
                        : () => controller.acceptBooking(bookingId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C5F4F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isAccepting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppTranslations.translateValue("common.accept"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Inter",
                            ),
                          ),
                  );
                }),
              ),
            ],
          ),
          TextButton(
            onPressed: () => _showConfirmationDialog(
              context,
              AppTranslations.translateValue(
                "provider_home.cancel_order_action",
              ),
            ),
            child: Text(
              AppTranslations.translateValue("common.cancel"),
              style: const TextStyle(
                color: Color(0xFFE74C3C),
                fontWeight: FontWeight.w600,
                fontFamily: "Inter",
              ),
            ),
          ),
        ],
      );
    } else if (status == "cancelled" || status == "rejected") {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            _translateStatusLabel(status),
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
              fontFamily: "Inter",
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2C5F4F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            _translateStatusLabel(status),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontFamily: "Inter",
            ),
          ),
        ),
      );
    }
  }

  void _showConfirmationDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 40,
            ),
            const SizedBox(height: 16),
            Text(
              "provider_home.confirm_action_message".trParams({
                "action": message,
              }),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: "Inter",
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2C5F4F)),
                    ),
                    child: Text(
                      AppTranslations.translateValue("common.no"),
                      style: const TextStyle(color: Color(0xFF2C5F4F)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Handle cancellation logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C5F4F),
                    ),
                    child: Text(
                      AppTranslations.translateValue("common.yes"),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _translateStatusLabel(String status) {
    final normalized = status.trim().toLowerCase();
    switch (normalized) {
      case 'pending':
        return AppTranslations.translateValue('order.pending');
      case 'confirmed':
        return AppTranslations.translateValue('order.confirmed');
      case 'completed':
        return AppTranslations.translateValue('order.completed');
      case 'cancelled':
        return AppTranslations.translateValue('order.cancelled');
      case 'rejected':
        return AppTranslations.translateValue('order.rejected');
      case 'accepted':
        return AppTranslations.translateValue('order.accepted');
      case 'in progress':
      case 'in_progress':
        return AppTranslations.translateValue('order.in_progress');
      case 'ongoing':
        return AppTranslations.translateValue('order.ongoing');
      default:
        return status;
    }
  }
}
