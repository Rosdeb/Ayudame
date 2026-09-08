import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/user/orders/order_model.dart';
import '../../../controller/user/orders/booking_details_controller.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class BookingDetailsScreen extends StatefulWidget {
  const BookingDetailsScreen({Key? key}) : super(key: key);

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final BookingDetailsController controller = Get.put(
    BookingDetailsController(),
  );

  @override
  void initState() {
    super.initState();
    final dynamic args = Get.arguments;
    if (args is Map) {
      final String? id = args['id']?.toString();
      final String source = (args['source'] ?? OrderSource.provider).toString();
      if (id != null && id.isNotEmpty) {
        controller.fetchBookingDetails(id, source: source);
      }
    } else if (args is OrderModel && args.id != null) {
      controller.fetchBookingDetails(args.id!, source: args.source);
    } else if (args is String) {
      controller.fetchBookingDetails(args, source: OrderSource.provider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F5),
      body: Column(
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
                      Icons.arrow_back_ios, color: Colors.white, size: 20),
                  onPressed: () => Get.back(),
                ),
                Expanded(
                  child: Text(
                    AppTranslations.translateValue("Booking details"),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1E523F)),
                );
              }

              final order = controller.booking.value;
              if (order == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppTranslations.translateValue(
                            "Booking details not found"),
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

              final String status = (order.overallStatus).toLowerCase();
              final String normalizedStatus = status
                  .replaceAll('-', '_')
                  .replaceAll(' ', '_');
              final String paymentStatus = (order.paymentStatus ?? '')
                  .toLowerCase();
              final String paymentIntentStatus = (order.paymentIntentStatus ??
                  '')
                  .toLowerCase();
              final bool hasPaymentIntent =
                  (order.paymentIntentId ?? '')
                      .trim()
                      .isNotEmpty ||
                      paymentIntentStatus.isNotEmpty;
              final bool isPaymentCompleted =
                  paymentStatus == 'completed' ||
                      paymentStatus == 'offline_paid' ||
                      paymentStatus == 'refunded';
              final bool canPayDue = paymentStatus == 'due_requested';
              final bool downPaymentSettled =
                  paymentStatus == 'authorized' ||
                      (paymentStatus == 'partial' &&
                          (paymentIntentStatus == 'succeeded' ||
                              paymentIntentStatus == 'requires_capture' ||
                              paymentIntentStatus == 'processing'));
              final bool waitingForProvider =
                  !hasPaymentIntent &&
                      !isPaymentCompleted &&
                      !canPayDue &&
                      normalizedStatus != 'cancelled' &&
                      normalizedStatus != 'rejected';
              final bool waitingForDueRequest =
                  downPaymentSettled &&
                      !canPayDue &&
                      !isPaymentCompleted &&
                      normalizedStatus != 'cancelled' &&
                      normalizedStatus != 'rejected';
              final bool showSplitPayment =
                  paymentStatus == 'pending' ||
                      paymentStatus == 'authorized' ||
                      paymentStatus == 'partial' ||
                      paymentStatus == 'due_requested';
              final num downPaymentAmount = order.downPayment ?? 0;
              final num dueAmount = order.remainingAmount ?? 0;
              final num totalAmount = order.totalAmount ?? 0;

              return SingleChildScrollView(
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
                      // Provider Row
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
                                ),
                                Text(
                                  order.provider?.user?.address ??
                                      order.provider?.occupation ??
                                      '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Date: ${order.bookingDate?.split('T')[0] ??
                                    ''}",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Title
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

                      // Note
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
                      const SizedBox(height: 24),

                      // Payment Info
                      if (showSplitPayment)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppTranslations.translateValue(
                                "Down Payment: \$$downPaymentAmount",
                              ),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ),
                            Text(
                              AppTranslations.translateValue(
                                "Due: \$$dueAmount",
                              ),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E4F),
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          AppTranslations.translateValue(
                            "Price: \$$totalAmount",
                          ),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                      if (waitingForProvider) ...[
                        const SizedBox(height: 14),
                        _buildInfoBox(
                          message: "Payment will be available after provider accepts your booking.",
                        ),
                      ],
                      if (waitingForDueRequest) ...[
                        const SizedBox(height: 14),
                        _buildInfoBox(
                          message: "Down payment received. Due payment will be enabled after provider request.",
                        ),
                      ],
                      const SizedBox(height: 32),

                      // Buttons Logic
                      _buildActionButtons(status, order),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String status, OrderModel order) {
    final String normalizedStatus = status
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
    final String bookingId = order.id ?? "";
    final String paymentStatus = (order.paymentStatus ?? '').toLowerCase();
    final String paymentIntentStatus = (order.paymentIntentStatus ?? '')
        .toLowerCase();
    final bool hasPaymentIntent =
        (order.paymentIntentId ?? '')
            .trim()
            .isNotEmpty ||
            paymentIntentStatus.isNotEmpty;
    final bool canPayDue = paymentStatus == 'due_requested';
    final bool isPaymentCompleted =
        paymentStatus == 'completed' ||
            paymentStatus == 'offline_paid' ||
            paymentStatus == 'refunded';
    final bool downPaymentSettled =
        paymentStatus == 'authorized' ||
            (paymentStatus == 'partial' &&
                (paymentIntentStatus == 'succeeded' ||
                    paymentIntentStatus == 'requires_capture' ||
                    paymentIntentStatus == 'processing'));
    final bool canPayDown =
        !isPaymentCompleted &&
            !canPayDue &&
            hasPaymentIntent &&
            !downPaymentSettled;
    final bool canPayNow = canPayDue || canPayDown;
    final bool isClosedStatus =
        normalizedStatus == 'cancelled' || normalizedStatus == 'rejected';
    final bool canTriggerPayment =
        canPayNow && bookingId.isNotEmpty && !isClosedStatus;
    final bool canCancel =
        normalizedStatus == 'pending' ||
            normalizedStatus == 'accepted' ||
            normalizedStatus == 'confirmed' ||
            normalizedStatus == 'in_progress';
    final bool hasReviewed = (order.reviewedAt ?? '')
        .trim()
        .isNotEmpty;
    final bool canReview = normalizedStatus == 'completed' && !hasReviewed;
    String paymentButtonLabel = 'Payment Unavailable';

    if (canPayDue) {
      paymentButtonLabel = 'Pay Due Payment';
    } else if (canPayDown) {
      paymentButtonLabel = 'Pay Down Payment';
    } else if (downPaymentSettled) {
      paymentButtonLabel = 'Down Payment Paid';
    } else if (isPaymentCompleted) {
      paymentButtonLabel = 'Payment Completed';
    } else if (!hasPaymentIntent) {
      paymentButtonLabel = 'Waiting for Provider';
    }

    final List<Widget> actionButtons = [];
    if (canReview) {
      actionButtons.add(
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: Text(AppTranslations.translateValue("Confirmation")),
                  content: Text(
                    "Are you sure you want to submit review now?".tr,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        AppTranslations.translateValue("No"),
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        controller.showRatingDialog(
                          bookingId,
                          order.provider?.user?.fullName ?? 'Provider',
                        );
                      },
                      child: Text(
                        AppTranslations.translateValue("Yes"),
                        style: TextStyle(color: Color(0xFF1E523F)),
                      ),
                    ),
                  ],
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              AppTranslations.translateValue("Leave Review"),
              style: TextStyle(
                color: Color(0xFF1B5E4F),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    if (canTriggerPayment) {
      if (actionButtons.isNotEmpty) {
        actionButtons.add(const SizedBox(width: 12));
      }
      actionButtons.add(
        Expanded(
          child: ElevatedButton(
            onPressed: () => controller.payDue(bookingId),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E523F),
              disabledBackgroundColor: Colors.grey.shade400,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              paymentButtonLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    if (actionButtons.isNotEmpty || canCancel || hasReviewed) {
      return Column(
        children: [
          if (actionButtons.isNotEmpty) Row(children: actionButtons),
          if (hasReviewed) ...[
            if (actionButtons.isNotEmpty) const SizedBox(height: 12),
            _buildInfoBox(
              message: "Review already submitted for this booking.",
            ),
          ],
          if (canCancel) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: bookingId.isEmpty
                    ? null
                    : () => controller.cancelBooking(bookingId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7D7D),
                  disabledBackgroundColor: Colors.grey.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  AppTranslations.translateValue("Cancel Booking"),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          if (actionButtons.isEmpty && !canCancel && !hasReviewed) ...[
            const SizedBox(height: 12),
            _buildStatusIndicator(normalizedStatus),
          ],
        ],
      );
    }

    return _buildStatusIndicator(normalizedStatus);
  }

  Widget _buildStatusIndicator(String status) {
    final String normalizedStatus = status
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
    Color btnColor = Colors.grey.shade400;
    if (normalizedStatus == 'completed') btnColor = const Color(0xFF1E523F);
    if (normalizedStatus == 'cancelled' || normalizedStatus == 'rejected') {
      btnColor = const Color(0xFFB23B3B);
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: btnColor,
          disabledBackgroundColor: btnColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          _formatStatusLabel(normalizedStatus),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox({required String message}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFF8A5A00), fontSize: 13),
      ),
    );
  }

  String _formatStatusLabel(String status) {
    final normalized = status.trim().replaceAll('_', ' ').replaceAll('-', ' ');
    if (normalized.isEmpty) return 'Pending';
    return normalized
        .split(' ')
        .where((word) =>
    word
        .trim()
        .isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}
