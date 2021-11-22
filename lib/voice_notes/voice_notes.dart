import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'voice_notes_entry.dart';
import 'voice_notes_model.dart' show VoiceNotesModel, voiceNotesModel;
import 'voice_notes_model.dart';
import 'voice_notes_list.dart';
import 'voice_notes_db_worker.dart';

/// The main widget for the voice notes tab in FlutterBook.
class VoiceNotes extends StatelessWidget {

  /// Simple constructor where data is loaded from that database on creation.
  VoiceNotes() {
    voiceNotesModel.loadData(VoiceNotesDBWorker.db);
  }

  /// Build the voice notes tab in the application.
  @override
  Widget build(BuildContext context) {
    return ScopedModel<VoiceNotesModel>(
      model: voiceNotesModel,
      child: ScopedModelDescendant<VoiceNotesModel>(
        builder: (BuildContext context, Widget child, VoiceNotesModel model) {
          return IndexedStack(
            index: model.stackIndex,
            children: <Widget>[const VoiceNotesList(), VoiceNotesEntry()],
          );
        }
      )
    );
  }
}
