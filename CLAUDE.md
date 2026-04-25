# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Mando SOF Webview is a Flutter wrapper app that loads a web application (currently a Google Apps Script URL) inside a native WebView. The app is locked to portrait orientation and handles back-navigation within the WebView. It targets Android and iOS.

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Static analysis
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Build
flutter build apk        # Android
flutter build ios         # iOS
```

## Architecture

The entire app lives in `lib/main.dart` — a single-file architecture:

- **`MandoSofApp`** — `StatelessWidget` root with `MaterialApp`, no routing (single screen).
- **`WebViewScreen`** — `StatefulWidget` that manages the `WebViewController` from the `webview_flutter` package. Handles loading state (progress indicator overlay), web resource errors (snackbar), and back-button interception via `PopScope` to navigate within the WebView history instead of exiting the app.

## Key Dependencies

- `webview_flutter: ^4.13.1` — core WebView rendering
- `flutter_lints: ^6.0.0` — lint rules (configured in `analysis_options.yaml`)
- Dart SDK `^3.11.4`

## Platform Notes

- Android: INTERNET permission granted, cleartext traffic disabled (`android:usesCleartextTraffic="false"`).
- iOS: Display name is "Mando SOF" (`CFBundleDisplayName`).
- The widget test references `MandoSofApp` and verifies that `WebViewScreen` renders.
