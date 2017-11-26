import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'models.dart';

class SingleWorkout extends StatefulWidget {
  SingleWorkout({Key key, this.date}) : super(key: key);

  final String date;

  @override
  _SingleWorkoutState createState() => new _SingleWorkoutState();
}

class _SingleWorkoutState extends State<SingleWorkout>{

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
        title: new Text(_displayWorkout.name + " (" + _displayWorkout.date + ")"),
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
          Navigator.of(context).pushNamed('/workouts/date/2017-11-10');
        },
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ),
    );
  }
}
