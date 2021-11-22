import 'notes_model.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'notes_db_worker.dart';

class NotesEntry extends StatelessWidget {

  Color _toColor(String color) {
    Color col = Colors.white;
    switch (color) {
      case "red" :
        col = Colors.red;
        break;
      case "green" :
        col = Colors.green;
        break;
      case "blue" :
        col = Colors.blue;
        break;
      case "yellow" :
        col = Colors.yellow;
        break;
      case "grey" :
        col = Colors.grey;
        break;
      case "purple" :
        col = Colors.purple;
        break;
    }
    return col;
  }

  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _contentEditingController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  NotesEntry() {
    _titleEditingController.addListener(() {
      notesModel.entityBeingEdited.title = _titleEditingController.text;
    });
    _contentEditingController.addListener(() {
      notesModel.entityBeingEdited.content = _contentEditingController.text;
    });
  }

  ListTile _buildTitleListTile() {
    return ListTile(
        leading: Icon(Icons.title),
        title: TextFormField(
          decoration: InputDecoration(hintText: 'Title'),
          controller: _titleEditingController,
          validator: (String value) {
            if (value.length == 0) {
              return 'Please enter a title';
            }
            return null;
          },
        )
    );
  }

  ListTile _buildContentListTile() {
    return ListTile(
        leading: Icon(Icons.content_paste),
        title: TextFormField(
            keyboardType: TextInputType.multiline,
            maxLines: 8,
            decoration: InputDecoration(hintText: 'Content'),
            controller: _contentEditingController,
            validator: (String value) {
              if (value.length == 0) {
                return 'Please enter content';
              }
              return null;
            }
        )
    );
  }

  ListTile _buildColorListTile(BuildContext context) {
    const colors = const ['red', 'green', 'blue', 'yellow', 'grey', 'purple'];
    return ListTile(
        leading: Icon(Icons.color_lens),
        title: Row(
            children: colors.expand((c) =>
            [_buildColorBox(context, c), Spacer()]).toList()..removeLast()
        )
    );
  }

  GestureDetector _buildColorBox(BuildContext context, String color) {
    final Color colorValue = _toColor(color);
    return GestureDetector(
        child: Container(
            decoration: ShapeDecoration(
                shape: Border.all(width: 16, color: colorValue) +
                    Border.all(width: 4,  color: notesModel.color == color ? colorValue : Theme.of(context).canvasColor)
            )
        ),
        onTap: () {
          notesModel.entityBeingEdited.color = color;
          notesModel.setColor(color);
        }
    );
  }

  Row _buildControlButtons(BuildContext context, NotesModel model) {
    return Row(children: [
      TextButton(
        child: Text('Cancel'),
        onPressed: () {
          FocusScope.of(context).requestFocus(FocusNode());
          model.setStackIndex(0);
        },
      ),
      Spacer(),
      TextButton(
        child: Text('Save'),
        onPressed: () {
          _save(context, notesModel);
        },
      )
    ]
    );
  }

  void _save(BuildContext context, NotesModel model) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    // if (!model.noteList.contains(model.noteBeingEdited)) {
    //   model.noteList.add(model.noteBeingEdited);
    // }

    if (model.entityBeingEdited.id == null) {
      await NotesDBWorker.db.create(notesModel.entityBeingEdited);
    } else {
      await NotesDBWorker.db.update(notesModel.entityBeingEdited);
    }
    notesModel.loadData(NotesDBWorker.db);


    model.setStackIndex(0);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2), content: Text('Note saved'),
      )
    );
  }


  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<NotesModel>(
        builder: (BuildContext context, Widget child, NotesModel model) {
          _titleEditingController.text = model.entityBeingEdited?.title;
          _contentEditingController.text = model.entityBeingEdited?.content;
          return Scaffold(
              bottomNavigationBar: Padding(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  child: _buildControlButtons(context, model)
              ),
              body: Form(
                  key: _formKey,
                  child: ListView(
                      children: [
                        _buildTitleListTile(),
                        _buildContentListTile(),
                        _buildColorListTile(context)
                      ]
                  )
              )
          );
        }
    );
  }
}
