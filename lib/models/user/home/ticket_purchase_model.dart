class TicketPurchaseRequest {
  final int quantity;
  final List<TicketOwner> ticketOwners;

  TicketPurchaseRequest({
    required this.quantity,
    required this.ticketOwners,
  });

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'ticketOwners': ticketOwners.map((e) => e.toJson()).toList(),
    };
  }
}

class TicketOwner {
  final String name;
  final String identificationType;
  final String identificationNumber;

  TicketOwner({
    required this.name,
    required this.identificationType,
    required this.identificationNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'identificationType': identificationType,
      'identificationNumber': identificationNumber,
    };
  }
}

class TicketPurchaseResponse {
  final bool success;
  final String message;
  final PurchaseData? data;

  TicketPurchaseResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory TicketPurchaseResponse.fromJson(Map<String, dynamic> json) {
    return TicketPurchaseResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? PurchaseData.fromJson(json['data']) : null,
    );
  }
}

class PurchaseData {
  final String purchaseId;
  final CheckoutData checkout;

  PurchaseData({
    required this.purchaseId,
    required this.checkout,
  });

  factory PurchaseData.fromJson(Map<String, dynamic> json) {
    return PurchaseData(
      purchaseId: json['purchaseId'] ?? '',
      checkout: CheckoutData.fromJson(json['checkout'] ?? {}),
    );
  }
}

class CheckoutData {
  final String clientSecret;

  CheckoutData({required this.clientSecret});

  factory CheckoutData.fromJson(Map<String, dynamic> json) {
    return CheckoutData(
      clientSecret: json['clientSecret'] ?? json['sessionUrl'] ?? '',
    );
  }
}

class TicketOwnerInfo {
  final String name;
  final String identificationType;
  final String identificationNumber;

  TicketOwnerInfo({
    required this.name,
    required this.identificationType,
    required this.identificationNumber,
  });

  factory TicketOwnerInfo.fromJson(Map<String, dynamic> json) {
    return TicketOwnerInfo(
      name: json['name']?.toString() ?? '',
      identificationType: json['identificationType']?.toString() ?? '',
      identificationNumber: json['identificationNumber']?.toString() ?? '',
    );
  }
}

class TicketEventInfo {
  final String eventId;
  final String eventName;
  final String eventImage;
  final String eventLocation;
  final DateTime? eventStartDateTime;
  final DateTime? eventEndDateTime;
  final double ticketPrice;

  TicketEventInfo({
    required this.eventId,
    required this.eventName,
    required this.eventImage,
    required this.eventLocation,
    required this.eventStartDateTime,
    required this.eventEndDateTime,
    required this.ticketPrice,
  });

  factory TicketEventInfo.fromJson(Map<String, dynamic> json) {
    return TicketEventInfo(
      eventId: (json['_id'] ?? json['id'] ?? json['eventId'])?.toString() ?? '',
      eventName: json['eventName']?.toString() ?? '',
      eventImage: json['eventImage']?.toString() ?? '',
      eventLocation: json['eventLocation']?.toString() ?? '',
      eventStartDateTime: _toDate(json['eventStartDateTime']),
      eventEndDateTime: _toDate(json['eventEndDateTime']),
      ticketPrice: _toDouble(json['ticketPrice']),
    );
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}

class TicketPurchaseDetail {
  final String id;
  final String purchaseId;
  final int quantity;
  final List<TicketOwnerInfo> ticketOwners;
  final double ticketPrice;
  final double totalAmount;
  final String paymentStatus;
  final DateTime? createdAt;
  final TicketEventInfo? event;

  TicketPurchaseDetail({
    required this.id,
    required this.purchaseId,
    required this.quantity,
    required this.ticketOwners,
    required this.ticketPrice,
    required this.totalAmount,
    required this.paymentStatus,
    required this.createdAt,
    required this.event,
  });

  factory TicketPurchaseDetail.fromJson(Map<String, dynamic> json) {
    final dynamic eventRaw = json['eventId'];
    final Map<String, dynamic>? eventMap = eventRaw is Map
        ? Map<String, dynamic>.from(eventRaw)
        : null;

    final String id = (json['_id'] ?? json['id'] ?? '').toString();
    return TicketPurchaseDetail(
      id: id,
      purchaseId: id,
      quantity: _toInt(json['quantity']),
      ticketOwners: (json['ticketOwners'] is List)
          ? (json['ticketOwners'] as List)
                .whereType<Map>()
                .map((e) => TicketOwnerInfo.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const <TicketOwnerInfo>[],
      ticketPrice: _toDouble(json['ticketPrice']),
      totalAmount: _toDouble(json['totalAmount']),
      paymentStatus: json['paymentStatus']?.toString() ?? 'pending',
      createdAt: _toDate(json['createdAt']),
      event: eventMap != null ? TicketEventInfo.fromJson(eventMap) : null,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

class TicketPurchaseDetailData {
  final TicketPurchaseDetail? purchase;

  TicketPurchaseDetailData({required this.purchase});

  factory TicketPurchaseDetailData.fromJson(Map<String, dynamic> json) {
    final dynamic rawPurchase = json['purchase'];
    if (rawPurchase is Map) {
      return TicketPurchaseDetailData(
        purchase: TicketPurchaseDetail.fromJson(
          Map<String, dynamic>.from(rawPurchase),
        ),
      );
    }
    return TicketPurchaseDetailData(purchase: null);
  }
}

class TicketPurchaseDetailResponse {
  final bool success;
  final String message;
  final TicketPurchaseDetailData? data;

  TicketPurchaseDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TicketPurchaseDetailResponse.fromJson(Map<String, dynamic> json) {
    final dynamic rawData = json['data'];
    return TicketPurchaseDetailResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: rawData is Map
          ? TicketPurchaseDetailData.fromJson(Map<String, dynamic>.from(rawData))
          : null,
    );
  }
}

class TicketPurchaseListData {
  final List<TicketPurchaseDetail> purchases;
  final int total;
  final int currentPage;
  final int totalPages;

  TicketPurchaseListData({
    required this.purchases,
    required this.total,
    required this.currentPage,
    required this.totalPages,
  });

  factory TicketPurchaseListData.fromJson(Map<String, dynamic> json) {
    final dynamic rawPurchases = json['purchases'];
    final List<TicketPurchaseDetail> parsedPurchases = rawPurchases is List
        ? rawPurchases
              .whereType<Map>()
              .map(
                (e) => TicketPurchaseDetail.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
        : const <TicketPurchaseDetail>[];

    return TicketPurchaseListData(
      purchases: parsedPurchases,
      total: _toInt(json['total']),
      currentPage: _toInt(json['currentPage'], defaultValue: 1),
      totalPages: _toInt(json['totalPages'], defaultValue: 1),
    );
  }

  static int _toInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? defaultValue;
  }
}

class TicketPurchaseListResponse {
  final bool success;
  final String message;
  final TicketPurchaseListData? data;

  TicketPurchaseListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TicketPurchaseListResponse.fromJson(Map<String, dynamic> json) {
    final dynamic rawData = json['data'];
    return TicketPurchaseListResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: rawData is Map
          ? TicketPurchaseListData.fromJson(Map<String, dynamic>.from(rawData))
          : null,
    );
  }
}
