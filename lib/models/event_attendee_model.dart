class EventAttendeeResponse {
  final bool success;
  final EventAttendeeData data;

  EventAttendeeResponse({
    required this.success,
    required this.data,
  });

  factory EventAttendeeResponse.fromJson(Map<String, dynamic> json) {
    return EventAttendeeResponse(
      success: json['success'] == true,
      data: EventAttendeeData.fromJson(
        (json['data'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      ),
    );
  }
}

class EventAttendeeData {
  final EventAttendeeEvent event;
  final EventAttendeeSummary summary;
  final List<Attendee> attendees;
  final EventAttendeePagination pagination;

  EventAttendeeData({
    required this.event,
    required this.summary,
    required this.attendees,
    required this.pagination,
  });

  factory EventAttendeeData.fromJson(Map<String, dynamic> json) {
    final rawAttendees = (json['attendees'] as List?) ?? const [];
    return EventAttendeeData(
      event: EventAttendeeEvent.fromJson(
        (json['event'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      ),
      summary: EventAttendeeSummary.fromJson(
        (json['summary'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      ),
      attendees: rawAttendees
          .whereType<Map>()
          .map((e) => Attendee.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      pagination: EventAttendeePagination.fromJson(
        (json['pagination'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      ),
    );
  }
}

class EventAttendeeEvent {
  final String id;
  final String eventName;

  EventAttendeeEvent({
    required this.id,
    required this.eventName,
  });

  factory EventAttendeeEvent.fromJson(Map<String, dynamic> json) {
    return EventAttendeeEvent(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      eventName: (json['eventName'] ?? '').toString(),
    );
  }
}

class EventAttendeeSummary {
  final int totalBuyers;
  final int totalTicketsSold;

  EventAttendeeSummary({
    required this.totalBuyers,
    required this.totalTicketsSold,
  });

  factory EventAttendeeSummary.fromJson(Map<String, dynamic> json) {
    return EventAttendeeSummary(
      totalBuyers: _asInt(json['totalBuyers']),
      totalTicketsSold: _asInt(json['totalTicketsSold']),
    );
  }
}

class EventAttendeePagination {
  final int currentPage;
  final int totalPages;
  final int totalAttendees;
  final int attendeesPerPage;

  EventAttendeePagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalAttendees,
    required this.attendeesPerPage,
  });

  factory EventAttendeePagination.fromJson(Map<String, dynamic> json) {
    return EventAttendeePagination(
      currentPage: _asInt(json['currentPage'], fallback: 1),
      totalPages: _asInt(json['totalPages'], fallback: 1),
      totalAttendees: _asInt(json['totalAttendees']),
      attendeesPerPage: _asInt(json['attendeesPerPage'], fallback: 20),
    );
  }
}

class Attendee {
  final String purchaseId;
  final AttendeeBuyer? buyer;
  final int ticketsPurchased;
  final String receiptNumber;
  final String? idNumber;
  final String? idType;
  final DateTime? paidAt;

  Attendee({
    required this.purchaseId,
    required this.buyer,
    required this.ticketsPurchased,
    required this.receiptNumber,
    required this.idNumber,
    required this.idType,
    required this.paidAt,
  });

  factory Attendee.fromJson(Map<String, dynamic> json) {
    return Attendee(
      purchaseId: (json['purchaseId'] ?? '').toString(),
      buyer: json['buyer'] is Map<String, dynamic>
          ? AttendeeBuyer.fromJson(json['buyer'] as Map<String, dynamic>)
          : (json['buyer'] is Map
              ? AttendeeBuyer.fromJson(
                  Map<String, dynamic>.from(json['buyer'] as Map),
                )
              : null),
      ticketsPurchased: _asInt(json['ticketsPurchased']),
      receiptNumber: (json['receiptNumber'] ?? '').toString(),
      idNumber: json['idNumber']?.toString(),
      idType: json['idType']?.toString(),
      paidAt: DateTime.tryParse((json['paidAt'] ?? '').toString()),
    );
  }
}

class AttendeeBuyer {
  final String? userId;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? profilePicture;

  AttendeeBuyer({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.profilePicture,
  });

  factory AttendeeBuyer.fromJson(Map<String, dynamic> json) {
    return AttendeeBuyer(
      userId: json['userId']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      profilePicture: json['profilePicture']?.toString(),
    );
  }
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}
