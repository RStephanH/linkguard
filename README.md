# LinkGuard

A QR code scanner with real-time security verification, built in Flutter.

## What it does

LinkGuard scans a QR code or barcode using the camera, extracts the encoded URL, and checks it against the **Google Safe Browsing API** before showing a clear verdict: safe, threat detected, or network error.

Built as an academic demo project on integrating the Camera API with an external network API in mobile development.

## Tech stack

- **Flutter / Dart**
- [`mobile_scanner`](https://pub.dev/packages/mobile_scanner) — camera capture and decoding
- [`http`](https://pub.dev/packages/http) — network calls
- **Google Safe Browsing API v4** — URL reputation lookup

## Architecture

```
lib/
├── models/scan_result.dart               # result data structure
├── services/safe_browsing_service.dart   # API call logic, testable independently of the UI
└── screens/scanner_screen.dart           # camera + state machine (idle/loading/safe/unsafe/error)
```

The service takes an injectable `http.Client`, which allows unit testing without any real network call (`http.testing.MockClient`).

## Technical decision: why v4 instead of v5alpha1

Safe Browsing v5alpha1 (`urls:search`) was evaluated first but **only returns protobuf, not JSON** (`"Unsupported Output Format"` when requesting `$alt=json`). Decoding protobuf in Dart would require generating code from an official `.proto` file — disproportionate complexity for this project. The stable v4 API (native JSON) was used instead.

## Known limitation

Google Safe Browsing alone only covers threats already listed in its databases — a very recent phishing URL may not be detected yet. See the roadmap below for planned mitigations.

## Running the project

```bash
flutter pub get
flutter run --dart-define=SAFE_BROWSING_API_KEY=your_api_key
```

Get an API key via [Google Cloud Console](https://console.cloud.google.com) → APIs & Services → enable "Safe Browsing API" → Credentials → Create API key.

## Tests

```bash
flutter test
```

4 mocked unit tests cover: safe URL, unsafe URL, HTTP error, network error — with no dependency on a real network call.

## Manual network check

```bash
dart run bin/manual_safe_browsing_check.dart -DSAFE_BROWSING_API_KEY=your_api_key
```

Runs a single real call against Google's official test malware URL, useful for confirming the live API integration before a demo.

## Roadmap

Planned improvements beyond the current academic demo scope, roughly in priority order:

1. **Open in browser for safe URLs** — add an "Open link" action shown only when `ThreatLevel.safe`, using [`url_launcher`](https://pub.dev/packages/url_launcher). Never shown for `unsafe` or `error` results — an error means "unverified", not "safe".

2. **VirusTotal integration** — add as a second inspection source, aggregating verdicts from dozens of antivirus engines for a consensus score rather than a single yes/no. Free tier is rate-limited (4 req/min, 500/day, non-commercial use), so this becomes an opt-in "deeper scan" step rather than the default check.

3. **Re-attempt Safe Browsing v5** — re-evaluate whether `hashes.search` (the privacy-preserving, hash-based v5 endpoint) has a usable JSON path, or implement protobuf decoding via generated Dart code from Google's official `.proto` definitions if not.

4. **urlscan.io integration (deepest inspection tier)** — unlike Safe Browsing/VirusTotal (static blocklist lookups), urlscan.io actually renders the page in a sandbox and reports real behavior (screenshots, requests made, resources loaded) — genuinely complementary rather than redundant. Scans are public by default on the free tier, so the UI will need to warn the user explicitly before running this tier ("this scan will be publicly visible").

The long-term goal is a single "inspection level" selector — quick (Safe Browsing only) → deep (+ VirusTotal) → sandboxed (+ urlscan.io) — letting the user trade off speed/privacy against thoroughness.
