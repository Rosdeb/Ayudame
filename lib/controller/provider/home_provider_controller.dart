import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:middle_ware/utils/constants.dart';
import 'package:middle_ware/views/components/floatingbar.dart';
import 'package:middle_ware/views/components/successbar.dart';

import '../../models/provider/provider_booking_model.dart';
import '../../models/provider/provider_appointment_model.dart';
import '../../services/api_service.dart'; // Optional if we want appointments too

class HomeProviderController extends GetxController {
  var isLoading = false.obs;
  var acceptingBookingIds = <String>{}.obs;

  // Stats
  var totalBookings = 0.obs;
  var completedBookings = 0.obs;
  var cancelledBookings = 0.obs;

  var allBookings = <ProviderBooking>[].obs;
  var allAppointments = <ProviderAppointment>[].obs;
  var pendingItems = <dynamic>[].obs;

  var myOrdersTotal = 0.obs;
  var myOrdersThisMonth = 0.obs;
  var incomeTotal = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookingStats();
    fetchRecentBookings();
  }

  Future<void> fetchRecentBookings() async {
    try {
      final responses = await Future.wait([
        ApiService.get(
          endpoint: '/api/providers/bookings',
        ),
        ApiService.get(
          endpoint: '/api/providers/appointments',
        ),
      ]);

      if (responses[0].statusCode == 200) {
        var jsonResponse = json.decode(responses[0].body);
        var model = ProviderBookingModel.fromJson(jsonResponse);
        if (model.data != null) {
          allBookings.value = model.data!;
        }
      }

      if (responses[1].statusCode == 200) {
        var jsonResponse = json.decode(responses[1].body);
        var model = ProviderAppointmentModel.fromJson(jsonResponse);
        if (model.data != null) {
          allAppointments.value = model.data!;
        }
      }

      _updatePendingItems();
    } catch (e) {
      print("Error fetching recent data: $e");
    }
  }

  void _updatePendingItems() {
    List<dynamic> combined = [];

    combined.addAll(
      allBookings.where((e) => e.bookingStatus?.toLowerCase() == 'pending'),
    );
    combined.addAll(
      allAppointments.where(
        (e) => e.appointmentStatus?.toLowerCase() == 'pending',
      ),
    );

    // Sort by createdAt if available, otherwise just use them as is
    pendingItems.value = combined;
  }

  Future<void> fetchBookingStats() async {
    try {
      isLoading(true);

      var response = await ApiService.get(
        endpoint: '/api/providers/bookings/stats',
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          var homeStats = jsonResponse['data']['homeStats'];
          if (homeStats != null) {
            totalBookings.value =
                homeStats['totalServiceAndAppointmentBooking'] ?? 0;
            completedBookings.value =
                homeStats['completedServiceAndAppointmentBooking'] ?? 0;
            cancelledBookings.value =
                homeStats['cancelledServiceAndAppointmentBooking'] ?? 0;
          }

          var profileStats = jsonResponse['data']['profileStats'];
          if (profileStats != null) {
            var myOrders = profileStats['myOrders'];
            if (myOrders != null) {
              myOrdersTotal.value = myOrders['total'] ?? 0;
              myOrdersThisMonth.value = myOrders['thisMonth'] ?? 0;
            }
            var income = profileStats['totalIncome'];
            if (income != null) {
              incomeTotal.value = income['total'] ?? 0;
            }
          }
        }
      } else {
        print("Failed to fetch stats: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching stats: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> acceptBooking(BuildContext context ,String bookingId, {String? providerNotes}) async {
    if (bookingId.isEmpty || acceptingBookingIds.contains(bookingId)) {
      return;
    }

    try {
      acceptingBookingIds.add(bookingId);

      final response = await ApiService.patch(
        endpoint: '/api/providers/bookings/$bookingId/accept',
        body: {
          if (providerNotes != null && providerNotes.trim().isNotEmpty)
            'providerNotes': providerNotes.trim(),
        },
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        FloatingSuccessBar.show(context, message: "Booking accepted successfully");

        await fetchRecentBookings();
        await fetchBookingStats();
      } else {
        FloatingErrorBar.show(context, message: jsonResponse['message']?.toString() ?? 'Failed to accept booking');
      }
    } catch (e) {
      FloatingErrorBar.show(context, message: 'Failed to accept booking. Please try again.');
    } finally {
      acceptingBookingIds.remove(bookingId);
    }
  }
}
