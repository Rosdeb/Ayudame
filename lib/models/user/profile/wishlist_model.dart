class WishlistResponse {
  final bool? success;
  final String? message;
  final WishlistData? data;

  WishlistResponse({this.success, this.message, this.data});

  factory WishlistResponse.fromJson(Map<String, dynamic> json) {
    return WishlistResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? WishlistData.fromJson(json['data']) : null,
    );
  }
}

class WishlistData {
  final List<WishlistItem>? services;

  WishlistData({this.services});

  factory WishlistData.fromJson(Map<String, dynamic> json) {
    final rawServices = json['services'];
    List<WishlistItem> parsedServices = [];
    if (rawServices is List) {
      parsedServices = rawServices.map((i) => WishlistItem.fromJson(i)).toList();
    } else if (rawServices is Map<String, dynamic>) {
      parsedServices = [WishlistItem.fromJson(rawServices)];
    }

    return WishlistData(
      services: parsedServices,
    );
  }
}

class WishlistItem {
  final String? id;
  final WishlistService? service;
  final String? addedAt;
  final String? notes;

  WishlistItem({this.id, this.service, this.addedAt, this.notes});

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: _toStr(json['_id'] ?? json['id']),
      service: json['service'] is Map<String, dynamic>
          ? WishlistService.fromJson(json['service'])
          : null,
      addedAt: _toStr(json['addedAt']),
      notes: _toStr(json['notes']),
    );
  }
}

class WishlistService {
  final String? serviceId;
  final String? providerId;
  final String? servicePhoto;
  final WishlistCategory? category;
  final String? headline;
  final String? description;
  final num? basePrice;
  final bool? appointmentEnabled;
  final num? rating;
  final int? totalReviews;

  WishlistService({
    this.serviceId,
    this.providerId,
    this.servicePhoto,
    this.category,
    this.headline,
    this.description,
    this.basePrice,
    this.appointmentEnabled,
    this.rating,
    this.totalReviews,
  });

  factory WishlistService.fromJson(Map<String, dynamic> json) {
    return WishlistService(
      serviceId: _toStr(json['serviceId'] ?? json['_id'] ?? json['id']),
      providerId: _toStr(json['providerId']),
      servicePhoto: _toStr(json['servicePhoto']),
      category: json['category'] is Map<String, dynamic>
          ? WishlistCategory.fromJson(json['category'])
          : null,
      headline: _toStr(json['headline']),
      description: _toStr(json['description']),
      basePrice: _toNum(json['basePrice']),
      appointmentEnabled: json['appointmentEnabled'] == true,
      rating: _toNum(json['rating']),
      totalReviews: (json['totalReviews'] is num)
          ? (json['totalReviews'] as num).toInt()
          : int.tryParse(_toStr(json['totalReviews']) ?? ''),
    );
  }
}

class WishlistCategory {
  final String? id;
  final String? name;
  final String? slug;

  WishlistCategory({this.id, this.name, this.slug});

  factory WishlistCategory.fromJson(Map<String, dynamic> json) {
    return WishlistCategory(
      id: _toStr(json['_id'] ?? json['id']),
      name: _toStr(json['name']),
      slug: _toStr(json['slug']),
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
