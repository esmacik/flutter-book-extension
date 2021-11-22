import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';

class ConfigModel extends Model {
  Color _color = Colors.red;

  Color get color => _color;

  void setColor(Color color) {
    _color = color;
    notifyListeners();
  }
}

class ScopedModelPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scoped Model')),
          body: ScopedModel<ConfigModel>(
          model: ConfigModel(),
        child: Column(
          children: <Widget>[
            ScopedModelUpdater(),
            ScopedModelText('Hello World!')
          ],
        ),
      ),
    );
  }
}

class ScopedModelText extends StatelessWidget {
  final text;

  ScopedModelText(this.text);

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<ConfigModel>(
      builder: (BuildContext context, Widget child, ConfigModel config) =>
        Text('$text', style: TextStyle(color: config.color))
    );
  }
}

class ScopedModelUpdater extends StatelessWidget {
  static const _colors = const [Colors.red, Colors.green, Colors.blue];

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<ConfigModel>(
        builder: (BuildContext context, Widget child, ConfigModel config) =>
            DropdownButton(
                value: config.color,
                items: _colors.map((Color color) =>
                    DropdownMenuItem(
                      value: color,
                      child: Container(width: 100, height: 20, color: color),
                    )).toList(),
                onChanged: (Color color) => config.setColor(color)
            )
    );
  } }

