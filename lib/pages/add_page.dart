import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_weather/database/database.dart';
import 'package:google_maps_webservice/places.dart';

// to get places detail (lat/lng)
GoogleMapsPlaces _places;
createPlaces(String key) {
  if (_places != null) {
    return;
  }
  if (key == null || key.length == 0) {
    return;
  }
  _places = GoogleMapsPlaces(apiKey: key);
}

class AddPage extends PlacesAutocompleteWidget {
  AddPage(String apiKey)
      : super(
          apiKey: apiKey,
          sessionToken: Uuid().generateV4(),
          language: "en",
          components: [Component(Component.country, "us")],
        );

  @override
  _AddPageState createState() => _AddPageState();
}

Future<Null> displayPrediction(
    BuildContext context, Prediction p, ScaffoldState scaffold) async {
  if (p != null) {
    // get detail (lat/lng)
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
    final lat = detail.result.geometry.location.lat;
    final lng = detail.result.geometry.location.lng;

    scaffold.showSnackBar(
      SnackBar(content: Text("${p.description} - $lat/$lng")),
    );

    // save to db
    DatabaseManager manager = DatabaseManager();
    final loc = {
      'loc_desc': p.description,
      'lat': lat,
      'lon': lng,
    };
    await manager.insertLocation(loc);

    // pop
    Navigator.pop(context, loc);
  }
}

final searchScaffoldKey = GlobalKey<ScaffoldState>();

class _AddPageState extends PlacesAutocompleteState {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: searchScaffoldKey,
      appBar: AppBar(
        title: AppBarPlacesAutoCompleteTextField(),
        leading: BackButton(),
      ),
      body: PlacesAutocompleteResult(
        onTap: (p) {
          displayPrediction(context, p, searchScaffoldKey.currentState);
        },
        logo: Row(
          children: [FlutterLogo()],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }

  @override
  void onResponseError(PlacesAutocompleteResponse response) {
    super.onResponseError(response);
    searchScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  @override
  void onResponse(PlacesAutocompleteResponse response) {
    super.onResponse(response);
    if (response != null && response.predictions.isNotEmpty) {
      searchScaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text("Got answer")),
      );
    }
  }
}

class Uuid {
  final Random _random = Random();

  String generateV4() {
    // Generate xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx / 8-4-4-4-12.
    final int special = 8 + _random.nextInt(4);

    return '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}-'
        '${_bitsDigits(16, 4)}-'
        '4${_bitsDigits(12, 3)}-'
        '${_printDigits(special, 1)}${_bitsDigits(12, 3)}-'
        '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}';
  }

  String _bitsDigits(int bitCount, int digitCount) =>
      _printDigits(_generateBits(bitCount), digitCount);

  int _generateBits(int bitCount) => _random.nextInt(1 << bitCount);

  String _printDigits(int value, int count) =>
      value.toRadixString(16).padLeft(count, '0');
}
