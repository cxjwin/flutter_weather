import 'package:flutter/material.dart';
import 'package:flutter_weather/models/weather_data.dart';
import 'package:flutter_weather/utils/weather_icons.dart';
import 'package:flutter_weather/view_models/global_style.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WeatherContent extends StatelessWidget {
  final WeatherData weather;

  WeatherContent({
    Key key,
    @required this.weather,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GlobalStyle style = context.watch<GlobalStyle>();
    int timeType = style.timeType;
    int temperatureType = style.temperatureType;
    int themeType = style.themeType;

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
