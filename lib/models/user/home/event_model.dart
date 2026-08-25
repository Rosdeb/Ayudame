class EventModel {
  final String eventId;
  final String eventName;
  final String eventImage;
  final String eventType;
  final String eventLocation;
  final String formattedDate;
  final String formattedTime;
  final int ticketsSold;

  EventModel({
    required this.eventId,
    required this.eventName,
    required this.eventImage,
    required this.eventType,
    required this.eventLocation,
    required this.formattedDate,
    required this.formattedTime,
    required this.ticketsSold,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final String eventStart = _toStr(
      json['eventStartDateTime'] ?? json['startDateTime'] ?? json['startTime'],
    );
    final String eventEnd = _toStr(
      json['eventEndDateTime'] ?? json['endDateTime'] ?? json['endTime'],
    );

    return EventModel(
      eventId: _toStr(json['eventId'] ?? json['id'] ?? json['_id']),
      eventName: _toStr(json['eventName'] ?? json['name']),
      eventImage: _toStr(json['eventImage'] ?? json['image']),
      eventType: _toStr(json['eventType'] ?? json['type']),
      eventLocation: _toStr(json['eventLocation'] ?? json['location']),
      formattedDate:
          _toStr(json['formattedDate']).isNotEmpty
          ? _toStr(json['formattedDate'])
          : _dateLabel(eventStart),
      formattedTime:
          _toStr(json['formattedTime']).isNotEmpty
          ? _toStr(json['formattedTime'])
          : _timeLabel(eventStart, eventEnd),
      ticketsSold: _toInt(json['ticketsSold'] ?? json['attendingCount']),
    );
  }

  static String _toStr(dynamic value) => value?.toString() ?? '';

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _dateLabel(String value) {
    if (value.isEmpty) return '';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return '';
    return "${parsed.year.toString().padLeft(4, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}";
  }

  static String _timeLabel(String startValue, String endValue) {
    final start = DateTime.tryParse(startValue);
    final end = DateTime.tryParse(endValue);
    if (start == null) return '';

    final String startTime =
        "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}";
    if (end == null) return startTime;
    final String endTime =
        "${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}";
    return "$startTime - $endTime";
  }
}
