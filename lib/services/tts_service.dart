import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-speech service for kanji pronunciation
class TTSService {
  static final TTSService _instance = TTSService._internal();
  final FlutterTts _flutterTts = FlutterTts();

  factory TTSService() {
    return _instance;
  }

  TTSService._internal() {
    _initialize();
  }

  /// Initialize TTS
  Future<void> _initialize() async {
    await _flutterTts.setLanguage('ja-JP');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
  }

  /// Speak kanji pronunciation
  Future<void> speak(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print('TTS Error: $e');
    }
  }

  /// Stop speaking
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  /// Set language
  Future<void> setLanguage(String languageCode) async {
    await _flutterTts.setLanguage(languageCode);
  }

  /// Set speech rate
  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }
}
