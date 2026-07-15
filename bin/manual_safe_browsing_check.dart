import 'package:linkguard/services/safe_browsing_service.dart';

void main() async {
  // Values from fromEnvironment MUST be const
  const apiKey = String.fromEnvironment('SAFE_BROWSING_API_KEY');

  if (apiKey.isEmpty) {
    print('Error: Please provide your API key using:');
    print('dart run --define=SAFE_BROWSING_API_KEY=your_key bin/manual_safe_browsing_check.dart');
    return;
  }

  final service = SafeBrowsingService(apiKey: apiKey);

  // Official Google test URL — supposed to always be detected as malware
  const testUrl = 'https://testsafebrowsing.appspot.com/s/malware.html';

  final result = await service.checkUrl(testUrl);

  print('URL          : ${result.url}');
  print('Level        : ${result.level}');
  print('Threat Type  : ${result.threatType}');
  print('Error        : ${result.errorMessage}');
}
