class ProviderPaymentHistoryResponse {
  final bool? success;
  final ProviderPaymentHistoryData? data;

  ProviderPaymentHistoryResponse({this.success, this.data});

  factory ProviderPaymentHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ProviderPaymentHistoryResponse(
      success: json['success'],
      data: json['data'] != null
          ? ProviderPaymentHistoryData.fromJson(json['data'])
          : null,
    );
  }
}

class ProviderPaymentHistoryData {
  final List<ProviderTransaction> transactions;
  final int? total;
  final int? currentPage;
  final int? totalPages;
  final Map<String, dynamic>? filters;

  ProviderPaymentHistoryData({
    required this.transactions,
    this.total,
    this.currentPage,
    this.totalPages,
    this.filters,
  });

  factory ProviderPaymentHistoryData.fromJson(Map<String, dynamic> json) {
    final rawTransactions = json['transactions'];
    final parsedTransactions = <ProviderTransaction>[];
    if (rawTransactions is List) {
      parsedTransactions.addAll(
        rawTransactions.map((e) => ProviderTransaction.fromJson(e)),
      );
    }

    return ProviderPaymentHistoryData(
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

class ProviderTransaction {
  final String? source;
  final String? orderId;
  final String? transactionId;
  final String? paymentIntentId;
  final String? duePaymentIntentId;
  final String? checkoutSessionId;
  final String? customerName;
  final String? serviceName;
  final String? bookingDate;
  final num? amount;
  final num? downPayment;
  final num? dueAmount;
  final num? remainingAmount;
  final String? paymentStatus;
  final String? paymentIntentStatus;
  final String? duePaymentIntentStatus;
  final String? paidVia;
  final String? status;
  final String? paidAt;
  final String? createdAt;

  ProviderTransaction({
    this.source,
    this.orderId,
    this.transactionId,
    this.paymentIntentId,
    this.duePaymentIntentId,
    this.checkoutSessionId,
    this.customerName,
    this.serviceName,
    this.bookingDate,
    this.amount,
    this.downPayment,
    this.dueAmount,
    this.remainingAmount,
    this.paymentStatus,
    this.paymentIntentStatus,
    this.duePaymentIntentStatus,
    this.paidVia,
    this.status,
    this.paidAt,
    this.createdAt,
  });

  factory ProviderTransaction.fromJson(Map<String, dynamic> json) {
    return ProviderTransaction(
      source: _toStr(json['source']),
      orderId: _toStr(json['orderId']),
      transactionId: _toStr(json['transactionId']),
      paymentIntentId: _toStr(json['paymentIntentId']),
      duePaymentIntentId: _toStr(json['duePaymentIntentId']),
      checkoutSessionId: _toStr(json['checkoutSessionId']),
      customerName: _toStr(json['customerName']),
      serviceName: _toStr(json['serviceName']),
      bookingDate: _toStr(json['bookingDate']),
      amount: _toNum(json['amount']),
      downPayment: _toNum(json['downPayment']),
      dueAmount: _toNum(json['dueAmount']),
      remainingAmount: _toNum(json['remainingAmount']),
      paymentStatus: _toStr(json['paymentStatus']),
      paymentIntentStatus: _toStr(json['paymentIntentStatus']),
      duePaymentIntentStatus: _toStr(json['duePaymentIntentStatus']),
      paidVia: _toStr(json['paidVia']),
      status: _toStr(json['status']),
      paidAt: _toStr(json['paidAt']),
      createdAt: _toStr(json['createdAt']),
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
