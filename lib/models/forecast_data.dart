import 'package:flutter_weather/models/weather_data.dart';

class ForecastData {
  final List<WeatherData> list;

  ForecastData({this.list});

  factory ForecastData.fromJson(Map<String, dynamic> json) {
    List<WeatherData> list = <WeatherData>[];

    for (dynamic e in json['list']) {
      WeatherData w = WeatherData(
        date: DateTime.fromMillisecondsSinceEpoch(e['dt'] * 1000, isUtc: false),
        name: json['city']['name'],
        temp: e['main']['temp'].toDouble(),
        main: e['weather'][0]['main'],
        id: e['weather'][0]['id'],
        icon: e['weather'][0]['icon'],
      );
      list.add(w);
    }

    return ForecastData(list: list);
  }

  factory ForecastData.fromDailyJson(Map<String, dynamic> json) {
    List<WeatherData> list = <WeatherData>[];

    for (dynamic e in json['list']) {
      WeatherData w = WeatherData(
        date: DateTime.fromMillisecondsSinceEpoch(e['dt'] * 1000, isUtc: false),
        name: json['city']['name'],
        temp: e['temp']['day'].toDouble(),
        main: e['weather'][0]['main'],
        id: e['weather'][0]['id'],
        icon: e['weather'][0]['icon'],
      );
      list.add(w);
    }

    return ForecastData(list: list);
  }
}
