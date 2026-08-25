class TopBusinessesResponse {
  final bool? success;
  final TopBusinessesData? data;

  TopBusinessesResponse({this.success, this.data});

  factory TopBusinessesResponse.fromJson(Map<String, dynamic> json) {
    return TopBusinessesResponse(
      success: json['success'],
      data: json['data'] != null
          ? TopBusinessesData.fromJson(json['data'])
          : null,
    );
  }
}

class TopBusinessesData {
  final List<TopBusiness>? businesses;
  final int? count;

  TopBusinessesData({this.businesses, this.count});

  factory TopBusinessesData.fromJson(Map<String, dynamic> json) {
    final dynamic rawBusinesses =
        json['businesses'] ?? json['topBusinesses'] ?? json['profiles'];
    return TopBusinessesData(
      businesses: rawBusinesses is List
          ? rawBusinesses
                .whereType<Map>()
                .map((i) => TopBusiness.fromJson(Map<String, dynamic>.from(i)))
                .toList()
          : null,
      count: json['count'],
    );
  }
}

class TopBusiness {
  final String? businessOwnerId;
  final String? businessOwnerName;
  final String? businessOwnerPhoto;
  final String? businessPhoto;
  final String? businessName;
  final num? businessRating;
  final String? businessAddress;
  final int? employeeCount;
  final int? serviceCount;
  final int? appointmentServiceCount;

  TopBusiness({
    this.businessOwnerId,
    this.businessOwnerName,
    this.businessOwnerPhoto,
    this.businessPhoto,
    this.businessName,
    this.businessRating,
    this.businessAddress,
    this.employeeCount,
    this.serviceCount,
    this.appointmentServiceCount,
  });

  factory TopBusiness.fromJson(Map<String, dynamic> json) {
    final dynamic ownerRaw = json['businessOwner'] ?? json['owner'];
    final Map<String, dynamic> owner = ownerRaw is Map
        ? Map<String, dynamic>.from(ownerRaw)
        : <String, dynamic>{};
    final Map<String, dynamic> businessProfileRaw =
        json['businessProfile'] is Map
        ? Map<String, dynamic>.from(json['businessProfile'])
        : <String, dynamic>{};

    final dynamic ownerIdRaw =
        json['businessOwnerId'] ??
        json['id'] ??
        json['_id'] ??
        owner['id'] ??
        owner['_id'];
    final String? ownerId = ownerIdRaw?.toString();

    return TopBusiness(
      businessOwnerId: ownerId,
      businessOwnerName:
          json['businessOwnerName']?.toString() ??
          json['ownerName']?.toString() ??
          json['business_owner_name']?.toString() ??
          owner['fullName']?.toString() ??
          owner['name']?.toString(),
      businessOwnerPhoto:
          json['businessOwnerPhoto']?.toString() ??
          json['ownerPhoto']?.toString() ??
          owner['profilePicture']?.toString() ??
          owner['photo']?.toString() ??
          owner['image']?.toString(),
      businessPhoto:
          json['businessPhoto']?.toString() ??
          json['businessOwnerPhoto']?.toString() ??
          json['business_image']?.toString() ??
          json['image']?.toString() ??
          businessProfileRaw['coverPhoto']?.toString(),
      businessName:
          json['businessName']?.toString() ??
          json['name']?.toString() ??
          json['business_name']?.toString() ??
          businessProfileRaw['name']?.toString(),
      businessRating: json['businessRating'],
      businessAddress:
          json['businessAddress']?.toString() ??
          json['address']?.toString() ??
          json['business_address']?.toString() ??
          businessProfileRaw['location']?.toString(),
      employeeCount: json['employeeCount'],
      serviceCount: json['serviceCount'],
      appointmentServiceCount: json['appointmentServiceCount'],
    );
  }
}
