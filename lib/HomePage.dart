import 'dart:async';

import 'package:flutter/material.dart';
import 'package:weight_tracker/WeightListItem.dart';
import 'package:weight_tracker/add_entry_dialog.dart';
import 'package:weight_tracker/model/WeightSave.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<WeightSave> weightSaves = new List();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new ListView.builder(
        itemCount: weightSaves.length,
        itemBuilder: (buildContext, index) {
          //calculating difference
          double difference = index == 0
              ? 0.0
              : weightSaves[index].weight - weightSaves[index - 1].weight;
          return new WeightListItem(weightSaves[index], difference);
        },
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _openAddEntryDialog,
        tooltip: 'Add new weight entry',
        child: new Icon(Icons.add),
      ),
    );
  }

  void _addWeightSave(WeightSave weightSave) {
    setState(() {
      weightSaves.add(weightSave);
    });
  }

  Future _openAddEntryDialog() async {
    WeightSave save =
    await Navigator.of(context).push(new MaterialPageRoute<WeightSave>(
        builder: (BuildContext context) {
          return new AddEntryDialog.add(
              weightSaves.isNotEmpty ? weightSaves.last.weight : 60.0);
        },
        fullscreenDialog: true));
    if (save != null) {
      _addWeightSave(save);
    }
  }
}
