import 'dart:convert';
import 'package:flutter/services.dart';

import 'models.dart';

/*
 * interface to data to centralize all API call definitions.
 * also, this will manage the local SQL database and sync operations
 */

class DataInterface {

  String apiLocation;
  var client = createHttpClient();

  DataInterface({this.apiLocation});

  getMetaWorkouts() async {
    List<MetaWorkout> metaWorkouts = [];

    String url = apiLocation + '/workouts/meta/';
    var response = await client.read(url);
    List data = JSON.decode(response); //list of objects to be converted

    //convert response objects into MetaWorkouts
    for(int i = 0; i < data.length; i++){
      metaWorkouts.add(new MetaWorkout.fromResponse(data[i]));
    }

    return metaWorkouts;
  }

  getWorkout(date) async {
    String url = apiLocation + '/workouts/date/'+date;
    var response = await client.read(url);
    Map data = JSON.decode(response);

    return new Workout.fromResponse(data);
  }

}
