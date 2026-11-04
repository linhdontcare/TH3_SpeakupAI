import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  static final SpeechService instance = SpeechService._init();
  SpeechService._init();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isAvailable = false;

  bool get isAvailable => _isAvailable;
  bool get isListening => _speech.isListening;

  Future<bool> initialize() async {
    if (_isInitialized) return _isAvailable;

    try {
      if (!kIsWeb) {
        final status = await Permission.microphone.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          _isAvailable = false;
          _isInitialized = true;
          return false;
        }
      }

      _isAvailable = await _speech.initialize(
        onError: (val) {
          debugPrint('Speech recognition error: ${val.errorMsg}');
        },
        onStatus: (val) {
          debugPrint('Speech recognition status: $val');
        },
      );
      _isInitialized = true;
      return _isAvailable;
    } catch (e) {
      debugPrint('Speech recognition init error: $e');
      _isAvailable = false;
      _isInitialized = true;
      return false;
    }
  }

  Future<void> startListening({
    required Function(String recognizedWords) onResult,
    Function(double soundLevel)? onSoundLevelChange,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isAvailable) {
      return;
    }

    try {
      await _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
        onSoundLevelChange: onSoundLevelChange,
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
          pauseFor: const Duration(seconds: 4),
        ),
        localeId: 'en_US',
      );
    } catch (e) {
      debugPrint('Error starting listening: $e');
    }
  }

  Future<void> stopListening() async {
    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
    } catch (e) {
      debugPrint('Error stopping listening: $e');
    }
  }
}
