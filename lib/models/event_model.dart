class EventModel {
  String? id;
  String? eventName;
  String? eventType;
  String? eventManagerName;
  String? eventLocation;
  String? ticketSalesStartDate;
  String? ticketSalesEndDate;
  String? eventStartDateTime;
  String? eventEndDateTime;
  double? ticketPrice;
  int? maximumNumberOfTickets;
  String? confirmationCodePrefix;
  String? eventDescription;
  String? eventImage;
  String? status;
  int? soldTickets;
  double? revenue;
  SalesPerformance? salesPerformance;

  EventModel({
    this.id,
    this.eventName,
    this.eventType,
    this.eventManagerName,
    this.eventLocation,
    this.ticketSalesStartDate,
    this.ticketSalesEndDate,
    this.eventStartDateTime,
    this.eventEndDateTime,
    this.ticketPrice,
    this.maximumNumberOfTickets,
    this.confirmationCodePrefix,
    this.eventDescription,
    this.eventImage,
    this.status,
    this.soldTickets,
    this.revenue,
    this.salesPerformance,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final dynamic salesRaw = json['salesPerformance'];
    final SalesPerformance? parsedSales =
        salesRaw is Map<String, dynamic>
            ? SalesPerformance.fromJson(salesRaw)
            : (salesRaw is Map
                ? SalesPerformance.fromJson(
                    Map<String, dynamic>.from(salesRaw),
                  )
                : null);

    final dynamic soldTicketsRaw =
        json['soldTickets'] ?? json['ticketsSold'] ?? parsedSales?.ticketSold;
    final dynamic revenueRaw = json['revenue'] ?? parsedSales?.earned;

    return EventModel(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      eventName: json['eventName']?.toString(),
      eventType: json['eventType']?.toString(),
      eventManagerName: json['eventManagerName']?.toString(),
      eventLocation: json['eventLocation']?.toString(),
      ticketSalesStartDate: json['ticketSalesStartDate']?.toString(),
      ticketSalesEndDate: json['ticketSalesEndDate']?.toString(),
      eventStartDateTime: json['eventStartDateTime']?.toString(),
      eventEndDateTime: json['eventEndDateTime']?.toString(),
      ticketPrice: double.tryParse((json['ticketPrice'] ?? 0).toString()),
      maximumNumberOfTickets:
          int.tryParse((json['maximumNumberOfTickets'] ?? 0).toString()),
      confirmationCodePrefix: json['confirmationCodePrefix']?.toString(),
      eventDescription: json['eventDescription']?.toString(),
      eventImage: (json['eventImage'] ?? json['eventFlier'])?.toString(),
      status: json['status']?.toString(),
      soldTickets: int.tryParse((soldTicketsRaw ?? 0).toString()),
      revenue: double.tryParse((revenueRaw ?? 0).toString()),
      salesPerformance: parsedSales,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventName': eventName,
      'eventType': eventType,
      'eventManagerName': eventManagerName,
      'eventLocation': eventLocation,
      'ticketSalesStartDate': ticketSalesStartDate,
      'ticketSalesEndDate': ticketSalesEndDate,
      'eventStartDateTime': eventStartDateTime,
      'eventEndDateTime': eventEndDateTime,
      'ticketPrice': ticketPrice?.toString(),
      'maximumNumberOfTickets': maximumNumberOfTickets?.toString(),
      'confirmationCodePrefix': confirmationCodePrefix,
      'eventDescription': eventDescription,
    };
  }

  Map<String, String> toApiFields() {
    return {
      'eventName': eventName ?? '',
      'eventType': eventType ?? '',
      'eventManagerName': eventManagerName ?? '',
      'eventLocation': eventLocation ?? '',
      'ticketSalesStartDate': ticketSalesStartDate ?? '',
      'ticketSalesEndDate': ticketSalesEndDate ?? '',
      'eventStartDateTime': eventStartDateTime ?? '',
      'eventEndDateTime': eventEndDateTime ?? '',
      'ticketPrice': ticketPrice?.toString() ?? '0',
      'maximumNumberOfTickets': maximumNumberOfTickets?.toString() ?? '0',
      'confirmationCodePrefix': confirmationCodePrefix ?? '',
      'eventDescription': eventDescription ?? '',
    };
  }
}

class SalesPerformance {
  final String sold;
  final int ticketSold;
  final int totalTickets;
  final double earned;
  final double soldPerformancePercent;

  SalesPerformance({
    required this.sold,
    required this.ticketSold,
    required this.totalTickets,
    required this.earned,
    required this.soldPerformancePercent,
  });

  factory SalesPerformance.fromJson(Map<String, dynamic> json) {
    return SalesPerformance(
      sold: (json['sold'] ?? '0/0').toString(),
      ticketSold: int.tryParse((json['ticketSold'] ?? 0).toString()) ?? 0,
      totalTickets: int.tryParse((json['totalTickets'] ?? 0).toString()) ?? 0,
      earned: double.tryParse((json['earned'] ?? 0).toString()) ?? 0,
      soldPerformancePercent:
          double.tryParse((json['soldPerformancePercent'] ?? 0).toString()) ??
              0,
    );
  }
}
