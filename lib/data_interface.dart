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

//helper functions
int timeStamp(){
  return new DateTime.now().millisecondsSinceEpoch | 0;
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

//for when exercises aren't populated
//raw representation of what's in database
class DatabaseWorkout {
  int id; //id for storage in local sql database
  String type;
  String date;
  String name; //soon to be removed in favor of type->name lookup table
  String exercises; //textual representation of an array of int ids of exercises

  DatabaseWorkout({this.id, this.name, this.date, this.type, this.exercises});

  DatabaseWorkout.defaultValues() {
    this.id = 0;
    this.name = "workout name";
    this.date = "workout date";
    this.type = "workout type";
    this.exercises = "";
  }

  String toString() {
    return """
     id: $id
     name: $name
     date: $date
     type: $type
     exercises: $exercises
    """;
  }

  Map toMap() {
    Map map = new Map();
    map['id'] = id;
    map['type'] = type;
    map['date'] = date;
    map['exercises'] = exercises;
    return map;
  }

  DatabaseWorkout.fromMap(Map r) {
    this.id = r['id'] ?? 0; //change to timestamp
    this.name = r['name'] ?? "workout name";
    this.date = r['date'] ?? "workout date";
    this.type = r['type'] ?? "workout type";
    this.exercises = r['exercises'] ?? "";
  }
}

class WorkoutMeta {
  String type;
  String name;

  WorkoutMeta({this.type, this.name});

  WorkoutMeta.fromMap(Map r) {
    this.type = r['type'] ?? "workout meta type";
    this.name = r['name'] ?? "workout meta name";
  }

  Map toMap() {
    Map map = new Map();
    map['type'] = type;
    map['name'] = name;

    return map;
  }

  String toString() {
    return """
      type: $type
      name: $name
    """;
  }
}

//representation of what's in database
class DatabaseExercise {
  int id; //id for storage in local sql database
  String date;
  String type;
  String sets; //textual representation of an array of int ids of sets

  DatabaseExercise({this.id, this.date, this.type, this.sets});

  DatabaseExercise.defaultValues() {
    this.id = 0;
    this.date = "exercise date";
    this.type = "exercise type";
    this.sets = "";
  }

  String toString() {
    return """
      id: $id
      date: $date
      type: $type
      sets: $sets
    """;
  }

  Map toMap() {
    Map map = new Map();
    map['id'] = id;
    map['date'] = date;
    map['type'] = type;
    map['sets'] = sets;
    return map;
  }

  DatabaseExercise.fromMap(Map r) {
    this.id = r['id'] ?? 0;
    this.date = r['date'] ?? "exercise date";
    this.type = r['type'] ?? "exercise type";
    this.sets = r['sets'] ?? "";
  }
}

class ExerciseMeta {
  String type;
  String name;

  ExerciseMeta({this.type, this.name});

  ExerciseMeta.fromMap(Map r) {
    this.type = r['type'] ?? "exercise meta type";
    this.name = r['name'] ?? "exercise meta name";
  }

  Map toMap() {
    Map map = new Map();
    map['type'] = type;
    map['name'] = name;

    return map;
  }

  String toString() {
    return """
      type: $type
      name: $name
    """;
  }
}

class DatabaseSet {
  int id;
  int reps = 0;
  num weight = 0.0;

  DatabaseSet({this.id, this.reps, this.weight});

  DatabaseSet.defaultValues() {
    this.id = 0;
    this.reps = 0;
    this.weight = 0.0;
  }

  String toString() {
    return """
      id: $id
      reps: $reps
      weight: $weight
    """;
  }

  Map toMap() {
    Map map = new Map();
    map['id'] = id;
    map['reps'] = reps;
    map['weight'] = weight;
    return map;
  }

  DatabaseSet.fromMap(Map r) {
    this.id = r['id'] ?? 0;
    this.reps = r['reps'] ?? 0;
    this.weight = r['weight'] ?? 0.0;
  }
}

class DatabaseInterface {

  Database database;

  //methods client has access to

  open() async {
    String dir = (await getApplicationDocumentsDirectory()).path;

    ////print(dir + "assets/data.db");

    Database database = await openDatabase(dir + "assets/data.db", version: 1,
      onCreate: (Database db, int version) async {
        //print('successfully created');
        // When creating the db (for the very first time), create the table
        await _createTables();
      }
    );

    this.database = database;
  }

  close() async {
    await database.close();
  }

  resetData() async {
    await _deleteTables();
    await _createTables();
    await _addSampleData();
  }

  testThings() async {
    List<Map> maps = await database.query("exercisemeta");
    for(int i = 0; i < maps.length; i++){
      print(new WorkoutMeta.fromMap(maps[i]));
    }
  }

  //get List<Workout> with populated exercises
  getWorkoutsByDate(String date) async {
    ////print("getWorkoutsByDate($date)");

    List<DatabaseWorkout> databaseWorkouts = await _getDatabaseWorkoutsByDate(date);
    List<Workout> workouts = [];
    Workout currWorkout;

    for(int i = 0; i < databaseWorkouts.length; i++){
      currWorkout = await _generateWorkoutPopulated(databaseWorkouts[i]);
      workouts.add(currWorkout);
    }

    return workouts;
  }

  //TODO: split populated/unpopulated into two classes

  //returns List<Workout> with unpopulated exercises (empty exercise field)
  getAllWorkoutsUnpopulated() async {
    List<DatabaseWorkout> databaseWorkouts = await _getAllDatabaseWorkouts();
    List<Workout> workouts = [];
    Workout currWorkout;

    for(int i = 0; i < databaseWorkouts.length; i++){
      currWorkout = await _generateWorkoutUnpopulated(databaseWorkouts[i]);
      workouts.add(currWorkout);
    }

    return workouts;
  }

  //returns List<Workout> with populated exercises (all the way down to sets)
  getAllWorkoutsPopulated() async {
    List<DatabaseWorkout> databaseWorkouts = await _getAllDatabaseWorkouts();
    List<Workout> workouts = [];
    Workout currWorkout;

    for(int i = 0; i < databaseWorkouts.length; i++){
      currWorkout = await _generateWorkoutPopulated(databaseWorkouts[i]);
      workouts.add(currWorkout);
    }

    return workouts;
  }

  //private methods for interacting directly with database

  _deleteTables() async {
    await database.execute(
      "DROP TABLE workouts");
    await database.execute(
      "DROP TABLE exercises");
    await database.execute(
      "DROP TABLE sets");

    await database.execute(
      "DROP TABLE workoutmeta");
    await database.execute(
      "DROP TABLE exercisemeta");
  }

  _createTables() async {
    await database.execute(
      "CREATE TABLE workouts (id INTEGER PRIMARY KEY, type TEXT, date TEXT, exercises TEXT)");
    await database.execute(
      "CREATE TABLE exercises (id INTEGER PRIMARY KEY, type TEXT, date TEXT, sets TEXT)");
    await database.execute(
      "CREATE TABLE sets (id INTEGER PRIMARY KEY, reps INTEGER, weight REAL)");

    await database.execute(
      "CREATE TABLE workoutmeta (type STRING PRIMARY KEY, name STRING)");
    await database.execute(
      "CREATE TABLE exercisemeta (type STRING PRIMARY KEY, name STRING)");
  }

  _addSampleData() async {

    await _addWorkoutMeta(new WorkoutMeta(type: "pull", name: "Pull day"));

    await _addExerciseMeta(new ExerciseMeta(type: "squat", name: "Squat"));
    await _addExerciseMeta(new ExerciseMeta(type: "lat_pulldowns", name: "Lat pulldowns"));

    List<int> exerciseIDs = [];
    int exerciseID;

    List<int> setIDs = [];
    int setID;

    for(int i = 0; i < 3; i++){
      setIDs = [];

      for(int j = 0; j < 4; j++){
        setID = await _addDatabaseSet(new DatabaseSet(reps: 10, weight: 130));
        setIDs.add(setID);
      }

      exerciseID = await _addDatabaseExercise(new DatabaseExercise(type: "squat", date: "2017-11-17", sets: listToString(setIDs)));
      exerciseIDs.add(exerciseID);
    }

    //print("sample exerciseid: $exerciseID");

    int workoutID = await _addDatabaseWorkout(new DatabaseWorkout(type: "pull", date: "2017-11-17", exercises: listToString(exerciseIDs)));

    print("sample workout id: $workoutID");
  }


  _addWorkoutMeta(WorkoutMeta wm) async {
    await database.insert("workoutmeta", wm.toMap());
  }

  _getWorkoutMeta(String type) async {
    print("_getWorkoutMeta($type)");

    WorkoutMeta result = new WorkoutMeta();

    List<Map> maps = await database.query("workoutmeta",
        columns: ["type", "name"],
        where: "type = ?",
        whereArgs: [type]);
    if (maps.length > 0) {
      result = new WorkoutMeta.fromMap(maps.first);
    }

    print("returning workoutMeta: $result");

    return result;
  }

  //DatabaseWorkout -> populated Workout
  _generateWorkoutPopulated(DatabaseWorkout dw) async {
    Workout workout; //this is what we'll be returning

    List<int> exerciseIDs = stringToIntList(dw.exercises);
    List<Exercise> exercises = [];
    DatabaseExercise currDatabaseExercise;
    Exercise currExercise;

    //populate exercises
    for(int j = 0; j < exerciseIDs.length; j++){
      currDatabaseExercise = await _getDatabaseExerciseByID(exerciseIDs[j]);
      currExercise = await _generateExercise(currDatabaseExercise);
      exercises.add(currExercise);
    }

    //at this point, exercises is a List<Exercise>

    WorkoutMeta wm = await _getWorkoutMeta(dw.type);

    workout = new Workout(
      id: dw.id,
      name: wm.name,
      type: dw.type,
      date: dw.date,
      exercises: exercises,
    );

    return workout;
  }

  //DatabaseWorkout -> unpopulated Workout
  _generateWorkoutUnpopulated(DatabaseWorkout dw) async {
    WorkoutMeta wm = await _getWorkoutMeta(dw.type);

    return new Workout(id: dw.id, name: wm.name, type: dw.type, date: dw.date, exercises: []);
  }

  //DatabaseWorkout operations
  _addDatabaseWorkout(DatabaseWorkout mw) async {
    int timestamp = timeStamp();

    ////print("workout timestamp: $timestamp");

    DatabaseWorkout newDatabaseWorkout = new DatabaseWorkout(id: timestamp, type: mw.type, date: mw.date, exercises: mw.exercises);

    print("inserting new database workout: $newDatabaseWorkout");

    await database.insert("workouts", newDatabaseWorkout.toMap());

    return timestamp;
  }

  _getDatabaseWorkoutByID(int id) async {
    DatabaseWorkout result = new DatabaseWorkout();

    List<Map> maps = await database.query("workouts",
        columns: ["id", "type", "date", "exercises"],
        where: "id = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      result = new DatabaseWorkout.fromMap(maps.first);
    }

    return result;
  }

  //get List<DatabaseWorkout> with unpopulated exercises (left as int IDs)
  _getDatabaseWorkoutsByDate(String date) async {
    List<Map> maps = await database.query("workouts",
        columns: ["id", "type", "date", "exercises"],
        where: "date = ?",
        whereArgs: [date]);

    List<DatabaseWorkout> result = [];
    for(int i = 0; i < maps.length; i++){
      result.add(new DatabaseWorkout.fromMap(maps[i]));
    }

    return result;
  }

  _getAllDatabaseWorkouts() async {
    List<Map> maps = await database.query("workouts");

    List<DatabaseWorkout> result = [];
    for(int i = 0; i < maps.length; i++){
      result.add(new DatabaseWorkout.fromMap(maps[i]));
    }

    return result;
  }

  //Exercise operations

  _addExerciseMeta(ExerciseMeta em) async {
    await database.insert("exercisemeta", em.toMap());
  }

  _getExerciseMeta(String type) async {
    print("_getExerciseMeta($type)");

    ExerciseMeta result = new ExerciseMeta();

    List<Map> maps = await database.query("exercisemeta",
        columns: ["type", "name"],
        where: "type = ?",
        whereArgs: [type]);
    if (maps.length > 0) {
      print("maps not empty");
      result = new ExerciseMeta.fromMap(maps.first);
    }

    print("returning exerciseMeta: $result");


    return result;
  }

  //DatabaseExercise -> populated Exercise
  _generateExercise(DatabaseExercise de) async {
    Exercise exercise; //this is what we'll be returning

    List<int> setIDs = stringToIntList(de.sets);
    List<Set> sets = [];
    DatabaseSet currDatabaseSet;

    //populate current exercise's sets
    for(int k = 0; k < setIDs.length; k++){
      currDatabaseSet = await _getDatabaseSetByID(setIDs[k]);
      sets.add(new Set(
        reps: currDatabaseSet.reps,
        weight: currDatabaseSet.weight
      ));
    }

    ExerciseMeta em = await _getExerciseMeta(de.type);

    //add the now-populated exercise
    exercise = new Exercise(
      name: em.name,
      id: de.id,
      type: de.type,
      date: de.date,
      sets: sets
    );

    return exercise;
  }

  _addDatabaseExercise(DatabaseExercise e) async {
    int timestamp = timeStamp();
    ////print("exercise timestamp: $timestamp");

    DatabaseExercise newDatabaseExercise = new DatabaseExercise(id: timestamp, type: e.type, date: e.date, sets: e.sets);

    print("inserting new database exercise: $newDatabaseExercise");

    await database.insert("exercises", newDatabaseExercise.toMap());

    return timestamp;
  }

  _getDatabaseExerciseByID(int id) async {
    DatabaseExercise result = new DatabaseExercise();

    List<Map> maps = await database.query("exercises",
        columns: ["id", "type", "date", "sets"],
        where: "id = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      result = new DatabaseExercise.fromMap(maps.first);
    }

    return result;
  }

  _getDatabaseExercisesByDate(String date) async {
    List<Map> maps = await database.query("exercises",
        columns: ["id", "type", "date", "sets"],
        where: "date = ?",
        whereArgs: [date]);

    List<DatabaseExercise> result = [];
    for(int i = 0; i < maps.length; i++){
      result.add(new DatabaseExercise.fromMap(maps[i]));
    }

    return result;
  }

  _getAllDatabaseExercises() async {
    List<Map> maps = await database.query("workouts");

    List<DatabaseExercise> result = [];
    for(int i = 0; i < maps.length; i++){
      result.add(new DatabaseExercise.fromMap(maps[i]));
    }

    return result;
  }

  //Set operations
  _addDatabaseSet(DatabaseSet s) async {
    int timestamp = timeStamp();
    ////print("exercise timestamp: $timestamp");

    DatabaseSet newDatabaseSet = new DatabaseSet(id: timestamp, reps: s.reps, weight: s.weight);

    ////print("inserting new meta workout: $newDatabaseExercise");

    await database.insert("sets", newDatabaseSet.toMap());

    return timestamp;
  }

  _getDatabaseSetByID(int id) async {
    List<Map> maps = await database.query("sets",
        columns: ["id", "reps", "weight"],
        where: "id = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return new DatabaseSet.fromMap(maps.first);
    }
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

  _getDatabaseWorkouts() async {

    ////print(newObjectID());

    List<Workout> DatabaseWorkouts = [];

    String url = apiLocation + '/workouts/meta/';
    var response = await client.read(url);
    List data = JSON.decode(response); //list of objects to be converted

    //convert response objects into DatabaseWorkouts
    for(int i = 0; i < data.length; i++){
      DatabaseWorkouts.add(new Workout.fromMap(data[i]));
    }

    return DatabaseWorkouts;
  }

  getWorkout(date) async {
    String url = apiLocation + '/workouts/date/'+date;
    var response = await client.read(url);
    Map data = JSON.decode(response);

    return new Workout.fromMap(data);
  }

}
