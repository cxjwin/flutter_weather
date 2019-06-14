class WeatherData {
  final DateTime date;
  final String name;
  final double temp;
  final String main;
  final int id;
  final String icon;

  WeatherData({this.date, this.name, this.temp, this.main, this.id, this.icon});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      date:
          DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000, isUtc: false),
      name: json['name'],
      temp: json['main']['temp'].toDouble(),
      main: json['weather'][0]['main'],
      id: json['weather'][0]['id'],
      icon: json['weather'][0]['icon'],
    );
  }
}
