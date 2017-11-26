import 'package:flutter/material.dart';

String monthFromInt(int month){
  switch(month){
    case 1: return "Jan";
    case 2: return "Feb";
    case 3: return "Mar";
    case 4: return "Apr";
    case 5: return "May";
    case 6: return "Jun";
    case 7: return "Jul";
    case 8: return "Aug";
    case 9: return "Sep";
    case 10: return "Oct";
    case 11: return "Nov";
    case 12: return "Dec";
  }

  return "Nan";
}

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
  String type;
  List<Set> sets;

  Exercise({this.name, this.date, this.type, this.sets, this.isExpanded});

  Exercise.defaultValues() {
    this.isExpanded = false;
    this.name = "exercise name";
    this.date = "exercise date";
    this.type = "exercise type";
    this.sets = [];
  }

  Exercise.fromResponse(Map r) {
    this.isExpanded = false;
    this.name = r['name'] ?? "exercise name";
    this.date = r['date'] ?? "exercise date";
    this.type = r['type'] ?? "exercise type";

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
            this.name,
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
  bool isExpanded;
  String type;
  String date;
  String name;
  List<String> exercises;

  MetaWorkout({this.name, this.date, this.type, this.exercises});

  MetaWorkout.defaultValues() {
    this.name = "workout name";
    this.date = "workout date";
    this.type = "workout type";
    this.exercises = [];
    this.isExpanded = false;
  }

  MetaWorkout.fromResponse(Map r) {
    this.name = r['name'] ?? "workout name";
    this.date = r['date'] ?? "workout date";
    this.type = r['type'] ?? "workout type";
    this.exercises = r['exercises'] ?? [];
    this.isExpanded = false;
  }

  createDataRow({Function onTap}){
    return new DataRow(
      cells: <DataCell>[
        new DataCell(
          new Text(this.name),
          onTap: onTap
        ),
        new DataCell(
          new Text(this.type),
          onTap: onTap
        ),
        new DataCell(
          new Text(this.date),
          onTap: onTap
        ),
        new DataCell(
          new Text(this.exercises.length.toString()),
          onTap: onTap
        )
      ]
    );
  }

  createListTile({Function onTap}){
    DateTime date = DateTime.parse(this.date);
    return new Container(
      /* disables InkWell, see: https://github.com/flutter/flutter/issues/3782
      decoration: new BoxDecoration(
        color: Colors.white,
      ),
      */
      child: new ListTile(
        leading: new CircleAvatar(
          radius: 20.0,
          backgroundColor: Colors.teal.shade500,
          child: new Container(
            margin: const EdgeInsets.only(top: 5.0),
            child: new Column(
              children: [
                new Text(
                  date.day.toString(),
                  style: new TextStyle(
                    fontSize: 18.0,
                  )
                ),
                new Text(
                  monthFromInt(date.month),
                  style: new TextStyle(
                    fontSize: 8.0
                  )
                ),
              ]
            )
          )
        ),
        title: new Text(this.name),
        onTap: onTap,
      )
    );
  }

  createExpansionPanel({Function onTap}) {
    return new ExpansionPanel(
      headerBuilder: (BuildContext context, bool isExpanded) {
        return new ListTile(
          title: new Text(
            this.name,
            textAlign: TextAlign.left,
            style: new TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          onTap: onTap ?? (){}
        );
      },
      body: new Column(
        children: <Widget>[
          new Text("Date: "+this.date),
          new Text("Number of exercises: "+this.exercises.length.toString())
        ]
      ),
      isExpanded: this.isExpanded
    );
  }

  createExpansionTile({Function onTap}) {
    return new ExpansionTile(
      title: new Text(
        this.name,
        textAlign: TextAlign.left,
        style: new TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w400,
        ),
      ),
      children: <Widget>[
        new Text("Date: "+this.date),
        new Text("Number of exercises: "+this.exercises.length.toString())
      ]
    );
  }
}

class Workout {
  String name;
  String date;
  String type;
  List<Exercise> exercises;

  Workout({this.name, this.date, this.type, this.exercises});

  Workout.defaultValues() {
    this.name = "workout name";
    this.date = "workout date";
    this.type = "workout type";
    this.exercises = [];
  }

  Workout.fromResponse(Map r) {
    this.name = r['name'] ?? "workout name";
    this.date = r['date'] ?? "workout date";
    this.type = r['type'] ?? "workout type";

    List<Exercise> exercises = [];
    for(num i = 0; i < r['exercises'].length; i++){
      exercises.add(new Exercise.fromResponse(r['exercises'][i]));
    }
    this.exercises = exercises;
  }
}
