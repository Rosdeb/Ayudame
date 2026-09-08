import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:middle_ware/models/business_booking_model.dart';
import 'package:middle_ware/services/business_booking_service.dart';

class BusinessBookingViewModel extends GetxController {
  final BusinessBookingService _service = BusinessBookingService();

  final RxList<BusinessBookingModel> bookingList = <BusinessBookingModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxSet<String> actioningBookingIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    isLoading.value = true;
    try {
      final bookings = await _service.getBookings();
      bookingList.assignAll(bookings);
    } finally {
      isLoading.value = false;
    }
  }

  final Rxn<BusinessBookingModel> currentBooking = Rxn<BusinessBookingModel>();

  Future<void> fetchBookingDetails(String id) async {
    isLoading.value = true;
    try {
      final booking = await _service.getBookingById(id);
      currentBooking.value = booking;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> acceptBooking(String id) async {
    return _runBookingAction(
      id: id,
      action: () => _service.acceptBooking(id),
      successMessage: "Booking accepted successfully",
    );
  }

  Future<bool> rejectBooking(String id) async {
    return _runBookingAction(
      id: id,
      action: () => _service.rejectBooking(id),
      successMessage: "Booking declined successfully",
    );
  }

  Future<bool> startBooking(String id) async {
    return _runBookingAction(
      id: id,
      action: () => _service.startBooking(id),
      successMessage: "Booking started successfully",
    );
  }

  Future<bool> completeBooking(String id) async {
    return _runBookingAction(
      id: id,
      action: () => _service.completeBooking(id),
      successMessage: "Booking completed successfully",
    );
  }

  Future<bool> requestDuePayment(String id) async {
    return _runBookingAction(
      id: id,
      action: () => _service.requestDuePayment(id),
      successMessage: "Due payment requested successfully",
    );
  }

  bool isActionInProgress(String? id) {
    if (id == null || id.isEmpty) return false;
    return actioningBookingIds.contains(id);
  }

  Future<bool> _runBookingAction({
    required String id,
    required Future<String?> Function() action,
    required String successMessage,
  }) async {
    if (id.isEmpty || actioningBookingIds.contains(id)) {
      return false;
    }

    try {
      actioningBookingIds.add(id);
      final error = await action();

      if (error == null) {

        await Future.wait([fetchBookings(), fetchBookingDetails(id)]);
        return true;
      }

      Get.snackbar(
        "Error",
        error,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return false;
    } catch (e) {
      Get.snackbar(
        "Error",
        "An error occurred: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      actioningBookingIds.remove(id);
    }
  }
}
