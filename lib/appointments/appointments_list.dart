import 'package:flutter/material.dart';
import 'package:flutter_book_non_nullsafe/appointments/appointments_db_worker.dart';
import 'package:flutter_book_non_nullsafe/utils.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'appointments_model.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';

class AppointmentsList extends StatefulWidget {
  @override
  _AppointmentsList createState() => _AppointmentsList();
}

class _AppointmentsList extends State<AppointmentsList> {
  _deleteAppointment(BuildContext context, AppointmentsModel model, Appointment appointment) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext alertContext) {
          return AlertDialog(
            title: const Text('Delete Appointment'),
            content: Text('Are you sure you want to delete ${appointment.title}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(alertContext).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                child: const Text('Delete'),
                onPressed: () async {
                  await AppointmentsDBWorker.db.delete(appointment.id);
                  Navigator.of(alertContext).pop();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                      content: Text('Appointment deleted'),
                    ),
                  );
                  model.loadData(AppointmentsDBWorker.db);
                },
              )
            ],
          );
        }
    );
  }

  void _showAppointments(DateTime date, BuildContext context, AppointmentsModel model) async {
    var filteredDates = model.entityList.where((a) => a.date == '${date.year}/${date.month}/${date.day}');
    return showModalBottomSheet(
      builder: (BuildContext context) {
        return Column(children: [
          Container(
            padding: const EdgeInsets.all(13),
            child: Text(DateFormat.yMMMMEEEEd().format(date),
              style: const TextStyle(color: Colors.blue, fontSize: 24),
            ),
          ),
          const Divider(
            thickness: 2,
            indent: 10,
            endIndent: 10,
          ),
          Expanded(
              child: ListView.builder(
                shrinkWrap: false,
                itemCount: filteredDates.length,
                itemBuilder: (BuildContext context, int index) {
                  Appointment app = filteredDates.elementAt(index);
                  if(app.date != "${date.year}/${date.month}/${date.day}") {
                    return Container(height: 0);
                  }
                  return Slidable(
                    actionPane: const SlidableDrawerActionPane(),
                    actionExtentRatio: .25,
                    child: Container(
                        margin: EdgeInsets.all(10),
                        height: 75,
                        child: ListTile(
                            title: Text('${app.title} (${app.time})', style: TextStyle(color: Colors.black)),
                            subtitle: Text('${app.description}', style: TextStyle(color: Colors.black54)),
                            onTap: () {
                              model.entityBeingEdited = app;
                              model.setStackIndex(1);
                              Navigator.of(context).pop();
                            }
                        )
                    ),
                    secondaryActions: [
                      IconSlideAction(
                        caption: "Delete",
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: () => _deleteAppointment(context, model, app),
                      ),
                    ],
                  );
                },
              ))
        ],);
      }, context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    EventList<Event> markedDateMap = EventList<Event>(events: {DateTime.now() : [Event(date: DateTime.now())]});
    if(appointmentsModel.entityList.isNotEmpty) {
      for (Appointment app in appointmentsModel.entityList) {
        DateTime date = toDate(app.date);
        markedDateMap.add(date, Event(date: date,
            icon: Container(
                decoration: const BoxDecoration(color: Colors.black))));
      }
    }
    return ScopedModelDescendant<AppointmentsModel>(
        builder: (BuildContext context, Widget child, AppointmentsModel model) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                model.entityBeingEdited = Appointment();
                model.setStackIndex(1);
              },
            ),
            body: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: CalendarCarousel<Event>(
                  thisMonthDayBorderColor: Colors.grey,
                  daysHaveCircularBorder: false,
                  markedDatesMap: markedDateMap,
                  onDayPressed: (DateTime date, List<Event> events) {
                    _showAppointments(date, context, model);
                  },
                )
            ),
          );
        }
    );
  }
}