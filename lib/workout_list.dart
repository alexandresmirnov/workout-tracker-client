import 'package:flutter/material.dart';

import 'models.dart';
import 'data_interface.dart';

//creates list with meta workouts that lead to SingleWorkout
class WorkoutList extends StatefulWidget {
  WorkoutList({Key key}) : super(key: key);

  @override
  _WorkoutListState createState() => new _WorkoutListState();
}

class _WorkoutListState extends State<WorkoutList>{

  List<MetaWorkout> _metaWorkouts = [];

  _getMetaWorkouts() async {
    DataInterface di = new DataInterface(apiLocation: "http://192.168.1.2:8080/api");
    List<MetaWorkout> metaWorkouts = await di.getMetaWorkouts();

    setState(() {
      _metaWorkouts = metaWorkouts;
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
              tiles: this._metaWorkouts.map((MetaWorkout mw) {
                return mw.createListTile(
                  onTap: (){
                    Navigator.of(context).pushNamed('/workouts/date/'+mw.date);
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
