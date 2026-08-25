class HomeSearchResponse {
  final bool success;
  final List<HomeSearchServiceItem> services;
  final String? message;

  HomeSearchResponse({
    required this.success,
    required this.services,
    this.message,
  });

  factory HomeSearchResponse.fromJson(Map<String, dynamic> json) {
    final dynamic data = json['data'];
    final dynamic rawServices = data is Map ? data['services'] : null;
    final List<HomeSearchServiceItem> parsedServices = rawServices is List
        ? rawServices
            .whereType<Map>()
            .map((e) => HomeSearchServiceItem.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : const <HomeSearchServiceItem>[];

    return HomeSearchResponse(
      success: json['success'] == true,
      services: parsedServices,
      message: json['message']?.toString(),
    );
  }
}

class HomeSearchServiceItem {
  final String serviceId;
  final String providerId;
  final String providerName;
  final String? providerImage;
  final String title;
  final String description;
  final String? serviceImage;
  final double price;
  final bool appointmentEnabled;
  final String serviceType;

  HomeSearchServiceItem({
    required this.serviceId,
    required this.providerId,
    required this.providerName,
    required this.providerImage,
    required this.title,
    required this.description,
    required this.serviceImage,
    required this.price,
    required this.appointmentEnabled,
    required this.serviceType,
  });

  factory HomeSearchServiceItem.fromJson(Map<String, dynamic> json) {
    final dynamic rawProvider = json['providerId'];
    final Map<String, dynamic>? providerMap =
        rawProvider is Map ? Map<String, dynamic>.from(rawProvider) : null;
    final dynamic rawUser = providerMap?['userId'];
    final Map<String, dynamic>? userMap =
        rawUser is Map ? Map<String, dynamic>.from(rawUser) : null;

    return HomeSearchServiceItem(
      serviceId: _toStr(json['_id'] ?? json['id'] ?? json['serviceId']),
      providerId: _toStr(providerMap?['_id'] ?? providerMap?['id'] ?? rawProvider),
      providerName: _toStr(userMap?['fullName'], fallback: 'Unknown'),
      providerImage: _toNullableStr(userMap?['profilePicture']),
      title: _toStr(json['headline'] ?? json['title'], fallback: 'Service'),
      description: _toStr(
        json['description'],
        fallback: '',
      ),
      serviceImage: _toNullableStr(json['servicePhoto'] ?? json['image']),
      price: _toDouble(json['basePrice'] ?? json['price']),
      appointmentEnabled: json['appointmentEnabled'] == true,
      serviceType: _toStr(json['serviceType']),
    );
  }

  bool get isValidProviderService =>
      serviceType == 'provider' && serviceId.isNotEmpty && providerId.isNotEmpty;
}

String _toStr(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final String parsed = value.toString().trim();
  return parsed.isEmpty ? fallback : parsed;
}

String? _toNullableStr(dynamic value) {
  if (value == null) return null;
  final String parsed = value.toString().trim();
  return parsed.isEmpty ? null : parsed;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}
