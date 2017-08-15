import 'dart:async';

import 'package:flutter/material.dart';
import 'package:weight_tracker/model/weight_entry.dart';
import 'package:weight_tracker/weight_entry_dialog.dart';
import 'package:weight_tracker/weight_list_item.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<WeightEntry> weightSaves = new List();
  ScrollController _listViewScrollController = new ScrollController();
  double _itemExtent = 50.0;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new ListView.builder(
        shrinkWrap: true,
        reverse: true,
        controller: _listViewScrollController,
        itemCount: weightSaves.length,
        itemBuilder: (buildContext, index) {
          //calculating difference
          double difference = index == 0
              ? 0.0
              : weightSaves[index].weight - weightSaves[index - 1].weight;
          return new InkWell(
              onTap: () => _editEntry(weightSaves[index]),
              child: new WeightListItem(weightSaves[index], difference));
        },
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _openAddEntryDialog,
        tooltip: 'Add new weight entry',
        child: new Icon(Icons.add),
      ),
    );
  }

  void _addWeightSave(WeightEntry weightSave) {
    setState(() {
      weightSaves.add(weightSave);
      _listViewScrollController.animateTo(
        weightSaves.length * _itemExtent,
        duration: const Duration(microseconds: 1),
        curve: new ElasticInCurve(0.01),
      );
    });
  }

  _editEntry(WeightEntry weightSave) {
    Navigator
        .of(context)
        .push(
      new MaterialPageRoute<WeightEntry>(
        builder: (BuildContext context) {
          return new WeightEntryDialog.edit(weightSave);
        },
        fullscreenDialog: true,
      ),
    )
        .then((newSave) {
      if (newSave != null) {
        setState(() => weightSaves[weightSaves.indexOf(weightSave)] = newSave);
      }
    });
  }

  Future _openAddEntryDialog() async {
    WeightEntry save =
    await Navigator.of(context).push(new MaterialPageRoute<WeightEntry>(
        builder: (BuildContext context) {
          return new WeightEntryDialog.add(
              weightSaves.isNotEmpty ? weightSaves.last.weight : 60.0);
        },
        fullscreenDialog: true));
    if (save != null) {
      _addWeightSave(save);
    }
  }
}
