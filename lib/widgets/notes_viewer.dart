import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'pdf_viewer.dart';

/// Renders a note/attachment for a video. PDFs use the native
/// [PdfViewer] (flutter_pdfview); other office formats (PPT/DOC/XLS, etc.)
/// fall back to an embedded web viewer since there's no native Flutter
/// renderer for those.
class NotesViewer extends StatelessWidget {
  const NotesViewer({super.key, required this.notesUrl});

  final String notesUrl;

  @override
  Widget build(BuildContext context) {
    final extension = Uri.parse(notesUrl).path.split('.').last.toLowerCase();
    if (extension == 'pdf') {
      return PdfViewer(url: notesUrl);
    }
    return _OfficeDocumentViewer(notesUrl: notesUrl);
  }
}

class _OfficeDocumentViewer extends StatefulWidget {
  const _OfficeDocumentViewer({required this.notesUrl});

  final String notesUrl;

  @override
  State<_OfficeDocumentViewer> createState() => _OfficeDocumentViewerState();
}

class _OfficeDocumentViewerState extends State<_OfficeDocumentViewer> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final viewerUrl = _buildViewerUrl(widget.notesUrl);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final host = Uri.tryParse(request.url)?.host ?? '';
            final isBlocked = _blockedHosts.any(host.contains);
            return isBlocked
                ? NavigationDecision.prevent
                : NavigationDecision.navigate;
          },
          onPageFinished: (_) async {
            await _controller.runJavaScript(_cleanupScript);
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(viewerUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFDDBF)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            SizedBox.expand(child: WebViewWidget(controller: _controller)),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}

// Best-effort cleanup: the viewer is a third-party hosted page we don't
// control, so these selectors may not match every layout/update on their end.
const _cleanupScript = '''
(function() {
  document.documentElement.style.overflow = 'auto';
  document.body.style.overflow = 'auto';
  document.body.style.webkitOverflowScrolling = 'touch';

  var viewport = document.querySelector('meta[name="viewport"]');
  if (viewport) {
    viewport.setAttribute(
      'content',
      'width=device-width, initial-scale=1, maximum-scale=5, user-scalable=yes'
    );
  }

  var selectors = [
    '[title*="Sign in" i]', '[aria-label*="Sign in" i]',
    '[title*="Print" i]', '[aria-label*="Print" i]',
    '[title*="Download" i]', '[aria-label*="Download" i]',
    '[title*="Edit" i]', '[aria-label*="Edit" i]',
    '[title*="Share" i]', '[aria-label*="Share" i]'
  ];
  selectors.forEach(function(sel) {
    document.querySelectorAll(sel).forEach(function(el) {
      el.style.display = 'none';
    });
  });
})();
''';

// Google's viewer can otherwise redirect into a full sign-in flow or a
// Drive file browser; blocking these hosts keeps the WebView confined to
// the document preview itself.
const _blockedHosts = ['accounts.google.com', 'drive.google.com'];

const _officeExtensions = {'ppt', 'pptx', 'doc', 'docx', 'xls', 'xlsx'};

String _buildViewerUrl(String notesUrl) {
  final extension = Uri.parse(notesUrl).path.split('.').last.toLowerCase();
  final encodedUrl = Uri.encodeComponent(notesUrl);

  if (_officeExtensions.contains(extension)) {
    return 'https://view.officeapps.live.com/op/embed.aspx?src=$encodedUrl';
  }
  return 'https://docs.google.com/gview?embedded=true&url=$encodedUrl';
}
