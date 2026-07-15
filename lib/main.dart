import 'package:flutter/material.dart';
import 'screens/scanner_screen.dart';

void main() {
  runApp(const LinkGuardApp());
}

class LinkGuardApp extends StatelessWidget {
  const LinkGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ScannerScreen(),
    );
  }
}