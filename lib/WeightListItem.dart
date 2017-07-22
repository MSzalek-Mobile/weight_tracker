import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weight_tracker/model/WeightSave.dart';

class WeightListItem extends StatelessWidget {
  final WeightSave weightSave;
  final double weightDifference;

  WeightListItem(this.weightSave, this.weightDifference);

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: new EdgeInsets.all(16.0),
      child: new Row(children: [
        new Expanded(
            child: new Column(children: [
              new Text(
                new DateFormat.yMMMMd().format(weightSave.dateTime),
                textScaleFactor: 0.9,
                textAlign: TextAlign.left,
              ),
              new Text(
                new DateFormat.EEEE().format(weightSave.dateTime),
                textScaleFactor: 0.8,
                textAlign: TextAlign.right,
                style: new TextStyle(
                  color: Colors.grey,
                ),
              ),
            ], crossAxisAlignment: CrossAxisAlignment.start)),
        new Expanded(
            child: new Text(
              weightSave.weight.toString(),
              textScaleFactor: 2.0,
              textAlign: TextAlign.center,
            )),
        new Expanded(
            child: new Text(
              weightDifference.toString(),
              textScaleFactor: 1.6,
              textAlign: TextAlign.right,
            )),
      ]),
    );
  }
}
