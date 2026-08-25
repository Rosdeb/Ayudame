class ProviderBookingModel {
  bool? success;
  List<ProviderBooking>? data;

  ProviderBookingModel({this.success, this.data});

  ProviderBookingModel.fromJson(Map<String, dynamic> json) {
    success = _toBool(json['success']);

    final rawData = json['data'];
    if (rawData is List) {
      data = rawData
          .whereType<Map>()
          .map((v) => ProviderBooking.fromJson(Map<String, dynamic>.from(v)))
          .toList();
      return;
    }

    // Fallback for wrapped payloads: { data: { bookings: [...] } }
    if (rawData is Map) {
      final nested = rawData['bookings'] ?? rawData['items'] ?? rawData['results'];
      if (nested is List) {
        data = nested
            .whereType<Map>()
            .map((v) => ProviderBooking.fromJson(Map<String, dynamic>.from(v)))
            .toList();
      }
    }
  }

  bool? _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return null;
  }
}

class ProviderBooking {
  String? id;
  String? bookingStatus;
  String? bookingFlowStatus;
  String? bookingDate;
  int? totalAmount;
  int? downPayment;
  int? dueAmount;
  int? remainingAmount;
  String? paymentStatus;
  String? paymentIntentStatus;
  String? duePaymentIntentStatus;
  String? userNotes;
  BookingUser? user;
  BookingServiceSnapshot? serviceSnapshot;

  ProviderBooking({
    this.id,
    this.bookingStatus,
    this.bookingFlowStatus,
    this.bookingDate,
    this.totalAmount,
    this.downPayment,
    this.dueAmount,
    this.remainingAmount,
    this.paymentStatus,
    this.paymentIntentStatus,
    this.duePaymentIntentStatus,
    this.userNotes,
    this.user,
    this.serviceSnapshot,
  });

  ProviderBooking.fromJson(Map<String, dynamic> json) {
    id = json['_id'] ?? json['id'];
    bookingStatus = json['bookingStatus']?.toString();
    bookingFlowStatus = json['bookingFlowStatus']?.toString();
    bookingDate = json['bookingDate']?.toString();
    // Handle int/double safety
    totalAmount = _toInt(json['totalAmount']);
    downPayment = _toInt(json['downPayment']);
    dueAmount = _toInt(json['dueAmount']);
    remainingAmount = _toInt(json['remainingAmount']);
    paymentStatus = json['paymentStatus']?.toString();
    paymentIntentStatus = json['paymentIntentStatus']?.toString();
    duePaymentIntentStatus = json['duePaymentIntentStatus']?.toString();
    userNotes = json['userNotes']?.toString();

    final userJson = json['user'] ?? json['userId'];
    if (userJson is Map) {
      user = BookingUser.fromJson(Map<String, dynamic>.from(userJson));
    }
    if (json['serviceSnapshot'] is Map) {
      serviceSnapshot = BookingServiceSnapshot.fromJson(
        Map<String, dynamic>.from(json['serviceSnapshot']),
      );
    }
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}

class BookingUser {
  String? id;
  String? fullName;
  String? email;
  String? profilePicture;
  String? phoneNumber;
  String? address;

  BookingUser({
    this.id,
    this.fullName,
    this.email,
    this.profilePicture,
    this.phoneNumber,
    this.address,
  });

  BookingUser.fromJson(Map<String, dynamic> json) {
    id = json['_id'] ?? json['id'];
    fullName = json['fullName']?.toString();
    email = json['email']?.toString();
    profilePicture = json['profilePicture']?.toString();
    phoneNumber = json['phoneNumber']?.toString();
    address = json['address']?.toString();

    final location = json['location'];
    if ((address == null || address!.isEmpty) && location is Map) {
      final locationAddress = location['address'];
      if (locationAddress is String && locationAddress.isNotEmpty) {
        address = locationAddress;
      }
    }
  }
}

class BookingServiceSnapshot {
  String? serviceName;
  String? servicePhoto;
  int? basePrice;

  BookingServiceSnapshot({this.serviceName, this.servicePhoto, this.basePrice});

  BookingServiceSnapshot.fromJson(Map<String, dynamic> json) {
    serviceName = json['serviceName']?.toString();
    servicePhoto = json['servicePhoto']?.toString();
    basePrice = _toInt(json['basePrice']);
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
