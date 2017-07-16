import 'package:flutter/material.dart';
import 'package:weight_tracker/model/WeightSave.dart';

class WeightListItem extends StatelessWidget {
  final WeightSave weightSave;

  WeightListItem(this.weightSave);

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      leading: new CircleAvatar(),
      title: new Row(
          children: [
            new Text("text"),
          ]
      ),
    );
  }
}