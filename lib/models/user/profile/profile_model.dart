class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? profilePicture;
  final String userType;
  final bool isActive;

  UserModel({
    required this.id,
    required this.fullName,
    this.phoneNumber,
    required this.email,
    this.profilePicture,
    required this.userType,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString(),
      profilePicture: json['profilePicture']?.toString(),
      userType: json['userType']?.toString() ?? '',
      isActive: json['isActive'] is bool ? json['isActive'] as bool : false,
    );
  }
}