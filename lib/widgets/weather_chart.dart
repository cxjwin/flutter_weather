import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_weather/models/forecast_data.dart';
import 'package:flutter_weather/models/weather_data.dart';
import 'package:flutter_weather/view_models/global_style.dart';
import 'package:provider/provider.dart';

class WeatherChart extends StatelessWidget {
  final List<charts.Series<TemperatureRow, DateTime>> seriesList;
  final List staticTicks;
  final bool animate;

  WeatherChart(this.seriesList, this.staticTicks, {this.animate});

  factory WeatherChart.withForecastData(ForecastData data) {
    List<WeatherData> list = data.list.sublist(0, 12);
    return WeatherChart(
      _createForecastData(list),
      _createForecastTicks(list),
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final units =
        context.watch<GlobalStyle>().temperatureType == 0 ? '°C' : '°F';

    final customTickFormatter =
        charts.BasicNumericTickFormatterSpec((num value) => '$value$units');

    return charts.TimeSeriesChart(seriesList,
        animate: animate,
        // Sets up a currency formatter for the measure axis.
        primaryMeasureAxis:
            charts.NumericAxisSpec(tickFormatterSpec: customTickFormatter),

        // List<TickSpec<DateTime>> tickSpecs;

        /// Customizes the date tick formatter. It will print the day of month
        /// as the default format, but include the month and year if it
        /// transitions to a new month.
        ///
        /// minute, hour, day, month, and year are all provided by default and
        /// you can override them following this pattern.
        domainAxis: charts.DateTimeAxisSpec(
            tickProviderSpec:
                charts.StaticDateTimeTickProviderSpec(this.staticTicks),
            tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
                hour: charts.TimeFormatterSpec(
                    format: 'h', transitionFormat: 'MM/dd HH'))));
  }

  static List<charts.Series<TemperatureRow, DateTime>> _createForecastData(
      List<WeatherData> list) {
    List<TemperatureRow> data = <TemperatureRow>[];

    list.forEach((e) => data.add(TemperatureRow(e.date, e.temp)));

    return [
      charts.Series<TemperatureRow, DateTime>(
        id: 'Temperature',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TemperatureRow row, _) => row.timeStamp,
        measureFn: (TemperatureRow row, _) => row.temperature,
        data: data,
      )
    ];
  }

  static List<charts.TickSpec<DateTime>> _createForecastTicks(
      List<WeatherData> list) {
    List<charts.TickSpec<DateTime>> specs = List<charts.TickSpec<DateTime>>();

    for (int i = 0; i < list.length; i++) {
      if (i % 2 == 0) {
        specs.add(charts.TickSpec(list[i].date));
      }
    }

    return specs;
  }
}

/// Sample time series data type.
class TemperatureRow {
  final DateTime timeStamp;
  final double temperature;

  TemperatureRow(this.timeStamp, this.temperature);
}
