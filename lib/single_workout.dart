import 'package:flutter/material.dart';

import 'models.dart';
import 'data_interface.dart';

class SingleWorkout extends StatefulWidget {
  final DatabaseInterface interface;
  final String date;

  SingleWorkout({Key key, this.interface, this.date}) : super(key: key);

  @override
  _SingleWorkoutState createState() => new _SingleWorkoutState();
}

class _SingleWorkoutState extends State<SingleWorkout>{

  Workout _displayWorkout = new Workout.defaultValues();
  List<bool> _expansionControl = [];

  _getWorkout(date) async {
    await widget.interface.open();

    List<Workout> workouts = await widget.interface.getWorkoutsByDate(date);
    await widget.interface.close();

    Workout displayWorkout;

    if(workouts.length > 0){
      displayWorkout = workouts.first;
    }
    else {
      displayWorkout = new Workout.defaultValues();
    }


    setState(() {
      _displayWorkout = displayWorkout;

      for(int i = 0; i < _displayWorkout.exercises.length; i++){
        _expansionControl.add(false);
      }
    });
  }

  @override
  initState() {
    super.initState();

    _getWorkout(widget.date);
  }

  @override
  Widget build(BuildContext context){

    List<ExpansionTile> tiles = [];

    for(int i = 0; i < _displayWorkout.exercises.length; i++){
      tiles.add(_displayWorkout.exercises[i].toExpansionTile());
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(_displayWorkout.name + " (" + _displayWorkout.date + ")"),
      ),
      body: new Container(
        padding: const EdgeInsets.all(11.0),
        child: new Card(
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: ListTile.divideTiles(
              context: context,
              tiles: tiles,
              color: new Color(0xFFAAAAAA)
            ).toList()
          )
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        tooltip: 'Add', // used by assistive technologies
        child: new Icon(Icons.add),
        onPressed: null,
      ),
    );
  }
}
