import 'package:linkguard/services/safe_browsing_service.dart';

void main() async {
  const apiKey = String.fromEnvironment('SAFE_BROWSING_API_KEY');

  if (apiKey.isEmpty) {
    print('Error: pass your key with --dart-define=SAFE_BROWSING_API_KEY=your_key '
        '(use -DSAFE_BROWSING_API_KEY=your_key if running via `dart run`)');
    return;
  }

  final service = SafeBrowsingService(apiKey: apiKey);

  // Google's official test URL — always flagged as malicious, safe to use for testing
  const testUrl = 'https://testsafebrowsing.appspot.com/s/malware.html';

  final result = await service.checkUrl(testUrl);

  print('URL          : ${result.url}');
  print('Level        : ${result.level}');
  print('Threat Type  : ${result.threatType}');
  print('Error        : ${result.errorMessage}');
}