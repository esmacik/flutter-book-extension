import 'package:flutter/material.dart';
import 'tasks_db_worker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'tasks_model.dart';

class TasksList extends StatefulWidget {
  @override
  _TasksList createState() => _TasksList();
}

class _TasksList extends State<TasksList> {
  _deleteTask(BuildContext context, TasksModel model, Task task) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext alertContext) {
          return AlertDialog(
            title: const Text('Delete Task'),
            content: Text('Are you sure you want to delete ${task.description}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(alertContext).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                child: const Text('Delete'),
                onPressed: () async {
                  await TasksDBWorker.db.delete(task.id);
                  Navigator.of(alertContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                      content: Text('Task deleted'),
                    ),
                  );
                  model.loadData(TasksDBWorker.db);
                },
              )
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<TasksModel>(
        builder: (BuildContext context, Widget child, TasksModel model) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                model.entityBeingEdited = Task();
                model.setStackIndex(1);
              },
            ),
            body: ListView.builder(
              itemCount: model.entityList.length,
              itemBuilder: (BuildContext context, int index) {
                Task task = model.entityList[index];
                return Container(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Slidable(
                    actionPane: const SlidableDrawerActionPane(),
                    actionExtentRatio: .25,
                    secondaryActions: [
                      IconSlideAction(
                        caption: "Delete",
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: () => _deleteTask(context, model, task),
                      ),
                    ],
                    child: ListTile(
                      leading: Checkbox(
                        value: task.completed,
                        onChanged: (value) async {
                          setState(() {
                            task.completed = value;
                          });
                          await TasksDBWorker.db.update(task);
                        },
                      ),
                      title: Text(
                          '${task.description}',
                          style:
                          task.completed ?
                          TextStyle(color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough)
                              : null),
                      subtitle: Text(
                          '${task.dueDate}',
                          style:
                          task.completed ?
                          TextStyle(color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough)
                              : null),
                      onTap: () {
                        model.entityBeingEdited = task;
                        model.setStackIndex(1);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        }
    );
  }
}