import 'dart:convert';
import '../lib/models/business_model.dart';

void main() {
  const jsonStr = '''
  {
    "user": {
      "profilePicture": "https://test.com/photo.jpg"
    },
    "businessOwner": {
      "businessName": "BOSS"
    }
  }
  ''';
  
  final Map<String, dynamic> data = jsonDecode(jsonStr);
  final model = BusinessModel.fromJson(data);
  print('Parsed Logo: ' + model.logo.toString());
}
