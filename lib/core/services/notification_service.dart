import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  static const String _oneSignalAppId = '91da2ac0-2551-491f-98ca-5d43667edf9e';
  static const String _restApiKey =
      'os_v2_app_shncvqbfkfer7ggklvbwm7w7ty2y2r3idg5un4fppemo3vkim64qflaqyqvtauentpikmokpup7s4sf7b5dw7fqfuo4sqglqh4b3tky';

  /// Sends a push notification to a single user
  static Future<void> sendNotification({
    required String title,
    required String message,
    required String playerId,
  }) async {
    if (playerId.isEmpty) {
      print('⚠️ Skipping notification. Player ID is empty.');
      return;
    }

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
      'priority': 10,
      'android_channel_id': '27cf1930-ec7a-449b-9c4f-f76134921712',
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('✅ Notification sent to one user.');
      } else {
        print('❌ Failed to send notification. Code: ${response.statusCode}');
        print('📨 Error body: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception during notification: $e');
    }
  }

  /// Sends a push notification to multiple users
  static Future<void> sendNotificationToMany({
    required String title,
    required String message,
    required List<String> playerIds,
  }) async {
    final validPlayerIds = playerIds.where((id) => id.isNotEmpty).toList();

    if (validPlayerIds.isEmpty) {
      print('⚠️ No valid player IDs to notify.');
      return;
    }

    final url = Uri.parse('https://onesignal.com/api/v1/notifications');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Basic $_restApiKey',
    };

    final body = jsonEncode({
      'app_id': _oneSignalAppId,
      'include_player_ids': validPlayerIds,
      'headings': {'en': title},
      'contents': {'en': message},
      'priority': 10,
      'android_channel_id': '27cf1930-ec7a-449b-9c4f-f76134921712',
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('✅ Notification sent to multiple users.');
      } else {
        print('❌ Failed to send notification to many. Code: ${response.statusCode}');
        print('📨 Error body: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception during bulk notification: $e');
    }
  }
}
