import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

/// Custom wrapper for `FlutterSoundPlayer` to abstract some API boiler plate code.
class SoundPlayer {

  /// `SoundPlayer` singleton instance.
  static final SoundPlayer _soundPlayerSingleton = SoundPlayer._();

  /// Getter for singleton instance
  static get instance => _soundPlayerSingleton;

  /// Private Constructor for `SoundPlayer`
  SoundPlayer._() {
    init();
  }

  /// The instance of `FlutterSoundPlayer` that this class wraps.
  FlutterSoundPlayer _soundPlayer;

  /// Retrieve whether or not the player is playing.
  bool get isPlaying => _soundPlayer.isPlaying;

  /// Get the player that this class wraps.
  FlutterSoundPlayer get getPlayer => _soundPlayer;

  /// Adjust the playback speed of the audio player. This can be adjusted in real time.
  void setPlaybackSpeed(double playbackSpeed) {
    _soundPlayer.setSpeed(playbackSpeed);
  }

  /// Adjust the playback volume of the audio player. This can be adjusted in real time.
  void setPlaybackVolume(double playbackVolume) {
    _soundPlayer.setVolume(playbackVolume);
  }

  /// Initialize the player and open the sound session.
  Future<void> init() async {
    _soundPlayer = FlutterSoundPlayer();
    await _soundPlayer.openAudioSession();
  }

  /// Free audio player resources when finished.
  Future<void> dispose() async {
    _soundPlayer.closeAudioSession();
    _soundPlayer = null;
  }

  /// Reset the player to the beginning of the file.
  Future<void> stop() async {
    await _soundPlayer.stopPlayer();
    print('AUDIO PLAYER WAS STOPPED');
  }

  /// Play the audio from the file path, and set up UI updates every 1 millisecond.
  Future<void> _play(String path) async {
    await _soundPlayer.startPlayer(
      fromURI: path
    );
  }

  /// If the player is stopped, play the audio. Pause if it is playing. Resume if it is paused.
  Future<void> togglePlaying(String path) async {
    if (_soundPlayer.isStopped) {
      await _play(path);
      print('AUDIO PLAYER WAS STARTED');
    } else if (_soundPlayer.isPlaying) {
      _soundPlayer.pausePlayer();
      print('AUDIO PLAYER WAS PAUSED');
    } else if (!_soundPlayer.isPlaying) {
      _soundPlayer.resumePlayer();
      print('AUDIO PLAYER WAS RESUMED');
    }
  }
}
