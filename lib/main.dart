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

const Color kNavbarColor = Color(0xFF00352C);

class MandoSofApp extends StatelessWidget {
  const MandoSofApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mando MSI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kNavbarColor),
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
  int _selectedIndex = 0;

  static final _uris = <WebUri>[
    WebUri(
      'https://script.google.com/macros/s/AKfycbyUZFLTEzuuUb7wTxDraJEfFWHCu3X1wDh8TcjJzC99di8ZlFq7/exec',
    ),
    WebUri('https://www.munisanisidro.gob.pe/MSIONLINE/Login'),
  ];

  static const _titles = ['Mando SOF', 'MSI Online'];

  final List<InAppWebViewController?> _controllers = [null, null];
  final List<bool> _loading = [true, true];
  final List<bool> _mounted = [true, false];

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
    cacheEnabled: true,
    cacheMode: CacheMode.LOAD_DEFAULT,
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
    final controller = _controllers[_selectedIndex];
    if (controller != null && await controller.canGoBack()) {
      await controller.goBack();
      return false;
    }
    return true;
  }

  void _onSelectTab(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
      if (!_mounted[index]) _mounted[index] = true;
    });
  }

  Widget _buildWebView(int index) {
    if (!_mounted[index]) {
      return const SizedBox.shrink();
    }
    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: _uris[index]),
          initialSettings: _settings,
          onWebViewCreated: (controller) => _controllers[index] = controller,
          onLoadStart: (_, _) {
            if (mounted) setState(() => _loading[index] = true);
          },
          onLoadStop: (_, _) {
            if (mounted) setState(() => _loading[index] = false);
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
        if (_loading[index]) const Center(child: CircularProgressIndicator()),
      ],
    );
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
        appBar: AppBar(
          backgroundColor: kNavbarColor,
          foregroundColor: Colors.white,
          title: Text(_titles[_selectedIndex]),
          centerTitle: true,
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildWebView(0),
            _buildWebView(1),
          ],
        ),
        bottomNavigationBar: _Toolbar(
          selectedIndex: _selectedIndex,
          onSelect: _onSelectTab,
        ),
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kNavbarColor,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _ToolbarButton(
              label: 'Mando SOF',
              icon: Icons.shield_outlined,
              selected: selectedIndex == 0,
              onTap: () => onSelect(0),
            ),
            _ToolbarButton(
              label: 'MSI Online',
              icon: Icons.account_balance_outlined,
              selected: selectedIndex == 1,
              onTap: () => onSelect(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: selected ? Colors.white : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected ? Colors.white : Colors.white70,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white70,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
