import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_book_non_nullsafe/appointments/appointments.dart';
import 'package:flutter_book_non_nullsafe/tasks/tasks.dart';
import 'package:flutter_book_non_nullsafe/voice_notes/voice_notes.dart';
import 'notes/notes.dart';

/// Main entry point for the application.
void main() {
  runApp(const FlutterBook());
}

/// Main `MaterialApp` for the FlutterBook application
class FlutterBook extends StatelessWidget {

  /// The list of tabs that the application will display.
  static const _TABS = [
    {'icon': Icons.date_range, 'name': 'Appointments'},
    {'icon': Icons.contacts, 'name': 'Contacts'},
    {'icon': Icons.note, 'name': 'Notes'},
    {'icon': Icons.assignment_turned_in, 'name': 'Tasks'},
    {'icon': Icons.mic, 'name': 'Voice Notes'}
  ];

  const FlutterBook({Key key}) : super(key: key);

  /// Build the main application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue
      ),
      home: DefaultTabController(
        length: _TABS.length, // 4
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Flutter Book'),
            bottom: TabBar(tabs: _TABS.map((tab) => Tab(icon: Icon(tab['icon']), text: tab['name'])).toList())
          ),
          body: TabBarView(
            children: _TABS.map((tab) => FlutterBookMainPage(tab['name'])).toList(),
          )
        )
      )
    );
  }
}

/// Main widget for a single tab of the home screen.
class FlutterBookMainPage extends StatelessWidget {

  /// The name of the tab.
  final _title;

  /// Simple constructor.
  const FlutterBookMainPage(this._title);

  /// Build the main screen of the application.
  @override
  Widget build(BuildContext context) {
    if (_title == 'Notes') return Notes();
    if (_title == 'Tasks') return Tasks();
    if (_title == 'Appointments') return Appointments();
    if (_title == 'Voice Notes') return VoiceNotes();
    return Center(child: Text(_title));
  }
}
