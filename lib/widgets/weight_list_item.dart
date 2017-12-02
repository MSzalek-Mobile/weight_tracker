import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weight_tracker/logic/constants.dart';
import 'package:weight_tracker/model/weight_entry.dart';

class WeightListItem extends StatelessWidget {
  final WeightEntry weightEntry;
  final double weightDifference;
  final String unit;

  WeightListItem(this.weightEntry, this.weightDifference, this.unit);

  @override
  Widget build(BuildContext context) {
    double displayWeight =
    unit == "kg" ? weightEntry.weight : weightEntry.weight * KG_LBS_RATIO;
    double displayDifference =
    unit == "kg" ? weightDifference : weightDifference * KG_LBS_RATIO;
    return new Padding(
      padding: new EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          new Expanded(
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Column(
                  children: [
                    new Text(
                      new DateFormat.MMMEd().format(weightEntry.dateTime),
                      textScaleFactor: 0.9,
                      textAlign: TextAlign.left,
                    ),
                    new Text(
                      new TimeOfDay.fromDateTime(weightEntry.dateTime)
                          .format(context),
                      textScaleFactor: 0.8,
                      textAlign: TextAlign.right,
                      style: new TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                ),
                (weightEntry.note == null || weightEntry.note.isEmpty)
                    ? new Container(
                  height: 0.0,
                )
                    : new Padding(
                  padding: new EdgeInsets.only(left: 4.0),
                  child: new Icon(
                    Icons.speaker_notes,
                    color: Colors.grey[300],
                    size: 16.0,
                  ),
                ),
              ],
            ),
          ),
          new Text(
            displayWeight.toStringAsFixed(1),
            textScaleFactor: 2.0,
            textAlign: TextAlign.center,
          ),
          new Expanded(
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new Text(
                  _differenceText(displayDifference),
                  textScaleFactor: 1.6,
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _differenceText(double weightDifference) {
    if (weightDifference > 0) {
      return "+" + weightDifference.toStringAsFixed(1);
    } else if (weightDifference < 0) {
      return weightDifference.toStringAsFixed(1);
    } else {
      return "-";
    }
  }
}
