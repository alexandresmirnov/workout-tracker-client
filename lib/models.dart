import 'package:flutter/material.dart';

class Set {
  num reps = 0;
  num weight = 0;

  Set({this.reps, this.weight});

  Set.fromResponse(Map s){
    this.reps = s['reps'];
    this.weight = s['weight'];
  }

  createDataRow(){
    return new DataRow(
      cells: <DataCell>[
        new DataCell(
          new Text("1")
        ),
        new DataCell(
          new Text(this.reps.toString())
        ),
        new DataCell(
          new Text(this.weight.toString())
        )
      ]
    );
  }
}

class Exercise {
  bool isExpanded;
  String name;
  String date;
  String title;
  List<Set> sets;

  Exercise({this.name, this.date, this.title, this.sets, this.isExpanded});

  Exercise.defaultValues() {
    this.isExpanded = false;
    this.name = "exercise name";
    this.date = "exercise date";
    this.title = "exercise title";
    this.sets = [];
  }

  Exercise.fromResponse(Map r) {
    this.isExpanded = false;
    this.name = r['name'] ?? "exercise name";
    this.date = r['date'] ?? "exercise date";
    this.title = r['title'] ?? "exercise title";

    List<Set> sets = [];
    for(num j = 0; j < r['sets'].length; j++){
      sets.add(new Set.fromResponse(r['sets'][j]));
    }
    this.sets = sets;
  }

  createExpansionPanel() {
    return new ExpansionPanel(
      headerBuilder: (BuildContext context, bool isExpanded) {
        return new ListTile(
          title: new Text(
            this.title,
            textAlign: TextAlign.left,
            style: new TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w400,
            ),
          )
        );
      },
      body: new DataTable(
        columns: <DataColumn>[
          new DataColumn(
            label: new Text("sets"),
            numeric: true
          ),
          new DataColumn(
            label: new Text("reps"),
            numeric: true
          ),
          new DataColumn(
            label: new Text("weight"),
            numeric: true
          )
        ],
        rows: this.sets.map((Set s) {
          return s.createDataRow();
        }).toList()
      ),
      isExpanded: this.isExpanded
    );
  }

}

//for when exercises aren't populated
class MetaWorkout {
  String name;
  String date;
  String title;
  List<String> exercises;

  MetaWorkout({this.name, this.date, this.title, this.exercises});

  MetaWorkout.defaultValues() {
    this.name = "workout name";
    this.date = "workout date";
    this.title = "workout title";
    this.exercises = [];
  }

  MetaWorkout.fromResponse(Map r) {
    this.name = r['name'] ?? "workout name";
    this.date = r['date'] ?? "workout date";
    this.title = r['title'] ?? "workout title";
    this.exercises = r['exercises'] ?? [];
  }
}

class Workout {
  String name;
  String date;
  String title;
  List<Exercise> exercises;

  Workout({this.name, this.date, this.title, this.exercises});

  Workout.defaultValues() {
    this.name = "workout name";
    this.date = "workout date";
    this.title = "workout title";
    this.exercises = [];
  }

  Workout.fromResponse(Map r) {
    this.name = r['name'] ?? "workout name";
    this.date = r['date'] ?? "workout date";
    this.title = r['title'] ?? "workout title";

    List<Exercise> exercises = [];
    for(num i = 0; i < r['exercises'].length; i++){
      exercises.add(new Exercise.fromResponse(r['exercises'][i]));
    }
    this.exercises = exercises;
  }
}
