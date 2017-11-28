import 'package:flutter/material.dart';

import 'single_workout.dart';
import 'workout_list.dart';

import 'models.dart';
import 'data_interface.dart';

doDataStuff() async {
  DatabaseInterface di = new DatabaseInterface();
  await di.open();

  int id = await di.addMetaWorkout(new MetaWorkout(type: "pull", date: "2017-11-18"));

  await di.close();
  //MetaWorkout testing = await di.getMetaWorkoutByID(id);
  //print(testing.type);

  //int id = await di.addMetaExercise(new MetaExercise(type: "exercise test 1", date: "2017-11-13"));

  //MetaExercise testing = await di.getMetaExerciseByID(id);
  //print(testing.toString());

  //List<MetaWorkout> workouts = await di.getAllMetaWorkouts();
  //List<MetaExercise> exercises = await di.getAllMetaExercises();
}

void main() {
  runApp(new WorkoutTracker());
}

class WorkoutTracker extends StatefulWidget {

  final DatabaseInterface interface = new DatabaseInterface();

  @override
  _WorkoutTrackerState createState() => new _WorkoutTrackerState();
}

class _WorkoutTrackerState extends State<WorkoutTracker> {

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

    print(widget.interface);

    return new MaterialApp(
      title: 'Workout Tracker',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => new WorkoutList(interface: widget.interface),
      },
      onGenerateRoute: _getRoute,
    );
  }
}
