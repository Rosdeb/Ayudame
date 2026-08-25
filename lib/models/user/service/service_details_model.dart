class ServiceDetailsResponse {
  final bool? success;
  final ServiceDetailsData? data;

  ServiceDetailsResponse({this.success, this.data});

  factory ServiceDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ServiceDetailsResponse(
      success: json['success'],
      data: json['data'] != null ? ServiceDetailsData.fromJson(json['data']) : null,
    );
  }
}

class ServiceDetailsData {
  final ServiceProvider? provider;
  final ServiceDetails? service;

  ServiceDetailsData({this.provider, this.service});

  factory ServiceDetailsData.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? serviceMap = json['service'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['service'])
        : null;

    Map<String, dynamic>? providerMap = json['provider'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['provider'])
        : null;

    // Fallback for raw /api/services/:id payload where provider is nested in service.providerId.userId
    if (providerMap == null && serviceMap != null) {
      final dynamic providerRaw = serviceMap['providerId'];
      if (providerRaw is Map) {
        final providerObj = Map<String, dynamic>.from(providerRaw);
        final dynamic userRaw = providerObj['userId'];
        final userObj = userRaw is Map ? Map<String, dynamic>.from(userRaw) : <String, dynamic>{};
        final dynamic locationRaw = userObj['location'];
        final locationObj = locationRaw is Map ? Map<String, dynamic>.from(locationRaw) : <String, dynamic>{};

        providerMap = {
          'id': providerObj['_id'] ?? providerObj['id'],
          'name': userObj['fullName'] ?? providerObj['name'],
          'image': userObj['profilePicture'] ?? providerObj['image'],
          'address': locationObj['address'] ?? providerObj['address'],
          'availableTime': providerObj['activityTime'] ?? providerObj['availableTime'],
        };
      } else if (providerRaw is String) {
        providerMap = {'id': providerRaw};
      }
    }

    return ServiceDetailsData(
      provider: providerMap != null ? ServiceProvider.fromJson(providerMap) : null,
      service: serviceMap != null ? ServiceDetails.fromJson(serviceMap) : null,
    );
  }
}

class ServiceProvider {
  final String? id;
  final String? name;
  final String? image;
  final String? address;
  final String? availableTime;

  ServiceProvider({this.id, this.name, this.image, this.address, this.availableTime});

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    String? id;
    final providerId = json['providerId'];
    if (providerId is String) {
      id = providerId;
    } else if (providerId is Map) {
      id = providerId['_id']?.toString() ?? providerId['id']?.toString();
    }

    final userId = json['userId'];
    Map<String, dynamic>? userMap;
    if (userId is Map) {
      userMap = Map<String, dynamic>.from(userId);
    }

    Map<String, dynamic>? locationMap;
    if (json['location'] is Map) {
      locationMap = Map<String, dynamic>.from(json['location']);
    } else if (userMap?['location'] is Map) {
      locationMap = Map<String, dynamic>.from(userMap!['location']);
    }

    return ServiceProvider(
      id: id ?? json['id']?.toString() ?? json['_id']?.toString(),
      name: json['name']?.toString() ?? userMap?['fullName']?.toString(),
      image: json['image']?.toString() ??
          json['profilePicture']?.toString() ??
          userMap?['profilePicture']?.toString(),
      address: json['address']?.toString() ?? locationMap?['address']?.toString(),
      availableTime: json['availableTime']?.toString() ?? json['activityTime']?.toString(),
    );
  }
}

class ServiceDetails {
  final String? serviceId;
  final String? image;
  final String? title;
  final String? about;
  final WhyChooseUs? whyChooseUs;
  final bool? appointmentEnabled;
  final num? basePrice;
  final List<AppointmentSlot>? appointmentSlots;
  final List<TopReview>? topReviews;
  final String? providerId;

  ServiceDetails({
    this.serviceId,
    this.image,
    this.title,
    this.about,
    this.whyChooseUs,
    this.appointmentEnabled,
    this.basePrice,
    this.appointmentSlots,
    this.topReviews,
    this.providerId,
  });

  factory ServiceDetails.fromJson(Map<String, dynamic> json) {
    String? parsedProviderId;
    final providerId = json['providerId'];
    if (providerId is String) {
      parsedProviderId = providerId;
    } else if (providerId is Map) {
      parsedProviderId = providerId['_id']?.toString() ?? providerId['id']?.toString();
    }

    return ServiceDetails(
      serviceId: json['serviceId']?.toString() ??
          json['_id']?.toString() ??
          json['id']?.toString(),
      image: json['image']?.toString() ?? json['servicePhoto']?.toString(),
      title: json['title']?.toString() ?? json['headline']?.toString(),
      about: json['about']?.toString() ?? json['description']?.toString(),
      whyChooseUs: json['whyChooseUs'] != null ? WhyChooseUs.fromJson(json['whyChooseUs']) : null,
      appointmentEnabled: json['appointmentEnabled'],
      basePrice: json['basePrice'],
      appointmentSlots: json['appointmentSlots'] != null
          ? (json['appointmentSlots'] as List).map((i) => AppointmentSlot.fromJson(i)).toList()
          : null,
      topReviews: json['topReviews'] != null
          ? (json['topReviews'] as List).map((i) => TopReview.fromJson(i)).toList()
          : null,
      providerId: parsedProviderId,
    );
  }
}

class WhyChooseUs {
  final String? twentyFourSeven;
  final String? efficientAndFast;
  final String? affordablePrices;
  final String? expertTeam;

  WhyChooseUs({
    this.twentyFourSeven,
    this.efficientAndFast,
    this.affordablePrices,
    this.expertTeam,
  });

  factory WhyChooseUs.fromJson(Map<String, dynamic> json) {
    return WhyChooseUs(
      twentyFourSeven: json['twentyFourSeven'],
      efficientAndFast: json['efficientAndFast'],
      affordablePrices: json['affordablePrices'],
      expertTeam: json['expertTeam'],
    );
  }
}

class AppointmentSlot {
  final String? id;
  final int? duration;
  final String? durationUnit;
  final num? price;

  AppointmentSlot({this.id, this.duration, this.durationUnit, this.price});

  factory AppointmentSlot.fromJson(Map<String, dynamic> json) {
    return AppointmentSlot(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      duration: json['duration'],
      durationUnit: json['durationUnit'],
      price: json['price'],
    );
  }
}

class TopReview {
  final String? reviewId;
  final num? rating;
  final String? comment;
  final String? createdAt;
  final ReviewUser? user;

  TopReview({this.reviewId, this.rating, this.comment, this.createdAt, this.user});

  factory TopReview.fromJson(Map<String, dynamic> json) {
    return TopReview(
      reviewId: json['reviewId']?.toString() ?? json['_id']?.toString(),
      rating: json['rating'],
      comment: json['comment'],
      createdAt: json['createdAt']?.toString(),
      user: json['user'] != null ? ReviewUser.fromJson(json['user']) : null,
    );
  }
}

class ReviewUser {
  final String? name;
  final String? image;

  ReviewUser({this.name, this.image});

  factory ReviewUser.fromJson(Map<String, dynamic> json) {
    return ReviewUser(
      name: json['name']?.toString() ?? json['fullName']?.toString(),
      image: json['image']?.toString() ?? json['profilePicture']?.toString(),
    );
  }
}
