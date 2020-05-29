import 'package:flutter/material.dart';
import 'package:flutter_weather/models/weather_data.dart';
import 'package:flutter_weather/utils/weather_icons.dart';
import 'package:flutter_weather/view_models/global_style.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WeatherItem extends StatelessWidget {
  final WeatherData weather;

  WeatherItem({Key key, @required this.weather}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GlobalStyle style = context.watch<GlobalStyle>();
    int timeType = style.timeType;
    int temperatureType = style.temperatureType;

    final units = temperatureType == 0 ? '°C' : '°F';
    final hourString = timeType == 0
        ? DateFormat.jm().format(weather.date)
        : DateFormat.Hm().format(weather.date);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(weather.name, style: TextStyle(color: Colors.black)),
            Text(weather.main,
                style: TextStyle(color: Colors.black, fontSize: 24.0)),
            Text('${weather.temp.toString()}$units',
                style: TextStyle(color: Colors.black)),
            Container(
              height: 48,
              alignment: Alignment.topCenter,
              child: Icon(WeatherIcons.icon(weather.id, weather.icon),
                  size: 28, color: Colors.black),
            ),
            Text(DateFormat.yMMMd().format(weather.date),
                style: TextStyle(color: Colors.black)),
            Text(hourString, style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
