import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_weather/database/database.dart';
import 'package:flutter_weather/widgets/segment_control.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, int> _oldSettings = {};
  Map<String, int> _settings = {};

  Future<void> loadSettings() async {
    DatabaseManager manager = DatabaseManager();
    int timeType = await manager.query("time_type");
    int temperatureType = await manager.query("temperature_type");
    int themeType = await manager.query("theme_type");

    final settings = {
      'time_type': timeType,
      'temperature_type': temperatureType,
      'theme_type': themeType,
    };

    _oldSettings = Map<String, int>.from(settings);

    setState(() {
      _settings = settings;
    });
  }

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    int timeType = _settings['time_type'];
    int temperatureType = _settings['temperature_type'];
    int themeType = _settings['theme_type'];

    Widget buildHeader(String text) => Container(
          height: 40,
          padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
          alignment: Alignment.centerLeft,
          child: Text(text, style: Theme.of(context).textTheme.title),
        );

    final timeSettings = <Widget>[
      buildHeader('Time'),
      SegmentControl(
        key: UniqueKey(),
        selectedIndex: timeType,
        titles: ['12h', '24h'],
        onPressed: (int index) => selectTimeType(index),
      ),
    ];

    final temperatureSettings = <Widget>[
      buildHeader('Temperature'),
      SegmentControl(
        key: UniqueKey(),
        selectedIndex: temperatureType,
        titles: ['°C', '°F'],
        onPressed: (int index) => selectTemperatureType(index),
      ),
    ];

    final themeInfo = [
      {'name': 'theme0', 'image': 'assets/images/theme_0.jpg'},
      {'name': 'theme1', 'image': 'assets/images/theme_1.jpg'},
      {'name': 'theme2', 'image': 'assets/images/theme_2.jpg'},
      {'name': 'theme3', 'image': 'assets/images/theme_3.jpg'},
    ];

    var items = <Widget>[];
    for (int i = 0; i < themeInfo.length; i++) {
      final info = themeInfo[i];
      if (i == themeType) {
        items.add(GridTile(
          child: InkResponse(
            enableFeedback: true,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Card(
                  child: Image.asset(
                    info['image'],
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 12, 12, 0),
                  alignment: Alignment.topRight,
                  child: Icon(Icons.check_circle_outline, color: Colors.white),
                ),
              ],
            ),
            onTap: () => selectThemeType(i),
          ),
        ));
      } else {
        items.add(GridTile(
          child: InkResponse(
            enableFeedback: true,
            child: Card(
              child: Image.asset(
                info['image'],
                fit: BoxFit.cover,
              ),
            ),
            onTap: () => selectThemeType(i),
          ),
        ));
      }
    }

    final themesGrid = GridView.count(
      primary: false,
      crossAxisCount: 2,
      shrinkWrap: true,
      childAspectRatio: 1.0,
      padding: const EdgeInsets.all(4.0),
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
      children: items,
    );

    final themes = <Widget>[
      buildHeader('Theme'),
      themesGrid,
    ];

    final children = <Widget>[
      ...timeSettings,
      ...temperatureSettings,
      ...themes,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: IconButton(
          icon: const BackButtonIcon(),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            final res =
                !DeepCollectionEquality().equals(_settings, _oldSettings);

            var type = 0;
            if (res) {
              type = 1;
              if (_settings['temperature_type'] !=
                  _oldSettings['temperature_type']) {
                type = 2;
              }
            }
            Navigator.pop(context, type);
          },
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.fromLTRB(0, 20, 0, 40),
        itemCount: children.length,
        itemBuilder: (context, index) {
          return children[index];
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
      ),
    );
  }

  selectTimeType(int index) {
    DatabaseManager manager = DatabaseManager();
    manager.set("time_type", index);
    _settings['time_type'] = index;
  }

  selectTemperatureType(int index) {
    DatabaseManager manager = DatabaseManager();
    manager.set("temperature_type", index);
    _settings['temperature_type'] = index;
  }

  selectThemeType(int index) {
    DatabaseManager manager = DatabaseManager();
    manager.set("theme_type", index);
    _settings['theme_type'] = index;
    final settings = Map<String, int>.from(_settings);
    // update UI
    setState(() {
      _settings = settings;
    });
  }
}
