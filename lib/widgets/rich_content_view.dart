import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../core/theme/app_typography.dart';
import '../utils/rich_html_sanitizer.dart';

/// Renders a question/option/explanation field that may contain the rich
/// content the admin editor can now produce: bold/italic text, inline
/// images, symbols, and KaTeX-rendered formulas baked into the stored HTML.
///
/// Plain strings (no HTML tags — the common case, and every question
/// written before the rich-text editor existed) skip the WebView entirely
/// and render as ordinary [Text]. Only content with actual markup pays for
/// a WebView, which is loaded from a bundled KaTeX stylesheet/fonts so
/// formulas render identically to the admin dashboard with no network call.
class RichContentView extends StatefulWidget {
  const RichContentView({
    super.key,
    required this.html,
    this.style,
    this.minHeight = 20,
  });

  final String html;
  final TextStyle? style;
  final double minHeight;

  @override
  State<RichContentView> createState() => _RichContentViewState();
}

class _RichContentViewState extends State<RichContentView> {
  WebViewController? _controller;
  double _height = 0;
  bool _isReady = false;

  bool get _looksLikeHtml => widget.html.contains('<') && widget.html.contains('>');

  @override
  void initState() {
    super.initState();
    if (_looksLikeHtml) _setUpController();
  }

  @override
  void didUpdateWidget(covariant RichContentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.html != widget.html && _looksLikeHtml && _isReady) {
      _injectContent();
    }
  }

  void _setUpController() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'FlutterHeight',
        onMessageReceived: (JavaScriptMessage message) {
          final parsed = double.tryParse(message.message);
          if (parsed != null && mounted && (parsed - _height).abs() > 0.5) {
            setState(() => _height = parsed);
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            _isReady = true;
            _injectContent();
          },
        ),
      )
      ..loadFlutterAsset('assets/katex/template.html');
    _controller = controller;
  }

  Future<void> _injectContent() async {
    final controller = _controller;
    if (controller == null) return;
    final sanitized = sanitizeRichHtml(widget.html);
    final encoded = jsonEncode(sanitized);
    await controller.runJavaScript(
      'document.getElementById("content").innerHTML = $encoded; postHeight();',
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = widget.style ?? AppTypography.bodyMedium;

    if (!_looksLikeHtml) {
      return widget.html.trim().isEmpty
          ? const SizedBox.shrink()
          : Text(widget.html, style: textStyle);
    }

    final controller = _controller;
    if (controller == null) return const SizedBox.shrink();

    return SizedBox(
      height: _height <= 0 ? widget.minHeight : _height,
      child: IgnorePointer(
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}
