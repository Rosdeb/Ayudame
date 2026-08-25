class RecentProviderResponse {
  final bool success;
  final String message;
  final RecentProviderData data;

  RecentProviderResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RecentProviderResponse.fromJson(Map<String, dynamic> json) {
    final dynamic dataRaw = json['data'];
    return RecentProviderResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: dataRaw is Map<String, dynamic>
          ? RecentProviderData.fromJson(dataRaw)
          : RecentProviderData(providers: const [], count: 0),
    );
  }
}

class RecentProviderData {
  final List<ProviderModel> providers;
  final int count;

  RecentProviderData({
    required this.providers,
    required this.count,
  });

  factory RecentProviderData.fromJson(Map<String, dynamic> json) {
    final providersRaw = json['providers'];
    final providersList = providersRaw is List ? providersRaw : const [];
    return RecentProviderData(
      providers: List<ProviderModel>.from(
        providersList
            .whereType<Map>()
            .map((x) => ProviderModel.fromJson(Map<String, dynamic>.from(x))),
      ),
      count: _toInt(json['count']),
    );
  }
}

class ProviderModel {
  final String id;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String? profilePicture;
  final LocationModel location;
  final List<CategoryModel> categories;
  final double rating;
  final int totalReviews;
  final bool isAvailable;
  final int completedJobs;
  final String occupation;
  final String activityTime;
  final LastServiceModel lastService;
  final DateTime? joinedAt;

  ProviderModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.profilePicture,
    required this.location,
    required this.categories,
    required this.rating,
    required this.totalReviews,
    required this.isAvailable,
    required this.completedJobs,
    required this.occupation,
    required this.activityTime,
    required this.lastService,
    required this.joinedAt,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    final locationRaw = json['location'];
    final categoriesRaw = json['categories'];
    final lastServiceRaw = json['lastService'];

    return ProviderModel(
      id: _toStr(json['id'] ?? json['_id']),
      fullName: _toStr(json['fullName'], fallback: 'Unknown'),
      email: _toNullableStr(json['email']),
      phoneNumber: _toNullableStr(json['phoneNumber']),
      profilePicture: _toNullableStr(json['profilePicture']),
      location: locationRaw is Map<String, dynamic>
          ? LocationModel.fromJson(locationRaw)
          : LocationModel.empty(),
      categories: List<CategoryModel>.from(
        (categoriesRaw is List ? categoriesRaw : const [])
            .whereType<Map>()
            .map((x) => CategoryModel.fromJson(Map<String, dynamic>.from(x))),
      ),
      rating: _toDouble(json['rating']),
      totalReviews: _toInt(json['totalReviews']),
      isAvailable: json['isAvailable'] == true,
      completedJobs: _toInt(json['completedJobs']),
      occupation: _toStr(json['occupation']),
      activityTime: _toStr(json['activityTime']),
      lastService: lastServiceRaw is Map<String, dynamic>
          ? LastServiceModel.fromJson(lastServiceRaw)
          : LastServiceModel.empty(),
      joinedAt: _toDateTime(json['joinedAt']),
    );
  }
}

class LocationModel {
  final double latitude;
  final double longitude;
  final String address;

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      address: _toStr(
        json['address'],
        fallback: 'Address not available',
      ),
    );
  }

  factory LocationModel.empty() {
    return LocationModel(
      latitude: 0.0,
      longitude: 0.0,
      address: 'Address not available',
    );
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String icon;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: _toStr(json['id'] ?? json['_id']),
      name: _toStr(json['name']),
      icon: _toStr(json['icon']),
    );
  }
}

class LastServiceModel {
  final DateTime? date;
  final String type;
  final String status;
  final ServiceModel service;

  LastServiceModel({
    required this.date,
    required this.type,
    required this.status,
    required this.service,
  });

  factory LastServiceModel.fromJson(Map<String, dynamic> json) {
    final serviceRaw = json['service'];
    return LastServiceModel(
      date: _toDateTime(json['date']),
      type: _toStr(json['type']),
      status: _toStr(json['status']),
      service: serviceRaw is Map<String, dynamic>
          ? ServiceModel.fromJson(serviceRaw)
          : ServiceModel.empty(),
    );
  }

  factory LastServiceModel.empty() {
    return LastServiceModel(
      date: null,
      type: '',
      status: '',
      service: ServiceModel.empty(),
    );
  }
}

class ServiceModel {
  final String id;
  final String name;
  final String photo;
  final String category;
  final double basePrice;
  final String description;

  ServiceModel({
    required this.id,
    required this.name,
    required this.photo,
    required this.category,
    required this.basePrice,
    required this.description,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: _toStr(json['id'] ?? json['_id'] ?? json['serviceId']),
      name: _toStr(json['name'], fallback: 'Service'),
      photo: _toStr(json['photo']),
      category: _toStr(json['category']),
      basePrice: _toDouble(json['basePrice'] ?? json['price']),
      description: _toStr(json['description'], fallback: 'No description'),
    );
  }

  factory ServiceModel.empty() {
    return ServiceModel(
      id: '',
      name: 'Service',
      photo: '',
      category: '',
      basePrice: 0.0,
      description: 'No description',
    );
  }
}

String _toStr(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final parsed = value.toString();
  return parsed.trim().isEmpty ? fallback : parsed;
}

String? _toNullableStr(dynamic value) {
  if (value == null) return null;
  final parsed = value.toString().trim();
  return parsed.isEmpty ? null : parsed;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
