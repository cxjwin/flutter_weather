
import 'package:flutter/cupertino.dart';
import 'package:flutter_weather/database/database.dart';

class GlobalStyle with ChangeNotifier {
  int _timeType = 0;
  int _temperatureType = 0;
  int _themeType = -1; // default no image

  DatabaseManager manager = DatabaseManager();

  Future<void> loadStyle() async {
    await manager.init();
    _timeType = await manager.query("time_type");
    _temperatureType = await manager.query("temperature_type");
    _themeType = await manager.query("theme_type");
    notifyListeners();
  }

  set timeType(int type) {
    _timeType = type;
    manager.set("time_type", type);
    notifyListeners();
  }

  int get timeType => _timeType;

  set temperatureType(int type) {
    _temperatureType = type;
    manager.set("temperature_type", type);
    notifyListeners();
  }

  int get temperatureType => _temperatureType;

  set themeType (int type) {
    _themeType  = type;
    manager.set("theme_type ", type);
    notifyListeners();
  }

  int get themeType => _themeType;
}