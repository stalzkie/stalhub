import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  static const String _oneSignalAppId = '91da2ac0-2551-491f-98ca-5d43667edf9e';
  static const String _restApiKey = 'os_v2_app_shncvqbfkfer7ggklvbwm7w7ty2y2r3idg5un4fppemo3vkim64qflaqyqvtauentpikmokpup7s4sf7b5dw7fqfuo4sqglqh4b3tky';

  /// Sends a push notification via OneSignal API
  static Future<void> sendNotification({
    required String title,
    required String message,
    required String playerId,
  }) async {
    final url = Uri.parse('https://onesignal.com/api/v1/notifications');

    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Basic $_restApiKey',
    };

    final body = jsonEncode({
      'app_id': _oneSignalAppId,
      'include_player_ids': [playerId],
      'headings': {'en': title},
      'contents': {'en': message},
      'priority': 10, // ✅ High priority (important for FCM)
      'android_channel_id': '27cf1930-ec7a-449b-9c4f-f76134921712', // ✅ Optional, ensure proper category
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print('✅ Notification sent successfully!');
      } else {
        print('❌ Failed to send notification. Status code: ${response.statusCode}');
        print('📨 Response body: ${response.body}');
      }
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }
}
