import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'models.dart';

/*
 * interface to data to centralize all API call definitions.
 * also, this will manage the local SQL database and sync operations
 */

class DataInterface {

  String apiLocation;
  var client = createHttpClient();

  DataInterface({this.apiLocation});

  String newObjectID(){
    String increment = new Random().nextInt(16777216).floor().toRadixString(16);
    String pid = new Random().nextInt(65536).floor().toRadixString(16);
    String machine = new Random().nextInt(16777216).floor().toRadixString(16);
    String timestamp = (new DateTime.now().millisecondsSinceEpoch ~/ 1000 | 0).toRadixString(16);

    return timestamp + machine + pid + increment;
  }

  int newObjectIDint(){
    int result = int.parse(newObjectID(), radix: 16);
    print('newObjectIDint: '+result.toString());
    return result;
  }

  int timeStamp(){
    return new DateTime.now().millisecondsSinceEpoch ~/ 1000 | 0;
  }


  openDB() async {
    String dir = (await getApplicationDocumentsDirectory()).path;

    print(dir + "assets/data.db");


    Database database = await openDatabase(dir + "assets/data.db", version: 1,
      onCreate: (Database db, int version) async {
        print('successfully created');
        // When creating the db, create the table
        await db.execute(
          "CREATE TABLE workouts (id INTEGER PRIMARY KEY, mongoID TEXT, type TEXT, date TEXT)");
      }
    );

    int testTimeStamp = timeStamp();

    MetaWorkout test = new MetaWorkout(sqlID: testTimeStamp, mongoID: "mongoID", type: "pullTest", date: "2017-11-13");

    //await database.insert("workouts", test.toMap());

    List<Map> maps = await database.query("workouts",
        columns: ["id", "mongoID", "type", "date"],
        where: "id = ?",
        whereArgs: [testTimeStamp]);
    if (maps.length > 0) {
      print(new MetaWorkout.fromMap(maps.first).type);
    }
  }


  getMetaWorkouts() async {

    print(newObjectID());

    List<MetaWorkout> metaWorkouts = [];

    String url = apiLocation + '/workouts/meta/';
    var response = await client.read(url);
    List data = JSON.decode(response); //list of objects to be converted

    //convert response objects into MetaWorkouts
    for(int i = 0; i < data.length; i++){
      metaWorkouts.add(new MetaWorkout.fromMap(data[i]));
    }

    return metaWorkouts;
  }

  getWorkout(date) async {
    String url = apiLocation + '/workouts/date/'+date;
    var response = await client.read(url);
    Map data = JSON.decode(response);

    return new Workout.fromResponse(data);
  }

}
