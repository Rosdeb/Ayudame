class EventBankModel {
  final String accountHolderName;
  final String bankName;
  final String accountNumber;
  final String routingNumber;
  final String accountHolderType;

  const EventBankModel({
    required this.accountHolderName,
    required this.bankName,
    required this.accountNumber,
    required this.routingNumber,
    required this.accountHolderType,
  });

  factory EventBankModel.fromJson(Map<String, dynamic> json) {
    return EventBankModel(
      accountHolderName: (json['accountHolderName'] ?? '').toString(),
      bankName: (json['bankName'] ?? '').toString(),
      accountNumber: (json['accountNumber'] ?? '').toString(),
      routingNumber: (json['routingNumber'] ?? '').toString(),
      accountHolderType: (json['accountHolderType'] ?? 'Personal').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'accountHolderName': accountHolderName,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'routingNumber': routingNumber,
      'accountHolderType': accountHolderType,
    };
  }

  String get maskedAccountNumber {
    final String trimmed = accountNumber.replaceAll(' ', '');
    if (trimmed.length <= 4) return trimmed;
    final String last4 = trimmed.substring(trimmed.length - 4);
    return '**** **** **** $last4';
  }
}

