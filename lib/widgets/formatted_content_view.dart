import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../core/config/env.dart';

class FormattedContentView extends StatelessWidget {
  const FormattedContentView({
    super.key,
    required this.content,
    this.textStyle,
    this.mathFontSize,
    this.maxImageHeight = 260,
  });

  final String content;
  final TextStyle? textStyle;
  final double? mathFontSize;
  final double maxImageHeight;

  static String cleanLatex(String latex) {
    var cleaned = latex.trim();
    if (cleaned.isEmpty) return '';

    // 1. Normalize Unicode symbols to LaTeX equivalents for KaTeX parsing
    cleaned = cleaned
        .replaceAll('→', r'\rightarrow ')
        .replaceAll('⟶', r'\longrightarrow ')
        .replaceAll('⇌', r'\rightleftharpoons ')
        .replaceAll('←', r'\leftarrow ')
        .replaceAll('↔', r'\leftrightarrow ')
        .replaceAll('×', r'\times ')
        .replaceAll('÷', r'\div ')
        .replaceAll('±', r'\pm ')
        .replaceAll('≤', r'\le ')
        .replaceAll('≥', r'\ge ')
        .replaceAll('≠', r'\ne ')
        .replaceAll('≈', r'\approx ')
        .replaceAll('•', r'\cdot ')
        .replaceAll('·', r'\cdot ')
        .replaceAll('°', r'^\circ ')
        .replaceAll('Δ', r'\Delta ')
        .replaceAll('α', r'\alpha ')
        .replaceAll('β', r'\beta ')
        .replaceAll('γ', r'\gamma ')
        .replaceAll('π', r'\pi ')
        .replaceAll('θ', r'\theta ')
        .replaceAll('λ', r'\lambda ')
        .replaceAll('μ', r'\mu ')
        .replaceAll('σ', r'\sigma ')
        .replaceAll('ω', r'\omega ')
        .replaceAll('Ω', r'\Omega ');

    // 2. Strip {\displaystyle ... } wrapper if present
    while (cleaned.startsWith(r'{\displaystyle') && cleaned.endsWith('}')) {
      cleaned = cleaned.substring(r'{\displaystyle'.length, cleaned.length - 1).trim();
    }
    if (cleaned.startsWith(r'\displaystyle')) {
      cleaned = cleaned.substring(r'\displaystyle'.length).trim();
    }

    // 3. Clean MediaWiki specific positioning artifacts:
    // {\vphantom {A}}_{\smash[{t}]{3}} -> _{3}
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\{\\vphantom\s*\{[^}]*\}\}\s*_\s*\{\\smash\[[^\]]*\]\{([^}]*)\}\}'),
      (m) => '_{${m[1]}}',
    );
    // \vphantom {A}_{\smash[{t}]{3}} -> _{3}
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\\vphantom\s*\{[^}]*\}\s*_\s*\{\\smash\[[^\]]*\]\{([^}]*)\}\}'),
      (m) => '_{${m[1]}}',
    );
    // General \vphantom..._{\smash...} -> _{...}
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'(?:\{\\vphantom\s*\{[^}]*\}\}|\\vphantom\s*\{[^}]*\})\s*_\s*(?:\{\\smash(?:\[[^\]]*\])?\{([^}]*)\}\}|\\smash(?:\[[^\]]*\])?\{([^}]*)\})'),
      (m) => '_{${m[1] ?? m[2]}}',
    );
    // Remove isolated \vphantom
    cleaned = cleaned.replaceAll(
      RegExp(r'\{\\vphantom\s*\{[^}]*\}\}'),
      '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'\\vphantom\s*\{[^}]*\}'),
      '',
    );
    // \smash[{t}]{3} -> {3}
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\\smash\[[^\]]*\]\{([^}]*)\}'),
      (m) => '{${m[1]}}',
    );
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\\smash\{([^}]*)\}'),
      (m) => '{${m[1]}}',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'\\smash\[[^\]]*\]'),
      '',
    );
    // \mathrel {\longrightarrow } -> \longrightarrow
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\\mathrel\s*\{\s*(\\longrightarrow|\\rightarrow)\s*\}'),
      (m) => '${m[1]} ',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'\\mathrel\s*\{\s*\}'),
      '',
    );
    cleaned = cleaned.replaceAll(r'{-}', '-');
    cleaned = cleaned.replaceAll(r'{+}', '+');
    cleaned = cleaned.replaceAll(r'~', ' ');
    cleaned = cleaned.replaceAll(r'\;', ' ');

    // 4. If wrapped in redundant outer braces `{ ... }`, unwrap
    if (cleaned.startsWith('{') && cleaned.endsWith('}')) {
      var depth = 0;
      var canUnwrap = true;
      for (var i = 0; i < cleaned.length; i++) {
        if (cleaned[i] == '{') depth++;
        if (cleaned[i] == '}') depth--;
        if (depth == 0 && i < cleaned.length - 1) {
          canUnwrap = false;
          break;
        }
      }
      if (canUnwrap && depth == 0) {
        cleaned = cleaned.substring(1, cleaned.length - 1).trim();
      }
    }

    return cleaned.trim();
  }

  String _preprocess(String raw) {
    var text = raw.trim();
    if (text.isEmpty) return '';

    // 1. If the entire string is just a raw image URL, wrap in <img> tag
    final isDirectImageUrl = (text.startsWith('http://') || text.startsWith('https://')) &&
        (text.contains('/image/') ||
            text.endsWith('.png') ||
            text.endsWith('.jpg') ||
            text.endsWith('.jpeg') ||
            text.endsWith('.webp') ||
            text.endsWith('.gif') ||
            text.endsWith('.svg'));
    if (isDirectImageUrl && !text.contains('<img')) {
      text = '<img src="$text" />';
    }

    // 2. Resolve relative image URLs to base API URL
    text = text.replaceAllMapped(
      RegExp(r'<img\s+([^>]*?)src=["' "'" r'](\/[^"' "'" r']+)["' "'" r']([^>]*?)>', caseSensitive: false),
      (match) {
        final prefix = match.group(1) ?? '';
        final path = match.group(2) ?? '';
        final suffix = match.group(3) ?? '';
        final fullUrl = '${Env.apiBaseUrl}$path';
        return '<img ${prefix}src="$fullUrl"$suffix>';
      },
    );

    // 3. Convert display math: \[ ... \] and $$ ... $$
    text = text.replaceAllMapped(
      RegExp(r'\\{1,2}\[(.*?)\\{1,2}\]', dotAll: true),
      (match) {
        final tex = match.group(1) ?? '';
        final cleanedTex = cleanLatex(tex);
        return '<div style="text-align: center; margin: 6px 0;"><tex display="true" math="${_escapeAttr(cleanedTex)}"></tex></div>';
      },
    );
    text = text.replaceAllMapped(
      RegExp(r'\$\$(.*?)\$\$', dotAll: true),
      (match) {
        final tex = match.group(1) ?? '';
        final cleanedTex = cleanLatex(tex);
        return '<div style="text-align: center; margin: 6px 0;"><tex display="true" math="${_escapeAttr(cleanedTex)}"></tex></div>';
      },
    );

    // 4. Convert inline math: \( ... \)
    text = text.replaceAllMapped(
      RegExp(r'\\{1,2}\((.*?)\\{1,2}\)', dotAll: true),
      (match) {
        final tex = match.group(1) ?? '';
        final cleanedTex = cleanLatex(tex);
        return '<tex math="${_escapeAttr(cleanedTex)}"></tex>';
      },
    );

    // 5. Convert single dollar inline math: $ ... $
    text = text.replaceAllMapped(
      RegExp(r'(?<!\\)\$([^\$\n]+?)(?<!\\)\$'),
      (match) {
        final tex = match.group(1) ?? '';
        final cleanedTex = cleanLatex(tex);
        return '<tex math="${_escapeAttr(cleanedTex)}"></tex>';
      },
    );

    // 6. ONLY if text is purely plain text (NO HTML tags at all) and contains raw LaTeX commands:
    if (!text.contains('<') &&
        (text.contains(r'\rightarrow') ||
            text.contains(r'\longrightarrow') ||
            text.contains(r'\rightleftharpoons') ||
            text.contains(r'\leftarrow') ||
            text.contains(r'\frac') ||
            text.contains(r'\sqrt') ||
            text.contains(r'^{') ||
            text.contains(r'_{'))) {
      text = '<tex math="${_escapeAttr(cleanLatex(text))}"></tex>';
    }

    // 7. Convert remaining un-delimited LaTeX arrows to Unicode arrows for plain text
    text = text
        .replaceAll(r'\rightarrow', ' → ')
        .replaceAll(r'\longrightarrow', ' ⟶ ')
        .replaceAll(r'\rightleftharpoons', ' ⇌ ')
        .replaceAll(r'\leftarrow', ' ← ');

    return text;
  }

  static String _escapeAttr(String val) {
    return val
        .replaceAll('&', '&amp;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }

  static String _unescapeAttr(String val) {
    return val
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&');
  }

  Widget _buildMathWidget(String rawLatex, {required bool isDisplay, required TextStyle defaultStyle}) {
    final mathString = cleanLatex(_unescapeAttr(rawLatex));
    if (mathString.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isDisplay ? 4.0 : 1.0,
        horizontal: 2.0,
      ),
      child: Math.tex(
        mathString,
        textStyle: defaultStyle.copyWith(
          fontSize: mathFontSize ?? (defaultStyle.fontSize ?? 15) * 1.05,
          color: defaultStyle.color,
        ),
        mathStyle: isDisplay ? MathStyle.display : MathStyle.text,
        onErrorFallback: (err) {
          // Clean fallback to readable text
          final fallbackText = mathString
              .replaceAll(r'\text', '')
              .replaceAll(r'\mathrm', '')
              .replaceAll(r'\rm', '')
              .replaceAll(r'\rightarrow', '→')
              .replaceAll(r'\longrightarrow', '⟶')
              .replaceAll(r'\rightleftharpoons', '⇌')
              .replaceAll(r'\leftarrow', '←')
              .replaceAll(r'{', '')
              .replaceAll(r'}', '')
              .replaceAll(r'\', '');
          return Text(
            fallbackText,
            style: defaultStyle,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final processed = _preprocess(content);

    if (processed.isEmpty) {
      return Text('', style: textStyle);
    }

    final defaultStyle = textStyle ?? const TextStyle(
      fontSize: 15,
      color: Color(0xFF3A1E0B),
    );

    return HtmlWidget(
      processed,
      textStyle: defaultStyle,
      customStylesBuilder: (element) {
        if (element.localName == 'img') {
          return {
            'max-width': '100%',
            'height': 'auto',
            'border-radius': '10px',
            'margin': '6px 0',
          };
        }
        return null;
      },
      customWidgetBuilder: (element) {
        // 1. TipTap / ProseMirror rich-text editor data-latex math spans:
        // <span data-type="math-inline" data-latex="..." class="rte-math">
        if (element.attributes.containsKey('data-latex')) {
          final rawLatex = element.attributes['data-latex'] ?? '';
          final isDisplay = element.attributes['data-type'] == 'math-display' ||
              element.localName == 'div';
          return _buildMathWidget(rawLatex, isDisplay: isDisplay, defaultStyle: defaultStyle);
        }

        // 2. Handle <img> tags: Math formula images vs Standalone SVGs vs Regular Images
        if (element.localName == 'img') {
          final alt = (element.attributes['alt'] ?? '').trim();
          final isMathAlt = alt.contains(r'\displaystyle') ||
              alt.contains(r'\mathrm') ||
              alt.contains(r'\rightarrow') ||
              alt.contains(r'\longrightarrow') ||
              alt.contains(r'\rightleftharpoons') ||
              alt.contains(r'\frac') ||
              alt.contains(r'\sqrt') ||
              alt.contains(r'\vphantom') ||
              alt.contains(r'\smash') ||
              alt.startsWith(r'{\') ||
              alt.startsWith(r'\');

          if (isMathAlt) {
            return _buildMathWidget(alt, isDisplay: false, defaultStyle: defaultStyle);
          }

          final src = element.attributes['src'] ?? '';
          if (src.contains('/svg/') || src.endsWith('.svg')) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: SvgPicture.network(
                src,
                headers: const {'User-Agent': 'Mozilla/5.0 (TKS-App)'},
                placeholderBuilder: (_) => const SizedBox(
                  height: 24,
                  width: 24,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
              ),
            );
          }
          return null;
        }

        // 3. Handle <tex math="..."> elements from delimiter preprocessing
        if (element.localName == 'tex') {
          final rawMath = element.attributes['math'] ?? element.text;
          final isDisplay = element.attributes['display'] == 'true';
          return _buildMathWidget(rawMath, isDisplay: isDisplay, defaultStyle: defaultStyle);
        }

        return null;
      },
    );
  }
}
