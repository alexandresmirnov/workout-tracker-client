import 'package:flutter/material.dart';

import 'models.dart';
import 'data_interface.dart';

//creates list with meta workouts that lead to SingleWorkout
class WorkoutList extends StatefulWidget {
  final DatabaseInterface interface;

  WorkoutList({Key key, this.interface}) : super(key: key);

  @override
  _WorkoutListState createState() => new _WorkoutListState();
}

class _WorkoutListState extends State<WorkoutList>{

  List<Workout> _metaWorkouts = [];

  _getMetaWorkouts() async {
    await widget.interface.open();

    List<MetaWorkout> metaWorkouts = await widget.interface.getAllMetaWorkouts();

    widget.interface.close();

    List<Workout> workouts = metaWorkouts.map((MetaWorkout mw) {
      return new Workout(name: "temp name", type: mw.type, date: mw.date, exercises: []);
    }).toList();

    setState(() {
      _metaWorkouts = workouts;
    });
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
        title: new Text("All Workouts"),
      ),
      body: new Container(
        padding: const EdgeInsets.all(16.0),
        child: new Card(
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: ListTile.divideTiles(
              context: context,
              tiles: this._metaWorkouts.map((Workout w) {
                return w.createListTile(
                  onTap: (){
                    Navigator.of(context).pushNamed('/workouts/date/'+w.date);
                  }
                );
              }),
              color: new Color(0xFFAAAAAA)
            ).toList()
          )
        ),
      ),
    );
  }
}
