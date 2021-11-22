import 'package:sqflite/sqflite.dart';
import 'appointments_model.dart';

abstract class AppointmentsDBWorker {
  static final _SqfLiteAppointmentsDBWorker db = _SqfLiteAppointmentsDBWorker._();
  /// Create and add the given task in this database
  Future<int> create(Appointment appointment);

  /// Update the given task of this database.
  Future<void> update(Appointment appointment);

  /// Delete the specified task.
  Future<void> delete(int id);

  /// Return the specified task, or null.
  Future<Appointment> get(int id);

  /// Return all the tasks of this database.
  Future<List<Appointment>> getAll();
}

class _SqfLiteAppointmentsDBWorker implements AppointmentsDBWorker {

  static const String DB_NAME = 'appointments.db';
  static const String TBL_NAME = 'appointments';
  static const String KEY_ID = 'id';
  static const String KEY_TITLE = 'title';
  static const String KEY_DESCRIPTION = 'description';
  static const String KEY_DATE = 'date';
  static const String KEY_TIME = 'time';
  Database _db;
  //…
  _SqfLiteAppointmentsDBWorker._();

  Future<Database> get database async => _db ??= await _init();

  Future<Database> _init() async {
    return await openDatabase(DB_NAME,
        version: 1,
        onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute(
              "CREATE TABLE IF NOT EXISTS $TBL_NAME ("
                  "$KEY_ID INTEGER PRIMARY KEY,"
                  "$KEY_TITLE TEXT,"
                  "$KEY_DESCRIPTION TEXT,"
                  "$KEY_DATE TEXT,"
                  "$KEY_TIME TEXT"
                  ")"
          );
        }
    );
  }

  @override
  Future<int> create(Appointment appointment) async {
    Database db = await database;
    int id = await db.rawInsert(
        "INSERT INTO $TBL_NAME ($KEY_DESCRIPTION, $KEY_TITLE, $KEY_DESCRIPTION, $KEY_DATE, $KEY_TIME) "
            "VALUES (?,?,?,?,?)",
        [appointment.description, appointment.title, appointment.description, appointment.date, appointment.time]
    );
    return id;
  }

  @override
  Future<void> delete(int id) async {
    Database db = await database;
    await db.delete(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
  }

  @override
  Future<Appointment> get(int id) async {
    Database db = await database;
    var values = await db.query(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
    return _appointmentsFromMap(values.first);
  }

  @override
  Future<List<Appointment>> getAll() async {
    Database db = await database;
    var values = await db.query(TBL_NAME);
    List<Appointment> tasks = values.isNotEmpty ? values.map((m) => _appointmentsFromMap(m)).toList() : [];
    return tasks;
  }

  @override
  Future<void> update(Appointment appointment) async {
    Database db = await database;
    await db.update(TBL_NAME, _appointmentsToMap(appointment),
        where: "$KEY_ID = ?", whereArgs: [appointment.id]
    );
  }

  Appointment _appointmentsFromMap(Map map) {
    return Appointment()
      ..id = map[KEY_ID]
      ..title = map[KEY_TITLE]
      ..description = map[KEY_DESCRIPTION]
      ..date = map[KEY_DATE]
      ..time = map[KEY_TIME];
  }

  Map<String, dynamic> _appointmentsToMap(Appointment appointment) {
    return Map<String, dynamic>()
      ..[KEY_ID] = appointment.id
      ..[KEY_TITLE] = appointment.title
      ..[KEY_DESCRIPTION] = appointment.description
      ..[KEY_DATE] = appointment.date
      ..[KEY_TIME] = appointment.time;
  }
}
