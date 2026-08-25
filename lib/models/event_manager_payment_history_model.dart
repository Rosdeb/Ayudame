class EventManagerPaymentHistoryResponse {
  final bool? success;
  final EventManagerPaymentHistoryData? data;

  EventManagerPaymentHistoryResponse({this.success, this.data});

  factory EventManagerPaymentHistoryResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return EventManagerPaymentHistoryResponse(
      success: json['success'] == true,
      data: json['data'] is Map<String, dynamic>
          ? EventManagerPaymentHistoryData.fromJson(json['data'])
          : null,
    );
  }
}

class EventManagerPaymentHistoryData {
  final List<EventManagerTransaction> transactions;
  final int? total;
  final int? currentPage;
  final int? totalPages;
  final Map<String, dynamic>? filters;

  EventManagerPaymentHistoryData({
    required this.transactions,
    this.total,
    this.currentPage,
    this.totalPages,
    this.filters,
  });

  factory EventManagerPaymentHistoryData.fromJson(Map<String, dynamic> json) {
    final rawTransactions = json['transactions'];
    final parsedTransactions = <EventManagerTransaction>[];

    if (rawTransactions is List) {
      parsedTransactions.addAll(
        rawTransactions
            .whereType<Map<String, dynamic>>()
            .map(EventManagerTransaction.fromJson),
      );
    }

    return EventManagerPaymentHistoryData(
      transactions: parsedTransactions,
      total: _toInt(json['total']),
      currentPage: _toInt(json['currentPage']),
      totalPages: _toInt(json['totalPages']),
      filters: json['filters'] is Map<String, dynamic>
          ? json['filters'] as Map<String, dynamic>
          : null,
    );
  }
}

class EventManagerTransaction {
  final String? source;
  final String? orderId;
  final String? transactionId;
  final String? paymentIntentId;
  final String? checkoutSessionId;
  final String? buyerName;
  final String? buyerEmail;
  final EventTransactionEvent? event;
  final num? quantity;
  final num? ticketPrice;
  final num? amount;
  final num? platformFee;
  final num? payout;
  final String? paymentStatus;
  final String? paymentIntentStatus;
  final String? paidAt;
  final String? createdAt;

  EventManagerTransaction({
    this.source,
    this.orderId,
    this.transactionId,
    this.paymentIntentId,
    this.checkoutSessionId,
    this.buyerName,
    this.buyerEmail,
    this.event,
    this.quantity,
    this.ticketPrice,
    this.amount,
    this.platformFee,
    this.payout,
    this.paymentStatus,
    this.paymentIntentStatus,
    this.paidAt,
    this.createdAt,
  });

  factory EventManagerTransaction.fromJson(Map<String, dynamic> json) {
    return EventManagerTransaction(
      source: _toStr(json['source']),
      orderId: _toStr(json['orderId']),
      transactionId: _toStr(json['transactionId']),
      paymentIntentId: _toStr(json['paymentIntentId']),
      checkoutSessionId: _toStr(json['checkoutSessionId']),
      buyerName: _toStr(json['buyerName']),
      buyerEmail: _toStr(json['buyerEmail']),
      event: json['event'] is Map<String, dynamic>
          ? EventTransactionEvent.fromJson(json['event'])
          : null,
      quantity: _toNum(json['quantity']),
      ticketPrice: _toNum(json['ticketPrice']),
      amount: _toNum(json['amount']),
      platformFee: _toNum(json['platformFee']),
      payout: _toNum(json['payout']),
      paymentStatus: _toStr(json['paymentStatus']),
      paymentIntentStatus: _toStr(json['paymentIntentStatus']),
      paidAt: _toStr(json['paidAt']),
      createdAt: _toStr(json['createdAt']),
    );
  }
}

class EventTransactionEvent {
  final String? id;
  final String? name;
  final String? location;
  final String? startDateTime;
  final String? endDateTime;

  EventTransactionEvent({
    this.id,
    this.name,
    this.location,
    this.startDateTime,
    this.endDateTime,
  });

  factory EventTransactionEvent.fromJson(Map<String, dynamic> json) {
    return EventTransactionEvent(
      id: _toStr(json['id']),
      name: _toStr(json['name']),
      location: _toStr(json['location']),
      startDateTime: _toStr(json['startDateTime']),
      endDateTime: _toStr(json['endDateTime']),
    );
  }
}

String? _toStr(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

num? _toNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
