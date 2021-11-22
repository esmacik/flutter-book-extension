import 'package:sqflite/sqflite.dart';
import 'tasks_model.dart';

abstract class TasksDBWorker {
  static final TasksDBWorker db = _SqfliteTasksDBWorker._();
  /// Create and add the given task in this database
  Future<int> create(Task task);

  /// Update the given task of this database.
  Future<void> update(Task task);

  /// Delete the specified task.
  Future<void> delete(int id);

  /// Return the specified task, or null.
  Future<Task> get(int id);

  /// Return all the tasks of this database.
  Future<List<Task>> getAll();
}

class _SqfliteTasksDBWorker implements TasksDBWorker {
  static const String DB_NAME = 'tasks.db';
  static const String TBL_NAME = 'tasks';
  static const String KEY_ID = 'id';
  static const String KEY_DESCRIPTION = 'description';
  static const String KEY_DUE_DATE = 'dueDate';
  static const String KEY_COMPLETED = 'completed';
  Database _db;

  _SqfliteTasksDBWorker._();

  Future<Database> get database async => _db ??= await _init();

  Future<Database> _init() async {
    return await openDatabase(DB_NAME,
        version: 1,
        onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute(
              "CREATE TABLE IF NOT EXISTS $TBL_NAME ("
                  "$KEY_ID INTEGER PRIMARY KEY,"
                  "$KEY_DESCRIPTION TEXT,"
                  "$KEY_DUE_DATE TEXT,"
                  "$KEY_COMPLETED BOOL"
                  ")"
          );
        }
    );
  }

  @override
  Future<int> create(Task task) async {
    Database db = await database;
    int id = await db.rawInsert(
        "INSERT INTO $TBL_NAME ($KEY_DESCRIPTION, $KEY_DUE_DATE, $KEY_COMPLETED) "
            "VALUES (?,?,?)",
        [task.description, task.dueDate, task.completed]
    );
    return id;
  }

  @override
  Future<void> update(Task task) async {
    Database db = await database;
    await db.update(TBL_NAME, _tasksToMap(task),
        where: "$KEY_ID = ?", whereArgs: [task.id]
    );
  }

  @override
  Future<void> delete(int id) async {
    Database db = await database;
    await db.delete(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
  }

  @override
  Future<Task> get(int id) async {
    Database db = await database;
    var values = await db.query(TBL_NAME, where: "$KEY_ID = ?", whereArgs: [id]);
    return _tasksFromMap(values.first);
  }

  @override
  Future<List<Task>> getAll() async {
    Database db = await database;
    var values = await db.query(TBL_NAME);
    List<Task> tasks = values.isNotEmpty ? values.map((m) => _tasksFromMap(m)).toList() : [];
    return tasks;
  }

  Task _tasksFromMap(Map map) {
    return Task()
      ..id = map[KEY_ID]
      ..description = map[KEY_DESCRIPTION]
      ..dueDate = map[KEY_DUE_DATE];
  }

  Map<String, dynamic> _tasksToMap(Task task) {
    return Map<String, dynamic>()
      ..[KEY_ID] = task.id
      ..[KEY_DESCRIPTION] = task.description
      ..[KEY_DUE_DATE] = task.dueDate;
  }
}
