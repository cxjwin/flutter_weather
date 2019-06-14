import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_weather/models/forecast_data.dart';
import 'package:flutter_weather/models/weather_data.dart';
import 'package:flutter_weather/utils/secrets.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class WeatherService {
  // Current weather data
  static const kWeatherAPI = "https://api.openweathermap.org/data/2.5/weather";
  // 5 day / 3 hour forecast
  static const kForecastAPI =
      "https://api.openweathermap.org/data/2.5/forecast";
  // 16 day / daily forecast
  static const kForecastDailyAPI =
      "https://api.openweathermap.org/data/2.5/forecast/daily";

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

    final tail = temperatureType == 0 ? 'units=metric' : 'units=imperial';

    final query =
        'APPID=$_appId&lat=${this.lat.toString()}&lon=${this.lon.toString()}&$tail';
    final weatherResponse = await http
        .get('https://api.openweathermap.org/data/2.5/weather?$query');

    if (weatherResponse.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(weatherResponse.body));
    }

    return null;
  }

  Future<ForecastData> queryForecastData() async {
    if (_appId == null || _appId.length == 0) {
      return null;
    }

    final tail = temperatureType == 0 ? 'units=metric' : 'units=imperial';

    final query =
        'APPID=$_appId&lat=${this.lat.toString()}&lon=${this.lon.toString()}&$tail';
    final forecastResponse = await http.get('$kForecastAPI?$query');

    if (forecastResponse.statusCode == 200) {
      return ForecastData.fromJson(jsonDecode(forecastResponse.body));
    }

    return null;
  }

  Future<ForecastData> queryForecastDailyData() async {
    if (_appId == null || _appId.length == 0) {
      return null;
    }

    final tail = temperatureType == 0 ? 'units=metric' : 'units=imperial';

    final query =
        'APPID=$_appId&lat=${this.lat.toString()}&lon=${this.lon.toString()}&$tail';
    final forecastResponse = await http.get('$kForecastDailyAPI?$query');

    if (forecastResponse.statusCode == 200) {
      return ForecastData.fromDailyJson(jsonDecode(forecastResponse.body));
    }

    return null;
  }
}
