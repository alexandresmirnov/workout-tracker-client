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
  int reps = 0;
  num weight = 0.0;

  Set({this.reps, this.weight});

  Set.fromResponse(Map s){
    this.reps = s['reps'];
    this.weight = s['weight'];
  }

  createDataRow(){
    return new DataRow(
      cells: <DataCell>[
        new DataCell(
          new Text(this.reps.toString())
        ),
        new DataCell(
          new Text(this.weight.toString())
        )
      ],
      onSelectChanged: (bool value) {
        print(value);
      }
    );
  }

  createListTile({Function onTap}){
    return new Container(
      child: new ListTile(
        leading: new Center(
          child: new Text(reps.toString())
        ),
        title: new Text(weight.toString()),
        onTap: onTap,
      )
    );
  }
}

//used for actual display
class Exercise {
  int id; //id for storage in local sql database
  String name;
  String date;
  String type;
  List<Set> sets;

  Exercise({this.id, this.name, this.date, this.type, this.sets});

  Exercise.defaultValues() {
    this.id = 0;
    this.name = "exercise name";
    this.date = "exercise date";
    this.type = "exercise type";
    this.sets = [];
  }

  String toString() {
    return """
      id: $id
      name: $name
      date: $date
      type: $type
    """;
  }

  Map toMap() {
    Map map = new Map();
    map['id'] = id;
    map['type'] = type;
    map['date'] = date;
    map['sets'] = sets;
    return map;
  }

  Exercise.fromMap(Map r) {
    this.name = r['name'] ?? "exercise name";
    this.date = r['date'] ?? "exercise date";
    this.type = r['type'] ?? "exercise type";

    List<Set> sets = [];
    for(int j = 0; j < r['sets'].length; j++){
      sets.add(new Set.fromResponse(r['sets'][j]));
    }
    this.sets = sets;
  }

  ExpansionPanel toExpansionPanel({isExpanded}) {
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
        }).toList(),
      ),
      isExpanded: isExpanded
    );
  }

  ExpansionTile toExpansionTile() {
    return new ExpansionTile(
      leading: new CircleAvatar(
        radius: 20.0,
        backgroundColor: Colors.teal.shade500,
        child: new Container(
          margin: const EdgeInsets.only(top: 5.0),
          child: new Column(
            children: [
              new Text(
                sets.length.toString(),
                style: new TextStyle(
                  fontSize: 18.0,
                )
              ),
              new Text(
                "sets",
                style: new TextStyle(
                  fontSize: 8.0
                )
              ),
            ]
          )
        )
      ),
      title: new Text(
        this.name,
        textAlign: TextAlign.left,
        style: new TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: new IconButton(
        icon: new Icon(Icons.edit),
        tooltip: 'Edit',
        onPressed: () {},
      ),
      children: this.sets.map((Set s) {
        return s.createListTile();
      }).toList(),
    );
  }

  Card toCard() {
    return new Card(
      child: toExpansionTile()
    );
  }

}

//object used when actually displaying a workout
class Workout {
  int id;
  String name;
  String date;
  String type;
  List<Exercise> exercises;

  Workout({this.id, this.name, this.date, this.type, this.exercises});

  Workout.defaultValues() {
    this.id = 0;
    this.name = "workout name";
    this.date = "workout date";
    this.type = "workout type";
    this.exercises = [];
  }

  Workout.fromMap(Map r) {
    this.id = r['name'] ?? 0;
    this.name = r['name'] ?? "workout name";
    this.date = r['date'] ?? "workout date";
    this.type = r['type'] ?? "workout type";

    List<Exercise> exercises = [];
    for(int i = 0; i < r['exercises'].length; i++){
      exercises.add(new Exercise.fromMap(r['exercises'][i]));
    }
    this.exercises = exercises;
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
        subtitle: new Text(this.type + ", id:" + this.id.toString()),
        onTap: onTap,
      )
    );
  }
}
