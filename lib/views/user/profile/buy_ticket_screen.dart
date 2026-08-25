import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:middle_ware/widgets/custom_appbar.dart';
import '../../../controller/user/home/buy_ticket_controller.dart';
import '../../../models/user/home/ticket_purchase_model.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class BuyTicketScreen extends StatefulWidget {
  final String eventId;
  final int availableTickets;
  final double ticketPrice;

  const BuyTicketScreen({
    super.key,
    required this.eventId,
    required this.availableTickets,
    this.ticketPrice = 0,
  });

  @override
  State<BuyTicketScreen> createState() => _BuyTicketScreenState();
}

class _BuyTicketScreenState extends State<BuyTicketScreen> {
  int ticketCount = 1;
  final Set<int> sameAsBeforeIndices = {};

  final List<TextEditingController> nameControllers = [];
  final List<TextEditingController> idControllers = [];
  final List<String> selectedIdTypes = [];

  final BuyTicketController controller = Get.put(BuyTicketController());

  double get _ticketPrice => widget.ticketPrice < 0 ? 0 : widget.ticketPrice;
  double get _totalPrice => _ticketPrice * ticketCount;

  int get _maxSelectableTickets {
    final int safeAvailable = widget.availableTickets < 0
        ? 0
        : widget.availableTickets;
    return safeAvailable > 10 ? 10 : safeAvailable;
  }

  @override
  void initState() {
    super.initState();
    if (_maxSelectableTickets == 0) {
      ticketCount = 0;
    }
    _syncControllers();
  }

  void _syncControllers() {
    if (nameControllers.length < ticketCount) {
      for (int i = nameControllers.length; i < ticketCount; i++) {
        nameControllers.add(TextEditingController());
        idControllers.add(TextEditingController());
        selectedIdTypes.add('Passport');
      }
    } else if (nameControllers.length > ticketCount) {
      for (int i = nameControllers.length; i > ticketCount; i--) {
        nameControllers.removeLast().dispose();
        idControllers.removeLast().dispose();
        selectedIdTypes.removeLast();
      }
    }
    sameAsBeforeIndices.removeWhere(
      (index) => index <= 0 || index >= ticketCount,
    );
  }

  @override
  void dispose() {
    for (final textController in nameControllers) {
      textController.dispose();
    }
    for (final textController in idControllers) {
      textController.dispose();
    }
    super.dispose();
  }

  void _handlePurchase() {
    if (ticketCount < 1 || _maxSelectableTickets < 1) {
      Get.snackbar(
        AppTranslations.translateValue("Sold Out"),
        AppTranslations.translateValue("No tickets are available right now"),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (ticketCount > _maxSelectableTickets) {
      setState(() {
        ticketCount = _maxSelectableTickets;
        _syncControllers();
      });
      Get.snackbar(
        AppTranslations.translateValue("Limit Reached"),
        AppTranslations.translateValue(
          "You cannot buy more than available tickets",
        ),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (nameControllers.any((c) => c.text.trim().isEmpty) ||
        idControllers.any((c) => c.text.trim().isEmpty)) {
      Get.snackbar(
        AppTranslations.translateValue("Error"),
        AppTranslations.translateValue("Please fill all fields"),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final List<TicketOwner> owners = List.generate(
      ticketCount,
      (i) => TicketOwner(
        name: nameControllers[i].text.trim(),
        identificationType: selectedIdTypes[i],
        identificationNumber: idControllers[i].text.trim(),
      ),
    );

    controller.purchaseTicket(widget.eventId, ticketCount, owners);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F5),
      appBar: CustomAppBar(title: AppTranslations.translateValue("Buy Ticket")),
      body: Obx(() {
        final bool canBuy =
            !controller.isLoading.value && _maxSelectableTickets > 0;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPurchaseOverviewCard(),
                    SizedBox(height: 16.h),
                    _buildQuantitySelectorCard(),
                    SizedBox(height: 20.h),
                    if (ticketCount < 1)
                      _buildSoldOutCard()
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: ticketCount,
                        separatorBuilder: (_, __) => SizedBox(height: 14.h),
                        itemBuilder: (context, index) =>
                            _buildTicketForm(index),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: canBuy ? _handlePurchase : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E4E),
                  elevation: 0,
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${AppTranslations.translateValue("Total")}: \$${_totalPrice.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                AppTranslations.translateValue("Purchase Now"),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPurchaseOverviewCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF2B7B64), Color(0xFF174739)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E4E).withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.confirmation_num_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTranslations.translateValue("Ticket Checkout"),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      AppTranslations.translateValue(
                        "Fill passenger details before payment",
                      ),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildMetaPill(
                icon: Icons.local_activity_outlined,
                title: AppTranslations.translateValue("Ticket price"),
                value: "\$${_ticketPrice.toStringAsFixed(2)}",
              ),
              _buildMetaPill(
                icon: Icons.group_outlined,
                title: AppTranslations.translateValue("Selected"),
                value: ticketCount.toString().padLeft(2, '0'),
              ),
              _buildMetaPill(
                icon: Icons.payments_outlined,
                title: AppTranslations.translateValue("Total"),
                value: "\$${_totalPrice.toStringAsFixed(2)}",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaPill({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: Colors.white),
          SizedBox(width: 6.w),
          Text(
            "$title: $value",
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelectorCard() {
    final double progress = _maxSelectableTickets > 0
        ? ticketCount / _maxSelectableTickets
        : 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFD8E6E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTranslations.translateValue("Number of tickets"),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF153F32),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildCounterButton(
                icon: Icons.remove_rounded,
                onTap: () {
                  if (ticketCount > 1) {
                    setState(() {
                      ticketCount--;
                      _syncControllers();
                    });
                  }
                },
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFF1B5E4E)),
                    color: const Color(0xFFF4FAF8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        ticketCount.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1B5E4E),
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        AppTranslations.translateValue("Tickets"),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildCounterButton(
                icon: Icons.add_rounded,
                onTap: () {
                  if (_maxSelectableTickets < 1) {
                    Get.snackbar(
                      AppTranslations.translateValue("Sold Out"),
                      AppTranslations.translateValue(
                        "No tickets are available right now",
                      ),
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                    return;
                  }

                  if (ticketCount < _maxSelectableTickets) {
                    setState(() {
                      ticketCount++;
                      _syncControllers();
                    });
                  } else {
                    Get.snackbar(
                      AppTranslations.translateValue("Limit Reached"),
                      AppTranslations.translateValue(
                        "You cannot buy more than available tickets",
                      ),
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    );
                  }
                },
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 7.h,
              backgroundColor: const Color(0xFFEAF3F0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF1B8C78),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "${AppTranslations.translateValue("Available tickets")}: ${widget.availableTickets}   |   ${AppTranslations.translateValue("Max per order")}: $_maxSelectableTickets",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoldOutCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              AppTranslations.translateValue(
                "No tickets are available right now",
              ),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8A2C2C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: const Color(0xFF1B5E4E),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B5E4E).withValues(alpha: 0.22),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 22.sp),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Color(0xFFBFD5CE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Color(0xFFBFD5CE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Color(0xFF1B8C78), width: 1.5),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FCFB),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1E3C34),
      ),
    );
  }

  Widget _buildTicketForm(int index) {
    final bool isFirst = index == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isFirst)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () {
                setState(() {
                  if (sameAsBeforeIndices.contains(index)) {
                    sameAsBeforeIndices.remove(index);
                  } else {
                    sameAsBeforeIndices.add(index);
                    nameControllers[index].text =
                        nameControllers[index - 1].text;
                    idControllers[index].text = idControllers[index - 1].text;
                    selectedIdTypes[index] = selectedIdTypes[index - 1];
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5F1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFC7E0D7)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      sameAsBeforeIndices.contains(index)
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: const Color(0xFF1B5E4E),
                      size: 18.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      AppTranslations.translateValue("Same as before"),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1B5E4E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFFD7E8E2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E4E),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      "${AppTranslations.translateValue("Ticket")} ${index + 1}",
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  if (isFirst)
                    Text(
                      AppTranslations.translateValue("Primary holder"),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 14.h),
              _fieldLabel(AppTranslations.translateValue("Ticket owner name")),
              SizedBox(height: 7.h),
              TextFormField(
                controller: nameControllers[index],
                decoration: _inputDecoration(
                  hint: AppTranslations.translateValue("Enter name"),
                ),
              ),
              SizedBox(height: 14.h),
              _fieldLabel(AppTranslations.translateValue("Select ID Type")),
              SizedBox(height: 7.h),
              DropdownButtonFormField<String>(
                initialValue: selectedIdTypes[index],
                items: const ['Passport', 'NID', 'Driving License']
                    .map(
                      (type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    selectedIdTypes[index] = value;
                  });
                },
                decoration: _inputDecoration(hint: ''),
              ),
              SizedBox(height: 14.h),
              _fieldLabel(
                AppTranslations.translateValue("Identification number"),
              ),
              SizedBox(height: 7.h),
              TextFormField(
                controller: idControllers[index],
                decoration: _inputDecoration(
                  hint: AppTranslations.translateValue("*****************"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
