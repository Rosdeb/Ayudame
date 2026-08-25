import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/user/orders/order_model.dart';
import '../../../controller/user/service/appointment_details_controller.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  const AppointmentDetailsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentDetailsScreen> createState() =>
      _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  final AppointmentDetailsController controller = Get.put(
    AppointmentDetailsController(),
  );

  @override
  void initState() {
    super.initState();
    final dynamic args = Get.arguments;
    if (args is Map) {
      final String? id = args['id']?.toString();
      final String source = (args['source'] ?? OrderSource.provider).toString();
      if (id != null && id.isNotEmpty) {
        controller.fetchAppointmentDetails(id, source: source);
      }
    } else if (args is OrderModel && args.id != null) {
      controller.fetchAppointmentDetails(args.id!, source: args.source);
    } else if (args is String) {
      controller.fetchAppointmentDetails(args, source: OrderSource.provider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F5),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1E523F)),
          );
        }

        final order = controller.appointment.value;
        if (order == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppTranslations.translateValue(
                    "Appointment details not found",
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text(AppTranslations.translateValue("Go Back")),
                ),
              ],
            ),
          );
        }

        final String status = (order.appointmentStatus ?? 'pending')
            .toLowerCase()
            .replaceAll('-', '_')
            .replaceAll(' ', '_');
        final String paymentStatus = (order.paymentStatus ?? 'pending')
            .toLowerCase();
        final String paymentIntentStatus = (order.paymentIntentStatus ?? '')
            .toLowerCase();
        final bool hasPaymentIntent =
            (order.paymentIntentId ?? '').trim().isNotEmpty ||
            paymentIntentStatus.isNotEmpty;
        final bool providerAccepted =
            status == 'confirmed' || status == 'in_progress';
        final bool isClosedStatus =
            status == 'cancelled' || status == 'rejected' || status == 'no_show';
        final bool paymentDone =
            paymentStatus == 'completed' ||
            paymentStatus == 'offline_paid' ||
            paymentStatus == 'refunded';
        final bool canPayNow =
            providerAccepted && hasPaymentIntent && !paymentDone;
        final bool waitingForProvider =
            !providerAccepted &&
            !paymentDone &&
            !isClosedStatus &&
            status != 'completed';
        final bool waitingForIntent =
            providerAccepted &&
            !hasPaymentIntent &&
            !paymentDone &&
            !isClosedStatus;

        return Column(
          children: [
            // Custom Curved Header
            Container(
              height: 120,
              padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF1E523F),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Get.back(),
                  ),
                  Expanded(
                    child: Text(
                      AppTranslations.translateValue("Appointment details"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey[200],
                            backgroundImage:
                                (order.provider?.user?.profilePicture != null &&
                                    order
                                        .provider!
                                        .user!
                                        .profilePicture!
                                        .isNotEmpty)
                                ? NetworkImage(
                                    order.provider!.user!.profilePicture!,
                                  )
                                : null,
                            child:
                                (order.provider?.user?.profilePicture == null ||
                                    order
                                        .provider!
                                        .user!
                                        .profilePicture!
                                        .isEmpty)
                                ? const Icon(Icons.person, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.provider?.user?.fullName ??
                                      'No Provider Name',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Date: ${order.appointmentDate?.split('T')[0] ?? ''}",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Text(
                        AppTranslations.translateValue("Title:"),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D6E5C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        order.serviceSnapshot?.serviceName ??
                            "Expert House Cleaning Services",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.7),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        AppTranslations.translateValue("Note"),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D6E5C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF2D6E5C).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          order.userNotes ?? "No notes provided",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.6),
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Duration:${order.selectedSlot?.duration ?? '02'} ${order.selectedSlot?.durationUnit ?? 'hour'}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D6E5C),
                            ),
                          ),
                          Text(
                            AppTranslations.translateValue(
                              "Price:\$${order.totalAmount ?? 0}",
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D6E5C),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppTranslations.translateValue("Date"),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    order.overallDate?.split('T')[0] ??
                                        "08/09/2025",
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppTranslations.translateValue("Time"),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    order.timeSlot?.startTime ?? "10:20 AM",
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      if (waitingForProvider) ...[
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Text(
                            "Payment will be available after provider accepts your appointment."
                                .tr,
                            style: TextStyle(
                              color: Color(0xFF8A5A00),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],

                      if (waitingForIntent) ...[
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Text(
                            "Payment is being prepared. Please refresh and try again shortly."
                                .tr,
                            style: TextStyle(
                              color: Color(0xFF8A5A00),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],

                      if (canPayNow) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                (controller.isLoading.value || order.id == null)
                                ? null
                                : () => controller.payAppointment(order.id!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E523F),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              AppTranslations.translateValue("Pay Appointment"),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _statusButtonColor(status),
                            disabledBackgroundColor: _statusButtonColor(status),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            _formatStatusLabel(status),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Color _statusButtonColor(String status) {
    if (status == 'completed') return const Color(0xFF1E523F);
    if (status == 'cancelled' || status == 'rejected' || status == 'no_show') {
      return const Color(0xFFB23B3B);
    }
    return Colors.grey.shade500;
  }

  String _formatStatusLabel(String status) {
    final normalized = status.trim().replaceAll('_', ' ').replaceAll('-', ' ');
    if (normalized.isEmpty) return 'Pending';
    return normalized
        .split(' ')
        .where((word) => word.trim().isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}
