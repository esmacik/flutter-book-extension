import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_book_non_nullsafe/voice_notes/sound/sound_recorder.dart';
import 'package:flutter_book_non_nullsafe/voice_notes/sound/sound_player.dart';
import 'package:flutter_book_non_nullsafe/voice_notes/voice_notes_db_worker.dart';
import 'package:flutter_book_non_nullsafe/voice_notes/voice_notes_model.dart';
import 'package:scoped_model/scoped_model.dart';

/// The main widget for ceating and editing voice notes in FlutterBook.
class VoiceNotesEntry extends StatelessWidget {

  /// The object used to record sound.
  final SoundRecorder _soundRecorder = SoundRecorder.instance;

  /// The object used to play sound.
  final SoundPlayer _soundPlayer = SoundPlayer.instance;

  /// The constroller for the title text field in this widget.
  final TextEditingController _titleEditingController = TextEditingController();

  /// The key for the fields in this widget.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Simple constructor that sets the title field upon creation.
  VoiceNotesEntry({Key key}) : super(key: key) {
    _titleEditingController.addListener(() {
      voiceNotesModel.entityBeingEdited.title = _titleEditingController.text;
    });
  }

  /// Build the widget that accepts the name of the voice note.
  ListTile _buildTitleListTile() {
    return ListTile(
      leading: const Icon(Icons.title),
      title: TextFormField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Title'
        ),
        controller: _titleEditingController,
        validator: (String value) {
          if (value.isEmpty) {
            return 'Please enter a title.';
          }
          return null;
        },
      ),
    );
  }

  /// Build the widget that will display the date and time the voice note was created.
  ListTile _buildDateTimeListTile() {
    return ListTile(
      leading: const Icon(Icons.calendar_today),
      title: Text(voiceNotesModel.entityBeingEdited?.dateTime.toString()),
    );
  }

  /// Build the widget that indicated whether or not this entity has a recording.
  ListTile _buildIsAudioRecordedTile() {
    return ListTile(
      leading: Icon(
        voiceNotesModel.entityBeingEdited.filePath != null ? Icons.check : Icons.cancel,
        color: voiceNotesModel.entityBeingEdited.filePath != null ? Colors.green : Colors.red
      ),
      title: Text(voiceNotesModel.entityBeingEdited.filePath != null ? 'Audio note has been recorded.' : 'Audio note has not been recorded.'),
    );
  }

  /// Build the cancel and save buttons for this screen.
  Row _buildControlButtons(BuildContext context, VoiceNotesModel model) {
    return Row(
      children: [
        TextButton(
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            FocusScope.of(context).requestFocus(FocusNode());
            model.setStackIndex(0);
          },
        ),
        const Spacer(),
        TextButton(
          child: const Text('Save'),
          onPressed: () {
            _save(context, model);
          },
        ),
      ],
    );
  }

  /// Convert the file name to one that does not have colons or spaces.
  String _toCompatibleFileName(VoiceNote voiceNote) =>
    voiceNote.dateTime.toString().replaceAll(RegExp(r'[:_]'), "_");

  /// Check whether or not the given file exists.
  Future<bool> _fileExists(String filePath) async => await File(filePath).exists();

  /// Build the buttons that are used to create and preview recording.
  Widget _buildAudioButtons(VoiceNotesModel model) {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: Icon(Icons.mic),
          label: Text(voiceNotesModel.isRecording ? 'STOP RECORDING' : 'START RECORDING'),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(voiceNotesModel.isRecording ? Colors.red : Colors.green),
          ),
          onPressed: () async {
            String localPathWithFileName = '${await _localPath}/${_toCompatibleFileName(voiceNotesModel.entityBeingEdited)}.aac';
            voiceNotesModel.entityBeingEdited.filePath = localPathWithFileName;
            await _soundRecorder.toggleRecording(localPathWithFileName);
            print('Recording is saved at $localPathWithFileName');
            voiceNotesModel.isRecording = _soundRecorder.isRecording;

            if (await _fileExists(localPathWithFileName)) voiceNotesModel.soundRecorded = true;
          },
        ),
        ElevatedButton(
          child: Text('PREVIEW VOICE NOTE'),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.green)
          ),
          onPressed: () async {
            String localPathWithFileName = '${await _localPath}/${_toCompatibleFileName(voiceNotesModel.entityBeingEdited)}.aac';
            await _soundPlayer.togglePlaying(localPathWithFileName);
            print('Playing file from: $localPathWithFileName');
          },
        )
      ],
    );
  }

  /// Save the current entity in the database.
  _save(BuildContext context, VoiceNotesModel model) async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    if (model.entityBeingEdited.id == null) {
      await VoiceNotesDBWorker.db.create(voiceNotesModel.entityBeingEdited);
    } else {
      await VoiceNotesDBWorker.db.update(voiceNotesModel.entityBeingEdited);
    }

    voiceNotesModel.loadData(VoiceNotesDBWorker.db);

    model.setStackIndex(0);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice note saved!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      )
    );
  }

  /// Get the location of the application's local files folder.
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Build the main voice note entry widget.
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<VoiceNotesModel>(
      builder: (BuildContext context, Widget child, VoiceNotesModel model) {
        _titleEditingController.text = model.entityBeingEdited?.title;
        return Scaffold(
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            child: _buildControlButtons(context, model),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildTitleListTile(),
                _buildIsAudioRecordedTile(),
                _buildDateTimeListTile(),
                _buildAudioButtons(model),
              ],
            ),
          ),
        );
      }
    );
  }
}
