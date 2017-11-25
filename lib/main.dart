import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

void main() {
  runApp(new WorkoutTrackerClient());
}

class WorkoutTrackerClient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Workout Tracker',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MainView(title: 'Workout Tracker'),
    );
  }
}

class Set {
  Set({this.reps, this.weight});

  num reps;
  num weight;
}

class SetView extends StatelessWidget {
  SetView({this.set});

  final Set set;

  @override
  build(BuildContext context){
    return new Column(
      children: <Widget>[
        new Text(set.reps.toString()),
        new Text(set.weight.toString()),
      ]
    );
  }
}

class Exercise {
  Exercise({this.name, this.date, this.title, this.sets, this.isExpanded});

  bool isExpanded;

  String name;
  String date;
  String title;
  List sets;
}

class ExercisePanel {
  bool isExpanded;
  final String header;
  final Widget body;
  final Icon iconpic;
  ExercisePanel(this.isExpanded, this.header, this.body, this.iconpic);
}

class ExerciseView extends StatelessWidget {
  ExerciseView({this.exercise});

  final Exercise exercise;

  @override
  build(BuildContext context){
    //TODO: clean this up
    Exercise displayExercise = new Exercise();
    if(exercise != null){
      displayExercise.name = exercise.name ?? "name";
      displayExercise.date = exercise.date ?? "date";
      displayExercise.title = exercise.title ?? "title";
      displayExercise.sets = exercise.sets ?? [];
    }
    else {
      displayExercise.name = "name";
      displayExercise.date = "date";
      displayExercise.title = "title";
      displayExercise.sets = [];
    }

    List<SetView> setViews = [];
    for(num i = 0; i < displayExercise.sets.length; i++){
      setViews.add(new SetView(set: displayExercise.sets[i]));
    }

    return new Column(
      children: <Widget>[
        new Text('name: '+displayExercise.name),
        new Text('date: '+displayExercise.date),
        new Text('title: '+displayExercise.title),
        new Column(
          children: setViews
        )
      ]
    );
  }
}

class Workout {
  Workout({this.name, this.date, this.title, this.exercises});

  String name;
  String date;
  String title;
  List<Exercise> exercises;
}


class WorkoutView extends StatefulWidget {
  WorkoutView({Key key, this.workout}) : super(key: key);

  final Workout workout;

  @override
  _WorkoutViewState createState() => new _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView>{

  Workout displayWorkout;

  @override
  Widget build(BuildContext context){
    if(widget.workout == null){
      displayWorkout = new Workout(name: "name", date: "date", title: "title", exercises: []);
    }
    else {
      displayWorkout = widget.workout;
    }

    List<ExerciseView> exerciseViews = [];
    for(num i = 0; i < displayWorkout.exercises.length; i++){
      exerciseViews.add(new ExerciseView(exercise: displayWorkout.exercises[i]));
    }

    return new Column(
      children: <Widget>[
        new Text('name: '+displayWorkout.name),
        new Text('date: '+displayWorkout.date),
        new Text('title: '+displayWorkout.title),
        new Column(
          children: exerciseViews
        ),
        new ExpansionPanelList(
          children: displayWorkout.exercises.map((Exercise e) {
            return new ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return new ListTile(
                  title: new Text(
                    e.title,
                    textAlign: TextAlign.left,
                    style: new TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                );
              },
              body: new Text('body'),
              isExpanded: e.isExpanded

            );
          }).toList(),
          expansionCallback: (int panelIndex, bool isExpanded) {
            setState(() {
              displayWorkout.exercises[panelIndex].isExpanded = !isExpanded;
            });
          }
        )
      ]
    );
  }
}

class MainView extends StatefulWidget {
  MainView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MainViewState createState() => new _MainViewState();
}

class _MainViewState extends State<MainView> {
  String _currWorkoutDate = '2017-11-10';
  Workout _currWorkout;

  _getWorkout() async {
    String url = 'http://192.168.1.2:8080/api/workouts/date/'+_currWorkoutDate;
    var httpClient = createHttpClient();
    var response = await httpClient.read(url);
    Map data = JSON.decode(response);

    String name = data['name'];
    String date = data['date'];
    String title = data['title'];
    List responseExercises = data['exercises'];

    List<Exercise> exercises = [];
    List<Set> sets = [];
    for(num i = 0; i < responseExercises.length; i++){

      sets = [];
      for(num j = 0; j < responseExercises[i]['sets'].length; j++){
        sets.add(new Set(reps: responseExercises[i]['sets'][j]['reps'], weight: responseExercises[i]['sets'][j]['weight']));
      }

      exercises.add(new Exercise(name: responseExercises[i]['name'], title: responseExercises[i]['title'], date: responseExercises[i]['date'], sets: sets, isExpanded: false));
    }


    if (!mounted) return;

    setState(() {
      _currWorkout = new Workout(name: name, date: date, title: title, exercises: exercises);
    });

  }

  @override
  initState() {
    super.initState();

    _getWorkout();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Container(
        padding: const EdgeInsets.all(16.0),
        child: new Column(
          children: <Widget>[
            new WorkoutView(workout: _currWorkout),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          setState(() {
            _currWorkoutDate = '2017-11-21';
          });
        },
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
