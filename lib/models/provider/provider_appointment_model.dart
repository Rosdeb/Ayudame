class ProviderAppointmentModel {
  bool? success;
  List<ProviderAppointment>? data;

  ProviderAppointmentModel({this.success, this.data});

  ProviderAppointmentModel.fromJson(Map<String, dynamic> json) {
    success = _toBool(json['success']);

    final rawData = json['data'];
    if (rawData is List) {
      data = rawData
          .whereType<Map>()
          .map((v) => ProviderAppointment.fromJson(Map<String, dynamic>.from(v)))
          .toList();
      return;
    }

    // Fallback for wrapped payloads: { data: { appointments: [...] } }
    if (rawData is Map) {
      final nested =
          rawData['appointments'] ?? rawData['items'] ?? rawData['results'];
      if (nested is List) {
        data = nested
            .whereType<Map>()
            .map(
              (v) => ProviderAppointment.fromJson(Map<String, dynamic>.from(v)),
            )
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

class ProviderAppointment {
  String? id;
  String? appointmentStatus;
  String? appointmentDate;
  int? totalAmount;
  int? downPayment;
  String? userNotes;
  AppointmentUser? user;
  AppointmentServiceSnapshot? serviceSnapshot;
  AppointmentSelectedSlot? selectedSlot;
  AppointmentTimeSlot? timeSlot;

  ProviderAppointment({
    this.id,
    this.appointmentStatus,
    this.appointmentDate,
    this.totalAmount,
    this.downPayment,
    this.userNotes,
    this.user,
    this.serviceSnapshot,
    this.selectedSlot,
    this.timeSlot,
  });

  ProviderAppointment.fromJson(Map<String, dynamic> json) {
    id = json['_id'] ?? json['id'];
    appointmentStatus = json['appointmentStatus']?.toString();
    appointmentDate = json['appointmentDate']?.toString();
    totalAmount = _toInt(json['totalAmount']);
    downPayment = _toInt(json['downPayment']);
    userNotes = json['userNotes']?.toString();

    final userJson = json['user'] ?? json['userId'];
    if (userJson is Map) {
      user = AppointmentUser.fromJson(Map<String, dynamic>.from(userJson));
    }

    if (json['serviceSnapshot'] is Map) {
      serviceSnapshot = AppointmentServiceSnapshot.fromJson(
        Map<String, dynamic>.from(json['serviceSnapshot']),
      );
    }
    if (json['selectedSlot'] is Map) {
      selectedSlot = AppointmentSelectedSlot.fromJson(
        Map<String, dynamic>.from(json['selectedSlot']),
      );
    }
    if (json['timeSlot'] is Map) {
      timeSlot = AppointmentTimeSlot.fromJson(
        Map<String, dynamic>.from(json['timeSlot']),
      );
    }
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}

class AppointmentUser {
  String? id;
  String? fullName;
  String? email;
  String? profilePicture;
  String? phoneNumber;
  String? address;

  AppointmentUser({this.id, this.fullName, this.email, this.profilePicture, this.phoneNumber, this.address});

  AppointmentUser.fromJson(Map<String, dynamic> json) {
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

class AppointmentServiceSnapshot {
  String? serviceName;
  String? servicePhoto;
  String? headline;
  String? category;

  AppointmentServiceSnapshot({this.serviceName, this.servicePhoto, this.headline, this.category});

  AppointmentServiceSnapshot.fromJson(Map<String, dynamic> json) {
    serviceName = json['serviceName']?.toString();
    servicePhoto = json['servicePhoto']?.toString();
    headline = json['headline']?.toString();
    category = json['category']?.toString();
  }
}

class AppointmentSelectedSlot {
  int? duration;
  String? durationUnit;
  int? price;

  AppointmentSelectedSlot({this.duration, this.durationUnit, this.price});

  AppointmentSelectedSlot.fromJson(Map<String, dynamic> json) {
    duration = _toInt(json['duration']);
    durationUnit = json['durationUnit']?.toString();
    price = _toInt(json['price']);
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}

class AppointmentTimeSlot {
  String? startTime;
  String? endTime;

  AppointmentTimeSlot({this.startTime, this.endTime});

  AppointmentTimeSlot.fromJson(Map<String, dynamic> json) {
    startTime = json['startTime']?.toString();
    endTime = json['endTime']?.toString();
  }
}
