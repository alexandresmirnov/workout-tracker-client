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

    List<ExpansionPanel> panels = [];

    for(int i = 0; i < _displayWorkout.exercises.length; i++){
      panels.add(_displayWorkout.exercises[i].toExpansionPanel(isExpanded: _expansionControl[i]));
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(_displayWorkout.name + " (" + _displayWorkout.date + ")"),
      ),
      body: new Container(
        padding: const EdgeInsets.all(16.0),
        child: new Column(
          children: <Widget>[
            new ExpansionPanelList(
              children: panels,
              expansionCallback: (int panelIndex, bool isExpanded) {
                setState(() {
                  _expansionControl[panelIndex] = !isExpanded;
                });
              }
            )
          ]
        )
      ),
      floatingActionButton: new FloatingActionButton(
        tooltip: 'Add', // used by assistive technologies
        child: new Icon(Icons.add),
        onPressed: null,
      ),
    );
  }
}
