import 'package:flutter_book_non_nullsafe/notes/notes_db_worker.dart';
import 'package:flutter_book_non_nullsafe/voice_notes/voice_notes_model.dart';
import 'package:sqflite/sqflite.dart';

/// Abstract class defining simple methods a database should have.
abstract class VoiceNotesDBWorker {

  /// Define the database type, either memory or SQFLite.
  static final VoiceNotesDBWorker db = _SqfliteVoiceNotesDBWorker._();

  /// Create and add the given voice note in this database.
  Future<int> create(VoiceNote voiceNote);

  /// Update the given voice note of this database.
  Future<void> update(VoiceNote voiceNote);

  /// Delete the specified voice note.
  Future<void> delete(int id);

  /// Return the specified voice note, or null.
  Future<VoiceNote> get(int id);

  /// Return all the voice notes of this database.
  Future<List<VoiceNote>> getAll();
}

/// Save notes in memory for debugging.
class _MemoryVoiceNotesDBWorker implements VoiceNotesDBWorker {
  static const _TEST = true;

  /// The list of voice notes in working memory.
  var _voiceNotes = [];

  /// Gives each voice note an ID.
  var _nextId = 1;

  /// Private constructor for the memory database.
  _MemoryVoiceNotesDBWorker._() {
    if (_TEST && _voiceNotes.isEmpty) {
      var voiceNote = VoiceNote()
        ..title = 'A test voice note'
        ..dateTime = DateTime.now();
      create(voiceNote);
    }
  }

  /// Clone the given voice note.
  static VoiceNote _clone(VoiceNote voiceNote) {
    if (voiceNote != null) {
      return VoiceNote()
        ..title = voiceNote.title
        ..dateTime = voiceNote.dateTime
        ..filePath = voiceNote.filePath;
    }
    return null;
  }

  /// Add the voice note to the database.
  @override
  Future<int> create(VoiceNote voiceNote) async {
    voiceNote = _clone(voiceNote)..id = _nextId++;
    _voiceNotes.add(voiceNote);
    print('Added: $voiceNote');
    return voiceNote.id;
  }

  /// Delete the specified voice note.
  @override
  Future<void> delete(int id) async {
    _voiceNotes.removeWhere((n) => n.id == id);
  }

  /// Return the specified voice note, or null.
  @override
  Future<VoiceNote> get(int id) async {
    return _clone(_voiceNotes.firstWhere((n) => n.id == id, orElse: () => null));
  }

  /// Return all the voice notes of this database.
  @override
  Future<List<VoiceNote>> getAll() async {
    return List.unmodifiable(_voiceNotes);
  }

  /// Update the given voice note of this database.
  @override
  Future<void> update(VoiceNote voiceNote) async {
    var old = await get(voiceNote.id);
    if (old != null) {
      old
        ..title = voiceNote.title
        ..dateTime = voiceNote.dateTime
        ..filePath = voiceNote.filePath;
      print('Updated: $voiceNote');
    }
  }
}

/// Save notes in an SQFLite database.
class _SqfliteVoiceNotesDBWorker implements VoiceNotesDBWorker {

  /// The name of the database.
  static const String DB_NAME = 'voiceNotes.db';

  /// The name of the table storing voice notes.
  static const String TBL_NAME = 'voiceNotes';

  /// The key for voice note IDs.
  static const String KEY_ID = '_id';

  /// The key for voice note titles.
  static const String KEY_TITLE = 'title';

  /// The key for date time of voice notes.
  static const String KEY_DATETIME = 'dateTime';

  /// The key for file paths of voice notes.
  static const String KEY_PATH = 'filePath';

  /// The underlying database.
  Database _db;

  /// A private constructor for the SQFLite database.
  _SqfliteVoiceNotesDBWorker._();

  /// Get the behind the scenes database.
  Future<Database> get database async => _db ?? await _init();

  /// Create and add the given voice note in this database.
  @override
  Future<int> create(VoiceNote voiceNote) async {
    Database db = await database;
    int id = await db.rawInsert(
      "INSERT INTO $TBL_NAME ($KEY_TITLE, $KEY_DATETIME, $KEY_PATH) "
        "VALUES (?, ?, ?)",
      [voiceNote.title, voiceNote.dateTime.toString(), voiceNote.filePath]
    );
    return id;
  }

  /// Delete the specified voice note.
  @override
  Future<void> delete(int id) async {
    Database db = await database;
    await db.delete(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
  }

  /// Return the specified voice note, or null.
  @override
  Future<VoiceNote> get(int id) async {
    Database db = await database;
    var values = await db.query(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
    return values.isEmpty ? null : _voiceNoteFromMap(values.first);
  }

  /// Return all the voice notes of this database.
  @override
  Future<List<VoiceNote>> getAll() async {
    Database db = await database;
    var values = await db.query(TBL_NAME);
    return values.isNotEmpty ? values.map((m) => _voiceNoteFromMap(m)).toList() : [];
  }

  /// Update the given voice note of this database.
  @override
  Future<void> update(VoiceNote voiceNote) async {
    Database db = await database;
    await db.update(TBL_NAME, _voiceNoteToMap(voiceNote),
        where: "$KEY_ID = ?", whereArgs: [voiceNote.id]);
  }

  /// Create a voice note from a map.
  VoiceNote _voiceNoteFromMap(Map map) {
    return VoiceNote()
      ..id = map[KEY_ID]
      ..title = map[KEY_TITLE]
      ..dateTime = DateTime.parse(map[KEY_DATETIME])
      ..filePath = map[KEY_PATH];
  }

  /// Create a map from this voice note.
  Map<String, dynamic> _voiceNoteToMap(VoiceNote voiceNote) {
    return <String, dynamic>{}
      ..[KEY_ID] = voiceNote.id
      ..[KEY_TITLE] = voiceNote.title
      ..[KEY_DATETIME] = voiceNote.dateTime.toString()
      ..[KEY_PATH] = voiceNote.filePath;
  }

  /// Initialize the database of voice notes.
  Future<Database> _init() async {
    return await openDatabase(DB_NAME,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute(
          "CREATE TABLE IF NOT EXISTS $TBL_NAME ("
            "$KEY_ID INTEGER PRIMARY KEY,"
            "$KEY_TITLE TEXT,"
            "$KEY_DATETIME TEXT,"
            "$KEY_PATH TEXT"
            ")"
        );
      }
    );
  }
}