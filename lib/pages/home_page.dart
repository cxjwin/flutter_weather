import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_weather/database/database.dart';
import 'package:flutter_weather/models/forecast_data.dart';
import 'package:flutter_weather/models/weather_data.dart';
import 'package:flutter_weather/pages/locations_page.dart';
import 'package:flutter_weather/services/weather_service.dart';
import 'package:flutter_weather/utils/secrets.dart';
import 'package:flutter_weather/view_models/global_style.dart';
import 'package:flutter_weather/widgets/weather_chart.dart';
import 'package:flutter_weather/widgets/weather_content.dart';
import 'package:flutter_weather/widgets/weather_item.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  bool _isLoading = false;
  WeatherData _weatherData;
  ForecastData _forecastData;
  ForecastData _forecastDailyData;

  DatabaseManager manager = DatabaseManager();
  WeatherService service = WeatherService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());

    loadWeather();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    int themeType = context.watch<GlobalStyle>().themeType;

    DecorationImage bgImage;
    if (themeType >= 0) {
      bgImage = DecorationImage(
        image: AssetImage('assets/images/theme_$themeType.jpg'),
        fit: BoxFit.cover,
      );
    }

    final weatherContent = ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
          child: _weatherData != null
              ? WeatherContent(
                  weather: _weatherData,
                )
              : Container(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 28, 8, 8),
          child: _forecastData != null
              ? Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    child: WeatherChart.withForecastData(
                      _forecastData,
                    ),
                  ),
                )
              : Container(),
        )
      ],
    );

    var forecastList = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 200.0,
        child: _forecastData != null
            ? ListView.builder(
                itemCount: _forecastDailyData != null
                    ? _forecastDailyData.list.length
                    : 10,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => WeatherItem(
                  weather: _forecastDailyData.list.elementAt(index),
                ),
              )
            : Container(),
      ),
    );

    var actions = <Widget>[];
    if (_isLoading) {
      actions = <Widget>[
        IconButton(
          icon: Icon(Icons.settings),
          iconSize: 28,
          tooltip: 'settings',
          onPressed: showSettings,
        )
      ];
    } else {
      actions = <Widget>[
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
          onPressed: () {
            _refreshIndicatorKey.currentState.show();
          },
        ),
        IconButton(
          icon: Icon(Icons.settings),
          iconSize: 28,
          tooltip: 'settings',
          onPressed: showSettings,
        ),
      ];
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Flutter Weather'),
        leading: IconButton(
          icon: Icon(Icons.add_circle_outline),
          iconSize: 28,
          tooltip: 'add',
          onPressed: showAdd,
        ),
        actions: actions,
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: loadWeather,
        child: Container(
          decoration: BoxDecoration(
            image: bgImage,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: weatherContent,
              ),
              SafeArea(
                child: forecastList,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showAdd() async {
    // goto add page
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => LocationsPage(myLocation: {
                'loc_desc': service.desc,
                'lat': service.lat,
                'lon': service.lon,
              })),
    );
    service.selectedLocation = result;
    if (result != null) {
      _refreshIndicatorKey.currentState.show();
      loadWeather();
    }
  }

  Future<void> showSettings() async {
    // goto settings page
    final result = await Navigator.pushNamed(context, '/settings');
    if (result == null || result == 0) {
      return;
    }
    if (result == 1) {
      setState(() {});
    } else if (result == 2) {
      _refreshIndicatorKey.currentState.show();
      loadWeather();
    }
  }

  Future<void> loadWeather() async {
    setState(() {
      _isLoading = true;
    });

    await manager.init();
    await SecretLoader().load();

    int temperatureType = await manager.query("temperature_type");

    service.temperatureType = temperatureType;
    await service.getLocation();

    final weatherData = await service.queryWeatherData();
    final forecastData = await service.queryForecastData();
    final forecastDailyData = await service.queryForecastDailyData();

    if (weatherData == null ||
        forecastData == null ||
        forecastDailyData == null) {
      return setState(() {
        _isLoading = false;
      });
    }

    service.desc = weatherData.name;

    setState(() {
      _isLoading = false;
      _weatherData = weatherData;
      _forecastData = forecastData;
      _forecastDailyData = forecastDailyData;
    });
  }
}
