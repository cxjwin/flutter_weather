import 'package:flutter/material.dart';
import 'package:flutter_weather/pages/home_page.dart';
import 'package:flutter_weather/pages/locations_page.dart';
import 'package:flutter_weather/pages/settings_page.dart';
import 'package:flutter_weather/view_models/global_style.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Widget appWidget(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Weather',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: true,
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/locations': (context) => LocationsPage(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Widget provider = ChangeNotifierProvider(
      create: (_) => GlobalStyle()..loadStyle(),
      child: appWidget(context),
    );
    return provider;
  }
}
