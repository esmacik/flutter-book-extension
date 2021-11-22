import 'package:flutter_book_non_nullsafe/base_model.dart';

TasksModel tasksModel = TasksModel();

class Task {
  int id;
  String description;
  String dueDate;
  bool completed = false; // note that the textbook uses String.

  String toString() {
    return "{ id=$id, description=$description, dueDate=$dueDate, completed=$completed }";
  }

  bool hasDueDate() {
    return dueDate != null;
  }
}

class TasksModel extends BaseModel<Task> with DateSelection {
}
