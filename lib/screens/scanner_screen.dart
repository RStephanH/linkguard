import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/scan_result.dart';
import '../services/safe_browsing_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late final MobileScannerController controller;
  late final SafeBrowsingService safeBrowsingService;

  bool _isProcessing = false;
  ScanResult? _lastResult; // null tant qu'on n'a rien scanné (état "idle")

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
    safeBrowsingService = SafeBrowsingService(
      apiKey: const String.fromEnvironment('SAFE_BROWSING_API_KEY'),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final value = capture.barcodes.first.rawValue;
    if (value == null) return;

    setState(() {
      _isProcessing = true;
      _lastResult = null; // état "loading" : pas encore de résultat
    });

    final result = await safeBrowsingService.checkUrl(value);

    if (!mounted) return; // garde vue plus tôt : le widget a pu être détruit pendant l'await

    setState(() {
      _lastResult = result;
    });
  }

  void _scanAgain() {
    setState(() {
      _isProcessing = false;
      _lastResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LinkGuard')),
      body: Stack(
        children: [
          MobileScanner(controller: controller, onDetect: _onDetect),
          if (_isProcessing && _lastResult == null)
            const Center(child: CircularProgressIndicator()),
          if (_lastResult != null) _buildResultCard(_lastResult!),
        ],
      ),
    );
  }

  Widget _buildResultCard(ScanResult result) {
    final isSafe = result.level == ThreatLevel.safe;
    final isError = result.level == ThreatLevel.error;

    final color = isError ? Colors.grey : (isSafe ? Colors.green : Colors.red);
    final label = isError
        ? 'Erreur : ${result.errorMessage}'
        : (isSafe ? 'URL sûre' : 'Menace : ${result.threatType}');

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              result.url,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _scanAgain,
              child: const Text('Scanner à nouveau'),
            ),
          ],
        ),
      ),
    );
  }
}