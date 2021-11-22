import 'package:flutter_book_non_nullsafe/base_model.dart';

/// The global voice notes model
VoiceNotesModel voiceNotesModel = VoiceNotesModel();

/// Representation of voice notes in Flutter Book
class VoiceNote {

  /// The id of the voice note in the database.
  int id;

  /// The title of the voice note.
  String title;

  /// The title of the voice note.
  DateTime dateTime = DateTime.now();

  /// The path to the file that stores the voice note.
  String filePath;

  /// Convert to a string representation for the database.
  String toString() {
    return "{ id=$id, title=$title, dateTime=${dateTime.toString()}, filePath=$filePath}";
  }
}

/// The scoped model for voice notes.
class VoiceNotesModel extends BaseModel<VoiceNote> {

  /// Indicates whether or not a sound has been recorded.
  bool _soundRecorded = false;

  /// Indicates whether or not the recorder is recording.
  bool _isRecording = false;

  /// Set whether or not a sound has been recorded.
  set soundRecorded(bool soundRecorded) {
    _soundRecorded = soundRecorded;
    notifyListeners();
  }

  /// set whether or not the recorder is recording.
  set isRecording(bool isRecording) {
    _isRecording = isRecording;
    notifyListeners();
  }

  /// Get whether or not the recorder is recording.
  get isRecording => _isRecording;

  /// Get whether or not the recorder has recorded sound.
  get soundRecorded => _soundRecorded;
}