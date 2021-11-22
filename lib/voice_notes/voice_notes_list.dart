import 'package:flutter/material.dart';
import 'package:flutter_book_non_nullsafe/voice_notes/voice_notes_db_worker.dart';
import 'package:flutter_book_non_nullsafe/voice_notes/voice_notes_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:scoped_model/scoped_model.dart';

/// The main widget for displaying voice notes in the application.
class VoiceNotesList extends StatelessWidget {

  /// Simple constructor.
  const VoiceNotesList({Key key}) : super(key: key);

  /// Delete a voice note from the databse.
  _deleteVoiceNote(BuildContext context, VoiceNotesModel model, VoiceNote voiceNote) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext alertContext) {
        return AlertDialog(
          title: const Text('Delete Voice Note'),
          content: Text('Are you sure you want to delete ${voiceNote.title}?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(alertContext).pop(),
            ),
            TextButton(
              child: const Text('Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                await VoiceNotesDBWorker.db.delete(voiceNote.id);
                Navigator.of(alertContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text('Voice Note Deleted'),
                  )
                );
                model.loadData(VoiceNotesDBWorker.db);
              },
            )
          ],
        );
      }
    );
  }

  /// Construct the widget that displays all voice notes.
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<VoiceNotesModel>(
      builder: (BuildContext context, Widget child, VoiceNotesModel model) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add, color: Colors.white,),
            onPressed: () {
              model.entityBeingEdited = VoiceNote();
              model.setStackIndex(1);
            },
          ),
          body: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2
            ),
            itemCount: model.entityList.length,
            itemBuilder: (BuildContext context, int index) {
              VoiceNote voiceNote = model.entityList[index];
              return Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Slidable(
                  actionPane: const SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  secondaryActions: [
                    IconSlideAction(
                      caption: 'Delete',
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () => _deleteVoiceNote(context, model, voiceNote)
                    )
                  ],
                  child: Card(
                    elevation: 10,
                    color: Colors.grey[700],
                    child: ListTile(
                      title: Text('${voiceNote.title}\n'),
                      subtitle: Text('Created: ${voiceNote.dateTime.toString()}'),
                      onTap: () {
                        model.entityBeingEdited = voiceNote;
                        model.setStackIndex(1);
                      },
                    ),
                  )
                ),
              );
            }
          ),
        );
      }
    );
  }
}