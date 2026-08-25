import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../models/user/home/event_model.dart';
import '../../../utils/token_service.dart';
import 'package:middle_ware/services/api_service.dart';


class EventController extends GetxController {
  var isLoading = false.obs;
  var eventList = <EventModel>[].obs;
  var errorMessage = ''.obs;

  final String eventsUrl = "${ApiService.BASE_URL}/api/home/popular-events";


  @override
  void onInit() {
    fetchEvents();
    super.onInit();
  }

  Future<void> fetchEvents() async {
    try {
      isLoading(true);
      errorMessage('');
      eventList.clear();

      final token = await TokenService().getToken();
      if (token == null || token.isEmpty) {
        errorMessage.value = "No authentication token";
        return;
      }
      final response = await http.get(Uri.parse(eventsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Events API Status: ${response.statusCode}");
      print("Events API Body: ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<Map<String, dynamic>> events = _extractEvents(body);
        eventList.value = events.map(EventModel.fromJson).toList();
      }else{
        errorMessage.value = _extractMessage(bodyRaw: response.body, fallback: "Failed to load events");
      }
    } catch(e) {
      errorMessage.value = "Failed to load events";
      print("Error fetching events: $e");
    }
    finally {
      isLoading(false);
    }
  }

  List<Map<String, dynamic>> _extractEvents(dynamic body) {
    if (body is! Map) return <Map<String, dynamic>>[];

    final dynamic data = body['data'];
    dynamic rawEvents;

    if (data is Map) {
      rawEvents = data['events'] ?? data['popularEvents'] ?? data['items'];
    } else if (data is List) {
      rawEvents = data;
    } else {
      rawEvents = body['events'];
    }

    if (rawEvents is! List) return <Map<String, dynamic>>[];
    return rawEvents
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  String _extractMessage({required String bodyRaw, required String fallback}) {
    try {
      final decoded = jsonDecode(bodyRaw);
      final msg = decoded is Map ? decoded['message'] : null;
      if (msg is String && msg.trim().isNotEmpty) {
        return msg.trim();
      }
    } catch (_) {}
    return fallback;
  }
}
