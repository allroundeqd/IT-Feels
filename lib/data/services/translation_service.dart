import 'package:translator/translator.dart';
import 'package:flutter/foundation.dart';

class TranslationService {
  static final GoogleTranslator _translator = GoogleTranslator();
  static final Map<String, String> _cache = {};

  static Future<String?> translateText(String text, String targetLanguage) async {
    if (text.isEmpty) return null;
    if (targetLanguage == 'none' || targetLanguage.isEmpty) return null;

    final cacheKey = '${targetLanguage}_${text.hashCode}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }

    try {
      final translation = await _translator.translate(text, to: targetLanguage);
      _cache[cacheKey] = translation.text;
      return translation.text;
    } catch (e) {
      debugPrint('[TranslationService] Error translating text: $e');
      return null;
    }
  }

  static Future<List<String>?> translateLines(List<String> lines, String targetLanguage) async {
    if (lines.isEmpty || targetLanguage == 'none' || targetLanguage.isEmpty) return null;
    
    // Join lines with a special delimiter or just newlines to minimize API calls
    final combined = lines.join('\n');
    final translated = await translateText(combined, targetLanguage);
    
    if (translated != null) {
      return translated.split('\n');
    }
    return null;
  }
}
