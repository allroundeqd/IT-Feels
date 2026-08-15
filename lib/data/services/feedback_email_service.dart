import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class FeedbackEmailService {
  final http.Client httpClient;

  FeedbackEmailService({http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  static String get baseUrl =>
      (dotenv.isInitialized ? dotenv.env['YT_DLP_BASE_URL'] : null) ??
      'https://it-feels-android.onrender.com';

  Map<String, String> get _proxyHeaders => {
        'X-Feels-Secret':
            (dotenv.isInitialized ? dotenv.env['API_SECRET'] : null) ??
                'development_secret_123',
      };

  /// Log Telemetry Event to backend
  Future<bool> logTelemetry(String eventName, Map<String, dynamic> metadata) async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/telemetry');
      final response = await httpClient
          .post(
            uri,
            headers: {
              ..._proxyHeaders,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'event': eventName,
              'metadata': metadata,
              'timestamp': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[FeedbackEmailService] logTelemetry error: $e');
      return false;
    }
  }

  /// Send user feedback email via backend proxy
  Future<bool> sendFeedbackEmail({
    required String subject,
    required String body,
    String? replyTo,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/feedback');
      final response = await httpClient
          .post(
            uri,
            headers: {
              ..._proxyHeaders,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'subject': subject,
              'body': body,
              'replyTo': replyTo,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      debugPrint('[FeedbackEmailService] sendFeedbackEmail error: $e');
    }
    return false;
  }
}
