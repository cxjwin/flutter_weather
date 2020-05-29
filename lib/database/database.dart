import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  static final DatabaseManager _singleton = DatabaseManager._internal();

  factory DatabaseManager() {
    return _singleton;
  }

  DatabaseManager._internal();

  Database database;

  bool initialized = false;

  Future<void> init() async {
    if (initialized) {
      return;
    }

    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'app_database.db');

    database = await openDatabase(
      // Set the path to the database.
      path,
      // When the database is first created, create tables
      onCreate: (db, version) async {
        // Run the CREATE TABLE statement on the database
        await db.execute(
            "CREATE TABLE settings(id INTEGER PRIMARY KEY, type_name TEXT UNIQUE, type_value INTEGER);");
        await db.execute(
            "CREATE TABLE locations(id INTEGER PRIMARY KEY, place_id TEXT UNIQUE, loc_desc TEXT, lat REAL, lon REAL);");
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );

    initialized = true;
  }

  Future<void> set(String name, int value) async {
    if (name == null || name.length == 0) {
      return;
    }

    final count = await database.rawUpdate(
        "UPDATE settings SET type_value = ? WHERE type_name = ?",
        [value, name]);

    if (count == 0) {
      // update fail, insert data
      await database.rawInsert(
          "INSERT INTO settings(type_name, type_value) VALUES(?, ?)",
          [name, value]);
    }
  }

  Future<int> query(String name) async {
    if (name == null || name.length == 0) {
      return 0;
    }

    final value = Sqflite.firstIntValue(await database.query("settings",
        columns: ["type_value"], where: "type_name = ?", whereArgs: [name]));

    return value ?? 0;
  }

  Future<void> insertLocation(Map<String, dynamic> loc) async {
    if (loc == null) {
      return;
    }

    if (loc["loc_desc"] == null || loc["lat"] == null || loc["lon"] == null) {
      return;
    }

    int count = Sqflite.firstIntValue(
        await database.rawQuery('SELECT COUNT(*) FROM locations'));

    // limit 100 rows
    if (count > 100) {
      var res = await database.query("locations", orderBy: "id DESC", limit: 9);
      await database.delete("locations");
      res.add(loc);
      // insert 10 rows
      await database.transaction((txn) async {
        var batch = txn.batch();

        res.forEach((e) => {batch.insert("locations", e)});

        await batch.commit();
      });
    } else {
      await database.insert("locations", loc);
    }
  }

  Future<Map<String, dynamic>> queryLocationById(String id) async {
    if (id == null || id.length == 0) {
      return null;
    }

    final res = await database
        .query("locations", where: "place_id = ?", whereArgs: [id]);

    return res != null ? res.first : null;
  }

  Future<List<Map<String, dynamic>>> queryLocations() async {
    // query last 10 rows
    final res =
        await database.query("locations", orderBy: "id DESC", limit: 10);
    return res;
  }
}
