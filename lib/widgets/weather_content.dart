import 'package:flutter/material.dart';
import 'package:flutter_weather/models/weather_data.dart';
import 'package:flutter_weather/utils/weather_icons.dart';
import 'package:intl/intl.dart';

class WeatherContent extends StatelessWidget {
  final timeType;
  final temperatureType;
  final themeType;
  final WeatherData weather;

  WeatherContent({
    Key key,
    this.timeType,
    this.temperatureType,
    this.themeType,
    @required this.weather,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final units = temperatureType == 0 ? '°C' : '°F';
    final hourString = timeType == 0
        ? DateFormat.jm().format(weather.date)
        : DateFormat.Hm().format(weather.date);

    var textColor = Colors.black38;
    switch (themeType) {
      case 1:
        textColor = Colors.white;
        break;
      case 2:
        textColor = Colors.black;
        break;
    }

    return Column(
      children: <Widget>[
        Text(weather.name, style: TextStyle(color: textColor)),
        Text(weather.main, style: TextStyle(color: textColor, fontSize: 32)),
        Text('${weather.temp.toString()}$units',
            style: TextStyle(color: textColor)),
        Container(
          height: 48,
          alignment: Alignment.topCenter,
          child: Icon(WeatherIcons.icon(weather.id, weather.icon),
              size: 28, color: textColor),
        ),
        Text(DateFormat.yMMMd().format(weather.date),
            style: TextStyle(color: textColor)),
        Text(hourString, style: TextStyle(color: textColor)),
      ],
    );
  }
}
