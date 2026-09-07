class ProviderService {
  final String id;
  final String headline;
  final String description;
  final String servicePhoto;
  final String categoryName;
  final String categoryId;
  final num basePrice;
  final num rating;
  final int totalReviews;
  final bool appointmentEnabled;
  final Map<String, dynamic> whyChooseUs;
  final List<dynamic> appointmentSlots;
  final String providerName;
  final String providerLocation;
  final String? providerProfilePicture;

  ProviderService({
    required this.id,
    required this.headline,
    required this.description,
    required this.servicePhoto,
    required this.categoryName,
    required this.categoryId,
    required this.basePrice,
    required this.rating,
    required this.totalReviews,
    required this.appointmentEnabled,
    required this.whyChooseUs,
    required this.appointmentSlots,
    required this.providerName,
    required this.providerLocation,
    this.providerProfilePicture,
  });

  factory ProviderService.fromJson(Map<String, dynamic> json) {
    final dynamic categoryRaw = json['category'] ?? json['categories'];
    String categoryName = '';
    String categoryId = '';
    if (categoryRaw is Map) {
      categoryName = (categoryRaw['name'] ?? '').toString();
      categoryId = (categoryRaw['id'] ?? categoryRaw['_id'] ?? '').toString();
    } else if (categoryRaw is List && categoryRaw.isNotEmpty) {
      final dynamic first = categoryRaw.first;
      if (first is Map) {
        categoryName = (first['name'] ?? '').toString();
        categoryId = (first['id'] ?? first['_id'] ?? '').toString();
      } else {
        categoryName = first.toString();
      }
    } else if (categoryRaw != null) {
      categoryName = categoryRaw.toString();
    }

    final Map<String, dynamic> providerIdObj = json['providerId'] is Map ? json['providerId'] : {};
    final Map<String, dynamic> employeeIdObj = json['employeeId'] is Map ? json['employeeId'] : {};
    final Map<String, dynamic> providerUserObj = providerIdObj['userId'] is Map ? providerIdObj['userId'] : (employeeIdObj['userId'] is Map ? employeeIdObj['userId'] : {});

    final dynamic providerLocationRaw =
        json['providerLocation'] ??
        providerUserObj['location'] ??
        employeeIdObj['location'] ??
        {};
    final Map<String, dynamic> providerLocation = providerLocationRaw is Map
        ? Map<String, dynamic>.from(providerLocationRaw)
        : <String, dynamic>{};
    final String address = (providerLocation['address'] ?? '').toString();

    final Map<String, dynamic> providerUser = Map<String, dynamic>.from(providerUserObj);

    final dynamic whyChooseRaw =
        json['whyChooseUs'] ?? json['whyChooseService'] ?? {};
    final Map<String, dynamic> whyChoose = whyChooseRaw is Map
        ? Map<String, dynamic>.from(whyChooseRaw)
        : <String, dynamic>{};

    final dynamic slotsRaw = json['appointmentSlots'] ?? <dynamic>[];
    final List<dynamic> slots = slotsRaw is List ? slotsRaw : <dynamic>[];

    return ProviderService(
      id: (json['id'] ?? json['_id'] ?? json['serviceId'] ?? '').toString(),
      headline: (json['headline'] ?? json['title'] ?? '').toString(),
      description: (json['description'] ?? json['about'] ?? '').toString(),
      servicePhoto: (json['servicePhoto'] ?? json['image'] ?? '').toString(),
      categoryName: categoryName,
      categoryId: categoryId,
      basePrice: json['basePrice'] ?? json['price'] ?? 0,
      rating: json['rating'] ?? 0,
      totalReviews: json['totalReviews'] ?? 0,
      appointmentEnabled: json['appointmentEnabled'] == true,
      whyChooseUs: whyChoose,
      appointmentSlots: slots,
      providerName:
          (json['providerName'] ??
                  json['employeeName'] ??
                  providerUser['fullName'] ??
                  '')
              .toString(),
      providerLocation: address,
      providerProfilePicture:
          (json['providerProfilePicture'] ?? providerUser['profilePicture'])
              ?.toString(),
    );
  }

  Map<String, dynamic> toArgs() {
    return {
      'id': id,
      'headline': headline,
      'description': description,
      'servicePhoto': servicePhoto,
      'categoryName': categoryName,
      'categoryId': categoryId,
      'basePrice': basePrice,
      'appointmentEnabled': appointmentEnabled,
      'whyChooseUs': whyChooseUs,
      'appointmentSlots': appointmentSlots,
    };
  }
}
