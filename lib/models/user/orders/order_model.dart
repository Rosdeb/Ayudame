class OrderResponse {
  final bool? success;
  final int? count;
  final int? total;
  final int? currentPage;
  final int? totalPages;
  final List<OrderModel>? data;

  OrderResponse({
    this.success,
    this.count,
    this.total,
    this.currentPage,
    this.totalPages,
    this.data,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      success: json['success'],
      count: json['count'],
      total: json['total'],
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      data: json['data'] != null
          ? (json['data'] as List).map((i) => OrderModel.fromJson(i)).toList()
          : null,
    );
  }
}

class OrderSource {
  static const String provider = 'provider';
  static const String businessOwner = 'businessOwner';
}

String _normalizeOrderSource(String? source) {
  final normalized = (source ?? '')
      .toLowerCase()
      .replaceAll('_', '')
      .replaceAll('-', '')
      .replaceAll(' ', '');
  if (normalized == 'businessowner') {
    return OrderSource.businessOwner;
  }
  return OrderSource.provider;
}

class OrderModel {
  final String? id;
  final String? userId;
  final String? serviceId;
  final String? providerId;
  final String? employeeServiceId;
  final String? businessOwnerId;
  final String? bookingDate;
  final String? appointmentDate;
  final String? createdAt;
  final num? downPayment;
  final num? totalAmount;
  final num? dueAmount;
  final num? remainingAmount;
  final String? paymentStatus;
  final String? paymentIntentId;
  final String? paymentIntentStatus;
  final String? duePaymentIntentStatus;
  final String? bookingStatus;
  final String? bookingFlowStatus;
  final String? appointmentStatus;
  final String? userNotes;
  final String? reviewedAt;
  final String source;
  final ServiceSnapshot? serviceSnapshot;
  final ProviderDetails? provider;
  final TimeSlot? timeSlot;
  final SelectedSlot? selectedSlot;

  OrderModel({
    this.id,
    this.userId,
    this.serviceId,
    this.providerId,
    this.employeeServiceId,
    this.businessOwnerId,
    this.bookingDate,
    this.appointmentDate,
    this.createdAt,
    this.downPayment,
    this.totalAmount,
    this.dueAmount,
    this.remainingAmount,
    this.paymentStatus,
    this.paymentIntentId,
    this.paymentIntentStatus,
    this.duePaymentIntentStatus,
    this.bookingStatus,
    this.bookingFlowStatus,
    this.appointmentStatus,
    this.userNotes,
    this.reviewedAt,
    this.source = OrderSource.provider,
    this.serviceSnapshot,
    this.provider,
    this.timeSlot,
    this.selectedSlot,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final bool hasBusinessOwnerShape =
        json['businessOwner'] != null ||
        json['businessOwnerId'] != null ||
        json['employeeServiceId'] != null;

    final dynamic providerOrOwner = json['provider'] ?? json['businessOwner'];

    final String resolvedSource =
        (json['source'] ?? '').toString().trim().isNotEmpty
        ? _normalizeOrderSource(json['source'].toString())
        : (hasBusinessOwnerShape
              ? OrderSource.businessOwner
              : OrderSource.provider);

    return OrderModel(
      id: json['_id'] ?? json['id'],
      userId: json['userId'],
      serviceId: json['serviceId'] ?? json['employeeServiceId'],
      providerId: json['providerId'] ?? json['businessOwnerId'],
      employeeServiceId: json['employeeServiceId'],
      businessOwnerId: json['businessOwnerId'],
      bookingDate: json['bookingDate'],
      appointmentDate: json['appointmentDate'],
      createdAt: json['createdAt'],
      downPayment: json['downPayment'],
      totalAmount: json['totalAmount'],
      dueAmount: json['dueAmount'],
      remainingAmount: json['remainingAmount'],
      paymentStatus: json['paymentStatus'],
      paymentIntentId: json['paymentIntentId']?.toString(),
      paymentIntentStatus: json['paymentIntentStatus']?.toString(),
      duePaymentIntentStatus: json['duePaymentIntentStatus']?.toString(),
      bookingStatus: json['bookingStatus'],
      bookingFlowStatus: json['bookingFlowStatus']?.toString(),
      appointmentStatus: json['appointmentStatus'],
      userNotes: json['userNotes'],
      reviewedAt: json['reviewedAt']?.toString(),
      source: resolvedSource,
      serviceSnapshot: json['serviceSnapshot'] != null
          ? ServiceSnapshot.fromJson(json['serviceSnapshot'])
          : null,
      provider: providerOrOwner != null
          ? ProviderDetails.fromJson(providerOrOwner)
          : null,
      timeSlot: json['timeSlot'] != null
          ? TimeSlot.fromJson(json['timeSlot'])
          : null,
      selectedSlot: json['selectedSlot'] != null
          ? SelectedSlot.fromJson(json['selectedSlot'])
          : null,
    );
  }

  // Helper to get status regardless of type
  String get overallStatus {
    if (isAppointment) {
      return appointmentStatus ?? 'pending';
    }
    return bookingFlowStatus ?? bookingStatus ?? 'pending';
  }

  // Helper to get date regardless of type
  String? get overallDate => bookingDate ?? appointmentDate ?? createdAt;

  // Helper to check if it's an appointment
  bool get isAppointment => appointmentStatus != null;

  // Helper to check if order belongs to business owner employee-service flow
  bool get isBusinessOwnerFlow =>
      _normalizeOrderSource(source) == OrderSource.businessOwner;
}

class SelectedSlot {
  final int? duration;
  final String? durationUnit;
  final num? price;
  final String? slotId;

  SelectedSlot({this.duration, this.durationUnit, this.price, this.slotId});

  factory SelectedSlot.fromJson(Map<String, dynamic> json) {
    return SelectedSlot(
      duration: json['duration'],
      durationUnit: json['durationUnit'],
      price: json['price'],
      slotId: json['slotId'],
    );
  }
}

class TimeSlot {
  final String? startTime;
  final String? endTime;

  TimeSlot({this.startTime, this.endTime});

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(startTime: json['startTime'], endTime: json['endTime']);
  }
}

class ServiceSnapshot {
  final String? serviceName;
  final String? servicePhoto;
  final num? basePrice;
  final String? headline;

  ServiceSnapshot({
    this.serviceName,
    this.servicePhoto,
    this.basePrice,
    this.headline,
  });

  factory ServiceSnapshot.fromJson(Map<String, dynamic> json) {
    return ServiceSnapshot(
      serviceName: json['serviceName'],
      servicePhoto: json['servicePhoto'],
      basePrice: json['basePrice'],
      headline: json['headline'],
    );
  }
}

class ProviderDetails {
  final String? id;
  final String? occupation;
  final String? verificationStatus;
  final double? rating;
  final int? totalReviews;
  final UserProfile? user;

  ProviderDetails({
    this.id,
    this.occupation,
    this.verificationStatus,
    this.rating,
    this.totalReviews,
    this.user,
  });

  factory ProviderDetails.fromJson(Map<String, dynamic> json) {
    return ProviderDetails(
      id: json['_id'],
      occupation: json['occupation'],
      verificationStatus: json['verificationStatus'],
      rating: (json['rating'] as num?)?.toDouble(),
      totalReviews: json['totalReviews'],
      user: json['userId'] != null
          ? UserProfile.fromJson(json['userId'])
          : null,
    );
  }
}

class UserProfile {
  final String? id;
  final String? fullName;
  final String? profilePicture;
  final String? address;

  UserProfile({this.id, this.fullName, this.profilePicture, this.address});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['_id'],
      fullName: json['fullName'],
      profilePicture: json['profilePicture'],
      address: json['location'] != null ? json['location']['address'] : null,
    );
  }
}
