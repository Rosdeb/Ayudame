import 'dart:convert';
import '../lib/models/business_model.dart';

void main() {
  const jsonStr = '''
  {
    "user": {
      "id": "6a9f952a65fc7f7ed9a40e68",
      "fullName": "rosdeb_koch",
      "email": "rosdevbusiness@yopmail.com",
      "phoneNumber": "01843207907",
      "profilePicture": "https://res.cloudinary.com/ayudameinc/image/upload/v1788856167/lavellh/profiles/qzki3rib5qj564s4hcud.jpg",
      "userType": "businessOwner"
    },
    "businessOwner": {
      "id": "6a9f952a65fc7f7ed9a40e6a",
      "dateOfBirth": "2003-09-25T00:00:00.000Z",
      "occupation": "",
      "referenceId": null,
      "businessName": "BOSS",
      "businessCategory": "691c98c8dad7e3d5eef771df",
      "businessAddress": {
        "fullAddress": "Dhaka,Bangladesh"
      }
    }
  }
  ''';
  
  final Map<String, dynamic> data = jsonDecode(jsonStr);
  final model = BusinessModel.fromJson(data);
  print('Logo: ' + model.logo.toString());
}
