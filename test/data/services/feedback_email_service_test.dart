import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:it_feels_music/data/services/feedback_email_service.dart';

void main() {
  group('FeedbackEmailService Unit Tests', () {
    test('logTelemetry returns true on HTTP 200', () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({'success': true}), 200);
      });

      final service = FeedbackEmailService(httpClient: mockClient);
      final success = await service.logTelemetry('test_event', {'key': 'val'});

      expect(success, isTrue);
    });

    test('sendFeedbackEmail returns true on HTTP 200', () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({'success': true}), 200);
      });

      final service = FeedbackEmailService(httpClient: mockClient);
      final success = await service.sendFeedbackEmail(
        subject: 'Bug report',
        body: 'Audio glitch',
        replyTo: 'user@example.com',
      );

      expect(success, isTrue);
    });
  });
}
