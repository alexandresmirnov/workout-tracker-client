import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'models.dart';
import 'data_interface.dart';

class SingleWorkout extends StatefulWidget {
  SingleWorkout({Key key, this.date}) : super(key: key);

  final String date;

  @override
  _SingleWorkoutState createState() => new _SingleWorkoutState();
}

class _SingleWorkoutState extends State<SingleWorkout>{

  Workout _displayWorkout = new Workout.defaultValues();
  List<bool> _expansionControl = [];

  _getWorkout(date) async {
    DataInterface di = new DataInterface(apiLocation: "http://192.168.1.2:8080/api");
    Workout w = await di.getWorkout(date);

    setState(() {
      _displayWorkout = w;

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
      )
    );
  }
}
