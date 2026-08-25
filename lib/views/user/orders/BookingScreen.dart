import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:middle_ware/widgets/custom_appbar.dart';
import 'package:intl/intl.dart';
import '../../../controller/user/orders/booking_controller.dart';
import 'BookingDetailsScreen.dart';
import 'package:middle_ware/core/localization/app_translations.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController downPaymentController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  Map<String, dynamic>? args;
  String? providerName;
  String? providerImage;
  String? providerAddress;
  num? servicePrice;
  String bookingSource = 'provider';
  String selectedDateDisplay = '';
  DateTime? selectedDateTime;

  final BookingController bookingController = Get.put(BookingController());

  @override
  void initState() {
    super.initState();
    args = Get.arguments;
    if (args != null) {
      providerName = args!['providerName'];
      providerImage = args!['providerImage'];
      providerAddress = args!['providerAddress'];
      bookingSource = (args!['bookingSource'] ?? 'provider')
          .toString()
          .trim();
      // For standard booking, basePrice or first slot price
      // In ProviderServiceDetailsScreen we pass servicePrice if appointmentEnabled is false
      servicePrice = args!['servicePrice'];
      if (servicePrice != null) {
        downPaymentController.text =
            (servicePrice!.toDouble() * 0.30).toStringAsFixed(2);
      }
    }
  }

  @override
  void dispose() {
    dateController.dispose();
    downPaymentController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppTranslations.translateValue("Booking")),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                    child: ClipOval(
                      child:
                          (providerImage != null && providerImage!.isNotEmpty)
                          ? Image.network(
                              providerImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person, size: 28),
                            )
                          : const Icon(Icons.person, size: 28),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        providerName ?? 'Provider Name',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        providerAddress ?? 'Address not available',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTranslations.translateValue('Date'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF2D6F5C),
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (pickedDate != null) {
                          setState(() {
                            selectedDateTime = pickedDate;
                            selectedDateDisplay = DateFormat(
                              'dd/MM/yyyy',
                            ).format(pickedDate);
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedDateDisplay.isEmpty
                                  ? "Select Date"
                                  : selectedDateDisplay,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            Icon(
                              Icons.calendar_today,
                              color: Colors.grey.shade400,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              Text(
                AppTranslations.translateValue('Down Payment'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: downPaymentController,
                keyboardType: TextInputType.number,
                readOnly: servicePrice != null,
                decoration: InputDecoration(
                  hintText: AppTranslations.translateValue('Down payment'),
                  prefixIcon: Icon(
                    Icons.attach_money,
                    size: 18,
                    color: Colors.grey[400],
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF2D6F5C)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 3),
              Text(
                AppTranslations.translateValue(
                  "Down payment must be at least 30% of the total payment.",
                ),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                AppTranslations.translateValue('Notes for User'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: AppTranslations.translateValue(
                    'Please write your note...',
                  ),
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF2D6F5C)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: bookingController.isLoading.value
                        ? null
                        : () async {
                            if (selectedDateTime == null) {
                              Get.snackbar(
                                AppTranslations.translateValue(
                                  "Validation Error",
                                ),
                                AppTranslations.translateValue(
                                  "Please select a booking date",
                                ),
                              );
                              return;
                            }
                            final double downPayment = servicePrice != null
                                ? servicePrice!.toDouble() * 0.30
                                : (double.tryParse(
                                        downPaymentController.text.trim(),
                                      ) ??
                                      0.0);
                            if (downPayment <= 0) {
                              Get.snackbar(
                                AppTranslations.translateValue(
                                  "Validation Error",
                                ),
                                AppTranslations.translateValue(
                                  "Unable to calculate down payment",
                                ),
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            final String? serviceId = args?['serviceId'];
                            if (serviceId == null) {
                              Get.snackbar(
                                AppTranslations.translateValue("Error"),
                                AppTranslations.translateValue(
                                  "Service ID not found",
                                ),
                              );
                              return;
                            }

                              final dynamic result = await bookingController
                                .createBooking(
                                  serviceId: serviceId,
                                  bookingDate: DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(selectedDateTime!),
                                  downPayment: downPayment,
                                  userNotes: notesController.text,
                                  bookingSource: bookingSource,
                                );

                            if (result != null) {
                              final bookingId =
                                  result['data']?['booking']?['_id'] ??
                                  result['data']?['_id'] ??
                                  result['_id'];

                              if (bookingId == null) {
                                Get.snackbar(
                                  AppTranslations.translateValue("Success"),
                                  "Booking created. Payment will be available after provider acceptance."
                                      .tr,
                                );
                                return;
                              }

                              Get.snackbar(
                                AppTranslations.translateValue("Success"),
                                "Booking created. Complete payment after provider accepts your request."
                                    .tr,
                              );

                              Get.to(
                                () => const BookingDetailsScreen(),
                                arguments: {
                                  'id': bookingId.toString(),
                                  'source': bookingSource,
                                },
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D6F5C),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: bookingController.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppTranslations.translateValue('Book Now'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
