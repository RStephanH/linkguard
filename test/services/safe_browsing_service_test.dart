import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:linkguard/services/safe_browsing_service.dart';
import 'package:linkguard/models/scan_result.dart';

void main() {
  group('SafeBrowsingService', () {
    test('returns safe when the API response is empty', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{}', 200);
      });
      final service = SafeBrowsingService(apiKey: 'fake-key', client: mockClient);

      final result = await service.checkUrl('https://example.com');

      expect(result.level, ThreatLevel.safe);
    });

    test('retourne unsafe quand l\'API signale une menace', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'matches': [
              {'threatType': 'SOCIAL_ENGINEERING'}
            ]
          }),
          200,
        );
      });
      final service = SafeBrowsingService(apiKey: 'fake-key', client: mockClient);

      final result = await service.checkUrl('https://phishing-exemple.com');

      expect(result.level, ThreatLevel.unsafe);
      expect(result.threatType, 'SOCIAL_ENGINEERING');
    });

    test('returns error on non-200 HTTP status', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Forbidden', 403);
      });
      final service = SafeBrowsingService(apiKey: 'bad-key', client: mockClient);

      final result = await service.checkUrl('https://example.com');

      expect(result.level, ThreatLevel.error);
      expect(result.errorMessage, contains('403'));
    });

    test('returns error if the network call fails', () async {
      final mockClient = MockClient((request) async {
        throw Exception('No connection');
      });
      final service = SafeBrowsingService(apiKey: 'fake-key', client: mockClient);

      final result = await service.checkUrl('https://example.com');

      expect(result.level, ThreatLevel.error);
    });
  });
}
