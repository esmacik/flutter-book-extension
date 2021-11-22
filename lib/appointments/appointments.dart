import 'package:flutter/material.dart';
import 'appointments_db_worker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'appointments_entry.dart';
import 'appointments_model.dart' show appointmentsModel, AppointmentsModel;
import 'appointments_list.dart';

class Appointments extends StatelessWidget {
  Appointments () {
    appointmentsModel.loadData(AppointmentsDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppointmentsModel>(
        model: appointmentsModel,
        child: ScopedModelDescendant<AppointmentsModel>(
          builder: (BuildContext context, Widget child, AppointmentsModel model) {
            return IndexedStack(
              index: model.stackIndex,
              children: <Widget>[AppointmentsList(), AppointmentsEntry()],
            );
          },
        )
    );
  }
}