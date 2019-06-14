import 'package:flutter/material.dart';
import 'package:flutter_weather/database/database.dart';
import 'package:flutter_weather/pages/add_page.dart';
import 'package:flutter_weather/utils/secrets.dart';

class LocationsPage extends StatefulWidget {
  final Map<String, dynamic> myLocation;

  LocationsPage({Key key, this.myLocation}) : super(key: key);

  @override
  _LocationsPageState createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  List<Map<String, dynamic>> _locations = [];

  @override
  void initState() {
    super.initState();
    loadLocations();
  }

  @override
  Widget build(BuildContext context) {
    Widget buildHeader(String text) => Container(
          height: 40,
          padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
          alignment: Alignment.centerLeft,
          child: Text(text, style: Theme.of(context).textTheme.title),
        );

    final myLocation = ListTile(
      title: Text(widget.myLocation['loc_desc']),
      leading: Icon(Icons.location_city),
      onTap: () {
        Navigator.pop(context);
      },
    );

    final items = <Widget>[];
    _locations.forEach((e) => {
          items.add(ListTile(
            title: Text(e["loc_desc"]),
            leading: Icon(Icons.location_city),
            onTap: () {
              Navigator.pop(context, e);
            },
          ))
        });

    items.add(ListTile(
      title: Text("Search More"),
      leading: Icon(Icons.location_searching),
      trailing: Icon(Icons.keyboard_arrow_right),
      onTap: () async {
        createPlaces(SecretLoader().secret.googleApiKey);
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddPage(SecretLoader().secret.googleApiKey),
          ),
        );

        if (result != null) {
          loadLocations();
        }
      },
    ));

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: IconButton(
          icon: const BackButtonIcon(),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: <Widget>[
          buildHeader('Current Location'),
          myLocation,
          buildHeader('Recent Locations'),
          ...items,
        ],
      ),
    );
  }

  Future<void> loadLocations() async {
    DatabaseManager manager = DatabaseManager();
    final locations = await manager.queryLocations();
    setState(() {
      _locations = locations;
    });
  }
}
