import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'single_workout.dart';
import 'workout_list.dart';

class Workout {

  int id;
  String type;
  String date;

  Workout({this.id, this.type, this.date});

  Map toMap() {
    Map map = new Map();
    map['id'] = id;
    map['type'] = type;
    map['date'] = date;

    return map;
  }

  Workout.fromMap(Map map) {
    id = map[id];
    type = map[type];
    date = map[date];
  }

}

connectToDatabase() async {
  String dir = (await getApplicationDocumentsDirectory()).path;

  print(dir + "assets/data.db");

  Database database = await openDatabase(dir + "assets/data.db", version: 1,
    onCreate: (Database db, int version) async {
      print('successfully created');
      // When creating the db, create the table
      await db.execute(
        "CREATE TABLE workouts (id INTEGER PRIMARY KEY, type TEXT, date TEXT)");
    }
  );

  Workout test = new Workout(id: 3, type: "pull", date: "2017-11-13");

  Map testMap = new Map();

  testMap['id'] = 2;
  testMap['type'] = "pull";
  testMap['date'] = "2017-11-12";

  //await database.insert("workouts", test.toMap());


  /*
  // Insert some records in a transaction
  await database.inTransaction(() async {
    int id1 = await database.rawInsert(
        'INSERT INTO workouts(id, type, date) VALUES(2, "pull", "2017-11-11")');
    print("inserted1: $id1");
  });
  */

  List<Map> list = await database.rawQuery('SELECT * FROM workouts');
  print(list[2]);

}

void main() {

  connectToDatabase();

  runApp(new WorkoutTrackerClient());
}

class WorkoutTrackerClient extends StatelessWidget {

  //taken from:
  //https://github.com/flutter/flutter/blob/master/examples/stocks/lib/main.dart#L122
  Route<Null> _getRoute(RouteSettings settings) {
    // Routes, by convention, are split on slashes, like filesystem paths.
    final List<String> path = settings.name.split('/');
    // We only support paths that start with a slash, so bail if
    // the first component is not empty:
    if (path[0] != '')
      return null;
    // If the path is "/workouts/date/..." then show a workout page for the
    // specified workout date.
    if (path[1] == 'workouts' && path[2] == 'date') {
      // We need a date, otherwise return
      if (path[3] == null)
        return null;
      // Extract the date of "workouts/date/..." and return a route
      // for that symbol.
      final String date = path[3];
      return new MaterialPageRoute<Null>(
        settings: settings,
        builder: (BuildContext context) => new SingleWorkout(date: date),
      );
    }
    // The other paths we support are in the routes table.
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Workout Tracker',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => new WorkoutList(),
      },
      onGenerateRoute: _getRoute,
    );
  }
}
