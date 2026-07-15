import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/scan_result.dart';

class SafeBrowsingService {
  final String apiKey;
  final http.Client client;

  SafeBrowsingService({required this.apiKey, http.Client? client})
      : client = client ?? http.Client();

  Future<ScanResult> checkUrl(String url) async {
    final uri = Uri.parse(
      'https://safebrowsing.googleapis.com/v4/threatMatches:find?key=$apiKey',
    );

    final body = jsonEncode({
      'client': {'clientId': 'linkguard', 'clientVersion': '1.0.0'},
      'threatInfo': {
        'threatTypes': ['MALWARE', 'SOCIAL_ENGINEERING', 'UNWANTED_SOFTWARE'],
        'platformTypes': ['ANY_PLATFORM'],
        'threatEntryTypes': ['URL'],
        'threatEntries': [
          {'url': url}
        ],
      },
    });

    try {
      final response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode != 200) {
        return ScanResult(
          url: url,
          level: ThreatLevel.error,
          errorMessage: 'HTTP ${response.statusCode}: ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (decoded.isEmpty) {
        return ScanResult(url: url, level: ThreatLevel.safe);
      }

      final matches = decoded['matches'] as List;
      final threatType = matches.first['threatType'] as String;
      return ScanResult(
        url: url,
        level: ThreatLevel.unsafe,
        threatType: threatType,
      );
    } catch (e) {
      return ScanResult(
        url: url,
        level: ThreatLevel.error,
        errorMessage: e.toString(),
      );
    }
  }
}