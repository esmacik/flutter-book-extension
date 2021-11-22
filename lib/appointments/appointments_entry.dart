import 'package:flutter/material.dart';
import 'appointments_db_worker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_book_non_nullsafe/utils.dart';
import 'appointments_model.dart';

class AppointmentsEntry extends StatelessWidget{
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _descriptionEditingController = TextEditingController();
  final TextEditingController _dateEditingController = TextEditingController();
  final TextEditingController _timeEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AppointmentsEntry(){
    _descriptionEditingController.addListener(() {
      appointmentsModel.entityBeingEdited.description = _descriptionEditingController.text;
    });
    _dateEditingController.addListener(() {
      appointmentsModel.entityBeingEdited.date = _dateEditingController.text;
    });
    _titleEditingController.addListener(() {
      appointmentsModel.entityBeingEdited.title = _titleEditingController.text;
    });
    _timeEditingController.addListener(() {
      appointmentsModel.entityBeingEdited.time = _timeEditingController.text;
    });
  }

  ListTile _buildTitleListTile() {
    return ListTile(
        leading: const Icon(Icons.title),
        title: TextFormField(
          decoration: const InputDecoration(hintText: 'Title'),
          controller: _titleEditingController,
          validator: (String value) {
            if(value.isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        )
    );
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

  ListTile _buildDateListTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.today),
      title: Text('Date'),
      subtitle: Text(_date()),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () async {
          String chosenDate = await selectDate(context, appointmentsModel,
              appointmentsModel.entityBeingEdited.date);
          if(chosenDate != null) {
            appointmentsModel.entityBeingEdited.date = chosenDate;
          }
        },
      ),
    );
  }

  ListTile _buildTimeListTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.alarm),
      title: const Text('Time'),
      subtitle: Text(appointmentsModel.time ?? ''),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () => _selectTime(context),
      ),
    );
  }

  String _date() {
    if(appointmentsModel.entityBeingEdited != null && appointmentsModel.entityBeingEdited.hasDate()) {
      return appointmentsModel.entityBeingEdited.date;
    }
    return '';
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay initialTime = TimeOfDay.now();
    if (appointmentsModel.entityBeingEdited.hasTime()) {
      initialTime = TimeOfDay(hour: int.parse(appointmentsModel.entityBeingEdited.time.split(':')[0]), minute: int.parse(appointmentsModel.entityBeingEdited.time.split(':')[1]));
    }
    TimeOfDay picked = await showTimePicker(context: context, initialTime: initialTime);
    if (picked != null) {
      appointmentsModel.entityBeingEdited.time = formatTime(picked);
      appointmentsModel.setTime(picked.format(context));
    }
  }

  Row _buildControlButtons(BuildContext context, AppointmentsModel model) {
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
          _save(context, appointmentsModel);
        },
      ),
    ],);
  }

  void _save(BuildContext context, AppointmentsModel model) async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    if (model.entityBeingEdited.id == null) {
      await AppointmentsDBWorker.db.create(appointmentsModel.entityBeingEdited);
    } else {
      await AppointmentsDBWorker.db.update(appointmentsModel.entityBeingEdited);
    }
    appointmentsModel.loadData(AppointmentsDBWorker.db);

    model.setStackIndex(0);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2), content: Text('Appointment saved'),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppointmentsModel>(builder: (BuildContext context, Widget child, AppointmentsModel model){
      _titleEditingController.text = (model.entityBeingEdited != null) ? model.entityBeingEdited.title : '';
      _descriptionEditingController.text = (model.entityBeingEdited != null) ? model.entityBeingEdited.description : '';
      _dateEditingController.text = (model.entityBeingEdited != null) ? model.entityBeingEdited.date : '';
      _timeEditingController.text = (model.entityBeingEdited != null) ? model.entityBeingEdited.time : '';
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
              _buildDescriptionListTile(),
              _buildDateListTile(context),
              _buildTimeListTile(context,)
            ],
          ),
        ),
      );
    });
  }
}