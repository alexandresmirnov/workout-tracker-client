import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

void main() {
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
    // If the path is "/workout/date/..." then show a workout page for the
    // specified workout date.
    if (path[1] == 'workout' && path[2] == 'date') {
      // We need a date, otherwise return
      if (path[3] == null)
        return null;
      // Extract the date of "workout/date/..." and return a route
      // for that symbol.
      final String date = path[3];
      return new MaterialPageRoute<Null>(
        settings: settings,
        builder: (BuildContext context) => new WorkoutView(date: date),
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
         '/': (BuildContext context) => new MainView(),
      },
      onGenerateRoute: _getRoute,
    );
  }
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


class WorkoutView extends StatefulWidget {
  WorkoutView({Key key, this.date}) : super(key: key);

  final String date;

  @override
  _WorkoutViewState createState() => new _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView>{

  Workout _displayWorkout = new Workout.defaultValues();

  _getWorkout(date) async {
    String url = 'http://192.168.1.2:8080/api/workouts/date/'+date;
    var httpClient = createHttpClient();
    var response = await httpClient.read(url);
    Map data = JSON.decode(response);

    if (!mounted) return;

    setState(() {
      _displayWorkout = new Workout.fromResponse(data);
    });

  }

  @override
  initState() {
    super.initState();

    _getWorkout(widget.date);
  }

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(_displayWorkout.title + " (" + _displayWorkout.date + ")"),
      ),
      body: new Container(
        padding: const EdgeInsets.all(16.0),
        child: new Column(
          children: <Widget>[
            new ExpansionPanelList(
              children: _displayWorkout.exercises.map((Exercise e) {
                return e.createExpansionPanel();
              }).toList(),
              expansionCallback: (int panelIndex, bool isExpanded) {
                setState(() {
                  _displayWorkout.exercises[panelIndex].isExpanded = !isExpanded;
                });
              }
            )
          ]
        )
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/workout/date/2017-11-10');
          //_getWorkout('2017-11-10');
        },
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ),
    );
  }
}

class MainView extends StatefulWidget {
  MainView({Key key}) : super(key: key);


  @override
  _MainViewState createState() => new _MainViewState();
}

class _MainViewState extends State<MainView> {

  @override
  Widget build(BuildContext context) {
    return new WorkoutView(date: '2017-11-11');
  }
}
