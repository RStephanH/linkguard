enum ThreatLevel { safe, unsafe, error }

class ScanResult {
  final String url;
  final ThreatLevel level;
  final String? threatType; // e.g., "SOCIAL_ENGINEERING", null if safe/error
  final String? errorMessage; // filled only if level == error

  ScanResult({
    required this.url,
    required this.level,
    this.threatType,
    this.errorMessage,
  });
}