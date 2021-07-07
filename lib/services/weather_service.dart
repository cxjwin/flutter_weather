import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_weather/models/forecast_data.dart';
import 'package:flutter_weather/models/weather_data.dart';
import 'package:flutter_weather/utils/secrets.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class WeatherService {
  // Base
  static const kBaseHost = "api.openweathermap.org";
  // Current weather data
  static const kWeatherPath = "/data/2.5/weather";
  // 5 day / 3 hour forecast
  static const kForecastPath = "/data/2.5/forecast";
  // 16 day / daily forecast
  static const kForecastDailyPath = "/data/2.5/forecast/daily";

  int temperatureType = 0;

  Map<String, dynamic> selectedLocation;

  // default location
  String desc = 'My Location';
  double lat = 39.9042;
  double lon = 116.4074;
  String error;

  String _appId;
  Location _location = Location();

  Future<void> getLocation() async {
    if (_appId == null) {
      _appId = SecretLoader().secret.weatherAppId;
    }
    if (selectedLocation != null) {
      this.desc = selectedLocation['loc_desc'];
      this.lat = selectedLocation['lat'];
      this.lon = selectedLocation['lon'];
      return;
    }

    LocationData location;
    try {
      error = null;
      location = await _location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permission denied';
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error =
            'Permission denied - please ask the user to enable it from the app settings';
      }
      location = null;
    }

    if (location != null) {
      this.lat = location.latitude;
      this.lon = location.longitude;
    }
  }

  Future<WeatherData> queryWeatherData() async {
    if (_appId == null || _appId.length == 0) {
      return null;
    }
    final uri = Uri.http(kBaseHost, kWeatherPath, {
      'APPID': _appId,
      'lat': this.lat.toString(),
      'lon': this.lon.toString(),
      'units': temperatureType == 0 ? 'metric' : 'imperial',
    });
    final weatherResponse = await http.get(uri);

    if (weatherResponse.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(weatherResponse.body));
    }

    return null;
  }

  Future<ForecastData> queryForecastData() async {
    if (_appId == null || _appId.length == 0) {
      return null;
    }

    final uri = Uri.http(kBaseHost, kForecastPath, {
      'APPID' : _appId,
      'lat' : this.lat.toString(),
      'lon' : this.lon.toString(),
      'units' : temperatureType == 0 ? 'metric' : 'imperial'
    });
    final forecastResponse = await http.get(uri);

    if (forecastResponse.statusCode == 200) {
      return ForecastData.fromJson(jsonDecode(forecastResponse.body));
    }

    return null;
  }

  Future<ForecastData> queryForecastDailyData() async {
    if (_appId == null || _appId.length == 0) {
      return null;
    }

    final uri = Uri.http(kBaseHost, kForecastDailyPath, {
      'APPID' : _appId,
      'lat' : this.lat.toString(),
      'lon' : this.lon.toString(),
      'units' : temperatureType == 0 ? 'metric' : 'imperial'
    });
    final forecastResponse = await http.get(uri);

    if (forecastResponse.statusCode == 200) {
      return ForecastData.fromDailyJson(jsonDecode(forecastResponse.body));
    }

    return null;
  }
}
