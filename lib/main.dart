import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MandoSofApp());
}

class MandoSofApp extends StatelessWidget {
  const MandoSofApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mando SOF',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const WebViewScreen(),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? _controller;
  bool _isLoading = true;

  static final _initialUri = WebUri(
    'https://script.google.com/macros/s/AKfycbyUZFLTEzuuUb7wTxDraJEfFWHCu3X1wDh8TcjJzC99di8ZlFq7/exec',
  );

  final _settings = InAppWebViewSettings(
    javaScriptEnabled: true,
    javaScriptCanOpenWindowsAutomatically: true,
    supportMultipleWindows: false,
    useShouldOverrideUrlLoading: false,
    mediaPlaybackRequiresUserGesture: false,
    thirdPartyCookiesEnabled: true,
    useHybridComposition: true,
    domStorageEnabled: true,
    databaseEnabled: true,
    allowFileAccess: true,
    allowContentAccess: true,
    loadWithOverviewMode: true,
    useWideViewPort: true,
    builtInZoomControls: true,
    displayZoomControls: false,
    mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
    userAgent:
        'Mozilla/5.0 (Linux; Android 15; Pixel 7) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36',
    allowsInlineMediaPlayback: true,
    allowsBackForwardNavigationGestures: true,
    disallowOverScroll: false,
    transparentBackground: false,
  );

  Future<bool> _onBackPressed() async {
    final controller = _controller;
    if (controller != null && await controller.canGoBack()) {
      await controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final canPop = await _onBackPressed();
        if (canPop && context.mounted) {
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(url: _initialUri),
                initialSettings: _settings,
                onWebViewCreated: (controller) => _controller = controller,
                onLoadStart: (_, _) {
                  if (mounted) setState(() => _isLoading = true);
                },
                onLoadStop: (_, _) {
                  if (mounted) setState(() => _isLoading = false);
                },
                onReceivedError: (_, request, error) {
                  if (!mounted) return;
                  if (request.isForMainFrame != true) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al cargar: ${error.description}'),
                    ),
                  );
                },
              ),
              if (_isLoading) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
