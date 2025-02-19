import 'package:flutter/material.dart';
import 'package:flutter_weather/pages/home_page.dart';
import 'package:flutter_weather/pages/locations_page.dart';
import 'package:flutter_weather/pages/settings_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Weather',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/locations': (context) => LocationsPage(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}
