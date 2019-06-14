import 'dart:async' show Future;
import 'dart:convert' show json;

import 'package:flutter/services.dart' show rootBundle;

class Secret {
  final String weatherAppId;
  final String googleApiKey;

  Secret({this.weatherAppId = "", this.googleApiKey = ""});

  factory Secret.fromJson(Map<String, dynamic> jsonMap) {
    return new Secret(
      weatherAppId: jsonMap["WeatherAppId"],
      googleApiKey: jsonMap["GoogleApiKey"],
    );
  }
}

class SecretLoader {
  static final SecretLoader _singleton = SecretLoader._internal();

  factory SecretLoader() {
    return _singleton;
  }

  SecretLoader._internal() {
    //
  }

  Secret _secret;

  Secret get secret {
    return _secret;
  }

  Future<void> load() async {
    if (_secret != null) {
      return;
    }

    await rootBundle.loadStructuredData<Secret>('secrets.json', (jsonStr) {
      _secret = Secret.fromJson(json.decode(jsonStr));
    });
  }
}
