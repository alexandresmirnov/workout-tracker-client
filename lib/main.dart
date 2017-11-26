import 'package:flutter/material.dart';

import 'single_workout.dart';

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
         '/': (BuildContext context) => new SingleWorkout(date: '2017-11-11'),
      },
      onGenerateRoute: _getRoute,
    );
  }
}
