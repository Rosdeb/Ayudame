class NearbyProvidersResponse {
  final bool? success;
  final String? message;
  final NearbyProvidersData? data;

  NearbyProvidersResponse({
    this.success,
    this.message,
    this.data,
  });

  factory NearbyProvidersResponse.fromJson(Map<String, dynamic> json) {
    final dynamic rawData = json['data'];
    final Map<String, dynamic>? dataMap = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : null;
    return NearbyProvidersResponse(
      success: json['success'],
      message: json['message']?.toString(),
      data: dataMap != null
          ? NearbyProvidersData.fromJson(dataMap)
          : null,
    );
  }
}

class NearbyProvidersData {
  final List<NearbyProvider>? providers;
  final List<CategoryWithProviders>? categories;
  final int? totalCategories;
  final int? totalProviders;
  final SearchRadius? searchRadius;

  NearbyProvidersData({
    this.providers,
    this.categories,
    this.totalCategories,
    this.totalProviders,
    this.searchRadius,
  });

  factory NearbyProvidersData.fromJson(Map<String, dynamic> json) {
    final dynamic rawProviders = json['providers'];
    final dynamic rawCategories = json['categories'];
    final dynamic rawSearchRadius = json['searchRadius'];

    return NearbyProvidersData(
      providers: rawProviders is List
          ? rawProviders
              .whereType<Map>()
              .map((i) => NearbyProvider.fromJson(Map<String, dynamic>.from(i)))
              .toList()
          : null,
      categories: rawCategories is List
          ? rawCategories
              .whereType<Map>()
              .map(
                (i) => CategoryWithProviders.fromJson(
                  Map<String, dynamic>.from(i),
                ),
              )
              .toList()
          : null,
      totalCategories: _toInt(json['totalCategories']),
      totalProviders: _toInt(json['totalProviders']),
      searchRadius: rawSearchRadius is Map
          ? SearchRadius.fromJson(Map<String, dynamic>.from(rawSearchRadius))
          : null,
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}

class SearchRadius {
  final int? meters;
  final String? kilometers;

  SearchRadius({
    this.meters,
    this.kilometers,
  });

  factory SearchRadius.fromJson(Map<String, dynamic> json) {
    return SearchRadius(
      meters: _toInt(json['meters']),
      kilometers: json['kilometers']?.toString(),
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}


class CategoryWithProviders {
  final String? categoryId;
  final String? categoryName;
  final String? categoryImage;
  final num? averageDistance;
  final String? averageDistanceKm;
  final int? providerCount;

  CategoryWithProviders({
    this.categoryId,
    this.categoryName,
    this.categoryImage,
    this.averageDistance,
    this.averageDistanceKm,
    this.providerCount,
  });

  factory CategoryWithProviders.fromJson(Map<String, dynamic> json) {
    return CategoryWithProviders(
      categoryId: json['categoryId']?.toString(),
      categoryName: json['categoryName']?.toString(),
      categoryImage: json['categoryImage']?.toString(),
      averageDistance: _toNum(json['averageDistance']),
      averageDistanceKm: json['averageDistanceKm']?.toString(),
      providerCount: _toInt(json['providerCount']),
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static num? _toNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '');
  }
}

class NearbyProvider {
  final String? providerId;
  final String? name;
  final String? profileImage;
  final String? address;
  final double? distance;
  final String? distanceKm;
  final String? activityTime;
  final double? rating;
  final int? totalReviews;
  final int? completedJobs;
  final String? occupation;

  NearbyProvider({
    this.providerId,
    this.name,
    this.profileImage,
    this.address,
    this.distance,
    this.distanceKm,
    this.activityTime,
    this.rating,
    this.totalReviews,
    this.completedJobs,
    this.occupation,
  });

  factory NearbyProvider.fromJson(Map<String, dynamic> json) {
    return NearbyProvider(
      providerId: json['providerId']?.toString(),
      name: json['name']?.toString(),
      profileImage: json['profileImage']?.toString(),
      address: json['address']?.toString(),
      distance: _toDouble(json['distance']),
      distanceKm: json['distanceKm']?.toString(),
      activityTime: json['activityTime']?.toString(),
      rating: _toDouble(json['rating']),
      totalReviews: _toInt(json['totalReviews']),
      completedJobs: _toInt(json['completedJobs']),
      occupation: json['occupation']?.toString(),
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
