import 'package:flutter/material.dart';
import 'package:flutter_book_non_nullsafe/tasks/tasks_db_worker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_book_non_nullsafe/utils.dart';
import 'tasks_model.dart';

class TasksEntry extends StatelessWidget{
  final TextEditingController _descriptionEditingController = TextEditingController();
  final TextEditingController _dueDateEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TasksEntry(){
    _descriptionEditingController.addListener(() {
      tasksModel.entityBeingEdited.description = _descriptionEditingController.text;
    });
    _dueDateEditingController.addListener(() {
      tasksModel.entityBeingEdited.dueDate = _dueDateEditingController.text;
    });
  }

  ListTile _buildDescriptionListTile() {
    return ListTile(
        leading: const Icon(Icons.description),
        title: TextFormField(
          decoration: const InputDecoration(hintText: 'Description'),
          controller: _descriptionEditingController,
          validator: (String value) {
            if(value.isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
        )
    );
  }

  ListTile _buildDueDateListTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.today),
      title: const Text('Due Date'),
      subtitle: Text(_dueDate()),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        //: Colors.purple,
        onPressed: () async {
          String chosenDate = await selectDate(context, tasksModel,
            tasksModel.entityBeingEdited.dueDate);
          if(chosenDate != null) {
            tasksModel.entityBeingEdited.dueDate = chosenDate;
          }
        },
      ),
    );
  }

  String _dueDate() {
    if(tasksModel.entityBeingEdited != null && tasksModel.entityBeingEdited.hasDueDate()) {
      return tasksModel.entityBeingEdited.dueDate;
    }
    return '';
  }

  Row _buildControlButtons(BuildContext context, TasksModel model) {
    return Row(children: [
      TextButton(
        onPressed: () {
          FocusScope.of(context).requestFocus(FocusNode());
          model.setStackIndex(0);
        },
        child: const Text('Cancel'),
      ),
      const Spacer(),
      TextButton(
        child: const Text('Save'),
        onPressed: () {
          _save(context, tasksModel);
        },
      ),
    ],);
  }

  void _save(BuildContext context, TasksModel model) async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    if (model.entityBeingEdited.id == null) {
      await TasksDBWorker.db.create(tasksModel.entityBeingEdited);
    } else {
      await TasksDBWorker.db.update(tasksModel.entityBeingEdited);
    }
    tasksModel.loadData(TasksDBWorker.db);

    model.setStackIndex(0);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2), content: Text('Task saved'),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<TasksModel>(builder: (BuildContext context, Widget child, TasksModel model){
      _descriptionEditingController.text = (model.entityBeingEdited != null) ? model.entityBeingEdited.description : '';
      _dueDateEditingController.text = (model.entityBeingEdited != null) ? model.entityBeingEdited.dueDate : '';
      return Scaffold(
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: _buildControlButtons(context, model),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildDescriptionListTile(),
              _buildDueDateListTile(context),
            ],
          ),
        ),
      );
    });
  }
}