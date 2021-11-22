import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:core';

/// Custom wrapper for `FlutterSoundRecorder` to abstract some boiler plate code.
class SoundRecorder {

  /// The singleton instance of `SoundRecorder`.
  static final SoundRecorder _soundRecorderSingleton = SoundRecorder._();

  /// Get the singleton instance of `SoundRecorder`
  static get instance => _soundRecorderSingleton;

  /// Private constructor for `SoundRecorder`.
  SoundRecorder._() {
    init();
  }

  /// Save file name of audio to play.
  bool _isRecorderInitialized = false;

  /// The instance of `FlutterSoundRecorder` that this class wraps.
  FlutterSoundRecorder _soundRecorder;

  bool get isRecording => _soundRecorder.isRecording;

  /// Initialize the recorder and open the sound session. Request mic access if needed.
  Future<void> init() async {
    if (!_isRecorderInitialized) {
      _soundRecorder = FlutterSoundRecorder();

      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Mic permission denied.');
      }

      await _soundRecorder.openAudioSession();
      _isRecorderInitialized = true;
    }
  }

  /// Free microphone resources when finished.
  Future<void> dispose() async {
    _soundRecorder = FlutterSoundRecorder();
    await _soundRecorder.closeAudioSession();
    _isRecorderInitialized = false;
  }

  /// Begin recording if the recording has not started, and stop if it has started.
  Future<void> toggleRecording(String path) async {
    print('IS RECORDER RECORDING ${_soundRecorder.isStopped}');
    if (_soundRecorder.isStopped) {
      await _record(path);
    } else {
      await _stop();
    }
  }

  /// Begin recording audio.
  Future<void> _record(String path) async {
    if (!_isRecorderInitialized) return;
    await _soundRecorder.startRecorder(toFile: path);
    print("RECORDER WAS STARTED");
  }

  /// Complete recording audio.
  Future<void> _stop() async {
    if (!_isRecorderInitialized) return;
    await _soundRecorder.stopRecorder();
    print("RECORDER WAS STOPPED");
  }
}
