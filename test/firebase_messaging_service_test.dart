import 'package:flutter_test/flutter_test.dart';
import 'package:middle_ware/services/notifications/firebase_messaging_service.dart';

void main() {
  test('notification service initializes without recursion and is shared', () {
    final service = FirebaseMessagingService.instance();

    expect(FirebaseMessagingService.instance(), same(service));
  });
}
