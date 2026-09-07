# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Mando MSI (repo/package name: `mando_sof_webview`) is a Flutter wrapper app for the Municipalidad de San Isidro. It bundles two municipal web tools into a single native app with a bottom toolbar so staff switch between them with one tap instead of opening a browser:

1. **Mando SOF** — an operations dashboard hosted on Google Apps Script (`script.google.com/macros/s/.../exec`).
2. **MSI Online** — the municipal portal with login (`munisanisidro.gob.pe/MSIONLINE/Login`).

The app is locked to portrait orientation and intercepts back-navigation to move through the active WebView's history. It targets Android and iOS (macOS/web/windows scaffolding exists but is not a shipping target).

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
flutter test test/widget_test.dart

# Regenerate launcher icons after changing assets/icon/logo_muni_msi.jpg
dart run flutter_launcher_icons

# Build
flutter build apk        # Android
flutter build ios        # iOS
```

## Architecture

The entire app lives in `lib/main.dart` (~250 lines) — single-file, no routing, one screen.

- **`kNavbarColor`** (`0xFF00352C`) — municipal dark green. Seeds the `ColorScheme`, and paints both the `AppBar` and the bottom toolbar.
- **`MandoSofApp`** — `StatelessWidget` root with `MaterialApp` (`title: 'Mando MSI'`, debug banner off).
- **`WebViewScreen`** / **`_WebViewScreenState`** — holds all state. Key detail: **both tabs are parallel lists indexed by tab number**, not separate widgets:
  - `_uris`, `_titles` — static per-tab config.
  - `_controllers`, `_loading`, `_mounted` — mutable per-tab state.
  - `_mounted` implements **lazy tab creation**: tab 1 starts `false` and flips to `true` the first time it is selected, so the second WebView is not built until needed.
  - An `IndexedStack` keeps both WebViews alive across tab switches, so session/scroll state survives (important — MSI Online is behind a login).
  - `_settings` — one shared `InAppWebViewSettings` for both tabs. Permissive by design: third-party cookies, DOM storage, mixed content allowed, and a **spoofed desktop-Chrome-on-Android user agent** (Google Apps Script and the MSI portal misbehave with the default WebView UA). Do not tighten these without testing both sites.
  - `_onBackPressed` — returns `false` when the active WebView can go back (consumes the pop), `true` to let the app exit. Wired through `PopScope(canPop: false)`.
  - `onReceivedError` — only surfaces a snackbar for main-frame errors; subresource failures are ignored.
- **`_Toolbar` / `_ToolbarButton`** — hand-rolled bottom bar (not `BottomNavigationBar`). Selection is indicated by a 3px white top border plus bold white label; unselected is `white70`.

When adding a third destination, extend `_uris`, `_titles`, `_controllers`, `_loading`, `_mounted`, the `IndexedStack` children, and `_Toolbar` together — they are positionally coupled.

## Key Dependencies

- `flutter_inappwebview: ^6.1.5` — WebView rendering. **Note:** the app migrated off `webview_flutter`; do not reintroduce it.
- `flutter_launcher_icons: ^0.14.3` (dev) — generates launcher icons for all platforms from `assets/icon/logo_muni_msi.jpg`.
- `flutter_lints: ^6.0.0` — lint rules, configured in `analysis_options.yaml`.
- Dart SDK `^3.11.4`.

## Platform Notes

- Android: `applicationId` `com.mandosof.mando_sof_webview`, label "Mando MSI", INTERNET permission, and `android:usesCleartextTraffic="true"` (required by the MSI portal).
- iOS: `CFBundleDisplayName` is "Mando MSI".
- App icon source is `assets/icon/logo_muni_msi.jpg`; generated icons across `android/`, `ios/`, `macos/`, `web/`, and `windows/` are committed — regenerate with `flutter_launcher_icons` rather than editing them by hand.
- `android/.kotlin/` is gitignored (Kotlin compiler session artifacts).

## Tests

`test/widget_test.dart` holds a single smoke test asserting `MandoSofApp` is a `StatelessWidget`. It deliberately does not pump the widget tree — `InAppWebView` has no test-environment implementation and would fail.
