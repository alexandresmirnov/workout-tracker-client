import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'models.dart';

//creates list with meta workouts that lead to SingleWorkout
class WorkoutList extends StatefulWidget {
  WorkoutList({Key key}) : super(key: key);

  @override
  _WorkoutListState createState() => new _WorkoutListState();
}

class _WorkoutListState extends State<WorkoutList>{

  List<MetaWorkout> _metaWorkouts = [];

  _getMetaWorkouts() async {
    String url = 'http://192.168.1.2:8080/api/workouts/meta/';
    var httpClient = createHttpClient();
    var response = await httpClient.read(url);
    List data = JSON.decode(response); //list of objects to be converted

    //convert response objects into MetaWorkouts
    List<MetaWorkout> metaWorkouts = [];
    for(num i = 0; i < data.length; i++){
      metaWorkouts.add(new MetaWorkout.fromResponse(data[i]));
    }

    print(data[0]);

    setState(() {
      _metaWorkouts = metaWorkouts;
      print('_metaWorkouts[0].name after response: ' + _metaWorkouts[0].name);
    });

    if (!mounted) return;

  }

  @override
  initState() {
    super.initState();

    _getMetaWorkouts();
  }

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("all workouts"),
      ),
      body: new Container(
        padding: const EdgeInsets.all(16.0),
        child: new Text('test')
      ),
    );
  }
}
