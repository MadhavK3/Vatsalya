import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maternal_infant_care/core/services/translation_service.dart';
import 'package:maternal_infant_care/presentation/viewmodels/language_provider.dart';

/// A text widget that automatically translates its content based on the selected language.
/// 
/// Usage:
/// ```dart
/// TText('Hello World', style: TextStyle(fontSize: 16))
/// ```
class TText extends ConsumerStatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool? softWrap;

  const TText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
  });

  @override
  ConsumerState<TText> createState() => _TTextState();
}

class _TTextState extends ConsumerState<TText> {
  String? _translatedText;
  String? _lastLanguage;
  String? _lastText;
  // No isLoading state needed if we handle cache well

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to safely read provider in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _translate();
    });
  }

  @override
  void didUpdateWidget(TText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      // If cached value exists for new text/lang combination, we might want to just set it immediately
      // But for now, reset and translate
      _translate();
    }
  }

  Future<void> _translate() async {
    final language = ref.read(languageProvider);
    
    // Skip if nothing changed
    if (_lastLanguage == language && _lastText == widget.text && _translatedText != null) {
      return;
    }
    
    _lastLanguage = language;
    _lastText = widget.text;

    // For English, use original text
    if (language == 'en') {
      if (mounted) {
        setState(() {
          _translatedText = widget.text;
        });
      }
      return;
    }

    try {
      // The service now handles caching efficiently
      final translated = await TranslationService().translate(widget.text, language);
      if (mounted) {
        setState(() {
          _translatedText = translated;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _translatedText = widget.text;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch language changes to trigger re-translation
    final currentLanguage = ref.watch(languageProvider);
    
    // Trigger translation if language changed
    if (_lastLanguage != currentLanguage) {
      // Avoid setState during build, schedule it
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _translate();
      });
    }

    // Show original text if translation not ready (or while loading)
    // Providing immediate feedback with original text is better than loading spinner for text
    final displayText = _translatedText ?? widget.text;
    
    return Text(
      displayText,
      style: widget.style,
      textAlign: widget.textAlign,
      overflow: widget.overflow,
      maxLines: widget.maxLines,
      softWrap: widget.softWrap,
    );
  }
}

/// Extension to make translation easier on strings
extension TranslatableString on String {
  /// Returns a TText widget for this string
  Widget tr({
    TextStyle? style,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
    bool? softWrap,
  }) {
    return TText(
      this,
      style: style,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      softWrap: softWrap,
    );
  }
}
