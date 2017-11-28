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

class DatabaseInterface {

  Database database;

  int timeStamp(){
    return new DateTime.now().millisecondsSinceEpoch | 0;
  }

  open() async {
    String dir = (await getApplicationDocumentsDirectory()).path;

    ////print(dir + "assets/data.db");

    Database database = await openDatabase(dir + "assets/data.db", version: 1,
      onCreate: (Database db, int version) async {
        //print('successfully created');
        // When creating the db (for the very first time), create the table
        await createTables();
      }
    );

    this.database = database;
  }

  deleteTables() async {
    await database.execute(
      "DROP TABLE workouts");
    await database.execute(
      "DROP TABLE exercises");
  }

  createTables() async {
    await database.execute(
      "CREATE TABLE workouts (id INTEGER PRIMARY KEY, type TEXT, date TEXT, exercises TEXT)");
    await database.execute(
      "CREATE TABLE exercises (id INTEGER PRIMARY KEY, type TEXT, date TEXT, sets TEXT)");
  }

  addSampleData() async {
    int exerciseid = await addMetaExercise(new MetaExercise(type: "squat", date: "2017-11-17", sets: ""));

    ////print("sample exercise id: $exerciseid");

    int workoutid = await addMetaWorkout(new MetaWorkout(type: "pull", date: "2017-11-17", exercises: exerciseid.toString()));

    ////print("sample workout id: $workoutid");
  }

  resetData() async {
    await deleteTables();
    await createTables();
    await addSampleData();
  }

  close() async {
    await database.close();
  }

  String listToString(List l){
    String result = "";

    for(int i = 0; i < l.length; i++){
      result += l[i].toString();
      if(i < l.length - 1){
        result += ",";
      }
    }

    return(result);
  }

  List<String> stringToList(String s){
    return s.split(",");
  }

  List<int> stringToIntList(String s){
    List<String> stringList = stringToList(s);
    List<int> intList = [];

    for(int i = 0; i < stringList.length; i++){
      intList.add(int.parse(stringList[i]));
    }

    return intList;
  }

  //MetaWorkout operations
  addMetaWorkout(MetaWorkout mw) async {
    int timestamp = timeStamp();

    ////print("workout timestamp: $timestamp");

    MetaWorkout newmetaworkout = new MetaWorkout(id: timestamp, type: mw.type, date: mw.date, exercises: mw.exercises);

    ////print("inserting new meta workout: $newmetaworkout");

    await database.insert("workouts", newmetaworkout.toMap());

    return timestamp;
  }

  getMetaWorkoutByID(int id) async {
    List<Map> maps = await database.query("workouts",
        columns: ["id", "type", "date", "exercises"],
        where: "id = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return new MetaWorkout.fromMap(maps.first);
    }
  }

  //get List<MetaWorkout> with unpopulated exercises (left as int IDs)
  getMetaWorkoutsByDate(String date) async {
    List<Map> maps = await database.query("workouts",
        columns: ["id", "type", "date", "exercises"],
        where: "date = ?",
        whereArgs: [date]);

    List<MetaWorkout> result = [];
    for(int i = 0; i < maps.length; i++){
      result.add(new MetaWorkout.fromMap(maps[i]));
    }

    return result;
  }

  //get List<Workout> with exercises as Exercise objects
  getWorkoutsByDate(String date) async {
    ////print("getWorkoutsByDate($date)");

    List<Map> maps = await database.query("workouts",
        columns: ["id", "type", "date", "exercises"],
        where: "date = ?",
        whereArgs: [date]);

    List<Workout> result = [];
    Workout currWorkout;
    List<int> exerciseIDs;

    MetaExercise currMetaExercise;
    List<Exercise> currExercises = [];

    for(int i = 0; i < maps.length; i++){

      exerciseIDs = stringToIntList(maps[i]['exercises']);

      //print("exerciseIDs: $exerciseIDs");

      for(int j = 0; j < exerciseIDs.length; j++){
        currMetaExercise = await getMetaExerciseByID(exerciseIDs[j]);

        //print("currMetaExercise: $currMetaExercise");

        currExercises.add(new Exercise(
          name: "temp exercise name",
          id: currMetaExercise.id,
          type: currMetaExercise.type,
          date: currMetaExercise.date,
          sets: [] //populate in a sec
        ));
      }

      currWorkout = new Workout(
        id: maps[i]['id'],
        name: "temp name",
        type: maps[i]['type'],
        date: maps[i]['date'],
        exercises: currExercises,
      );
      result.add(currWorkout);
    }

    return result;
  }

  getAllMetaWorkouts() async {
    List<Map> maps = await database.query("workouts");

    List<MetaWorkout> result = [];
    for(int i = 0; i < maps.length; i++){
      result.add(new MetaWorkout.fromMap(maps[i]));
    }

    return result;
  }

  //Exercise operations
  addMetaExercise(MetaExercise e) async {
    int timestamp = timeStamp();
    ////print("exercise timestamp: $timestamp");

    MetaExercise newmetaexercise = new MetaExercise(id: timestamp, type: e.type, date: e.date, sets: e.sets);

    ////print("inserting new meta workout: $newmetaexercise");

    await database.insert("exercises", newmetaexercise.toMap());

    return timestamp;
  }

  getMetaExerciseByID(int id) async {
    List<Map> maps = await database.query("exercises",
        columns: ["id", "type", "date", "sets"],
        where: "id = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return new MetaExercise.fromMap(maps.first);
    }
  }

  getMetaExercisesByDate(String date) async {
    List<Map> maps = await database.query("exercises",
        columns: ["id", "type", "date", "sets"],
        where: "date = ?",
        whereArgs: [date]);

    List<MetaExercise> result = [];
    for(int i = 0; i < maps.length; i++){
      result.add(new MetaExercise.fromMap(maps[i]));
    }

    return result;
  }

  getAllMetaExercises() async {
    List<Map> maps = await database.query("workouts");

    List<MetaExercise> result = [];
    for(int i = 0; i < maps.length; i++){
      result.add(new MetaExercise.fromMap(maps[i]));
    }

    return result;
  }
}

//for interacting with server
class ApiInterface {

  String apiLocation;
  var client = createHttpClient();

  ApiInterface({this.apiLocation});

  String newObjectID(){
    String increment = new Random().nextInt(16777216).floor().toRadixString(16);
    String pid = new Random().nextInt(65536).floor().toRadixString(16);
    String machine = new Random().nextInt(16777216).floor().toRadixString(16);
    String timestamp = (new DateTime.now().millisecondsSinceEpoch ~/ 1000 | 0).toRadixString(16);

    return timestamp + machine + pid + increment;
  }

  int newObjectIDint(){
    int result = int.parse(newObjectID(), radix: 16);
    ////print('newObjectIDint: '+result.toString());
    return result;
  }

  int timeStamp(){
    return new DateTime.now().millisecondsSinceEpoch ~/ 1000 | 0;
  }

  getMetaWorkouts() async {

    ////print(newObjectID());

    List<Workout> metaWorkouts = [];

    String url = apiLocation + '/workouts/meta/';
    var response = await client.read(url);
    List data = JSON.decode(response); //list of objects to be converted

    //convert response objects into MetaWorkouts
    for(int i = 0; i < data.length; i++){
      metaWorkouts.add(new Workout.fromMap(data[i]));
    }

    return metaWorkouts;
  }

  getWorkout(date) async {
    String url = apiLocation + '/workouts/date/'+date;
    var response = await client.read(url);
    Map data = JSON.decode(response);

    return new Workout.fromMap(data);
  }

}
