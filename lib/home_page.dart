import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
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

final mainReference = FirebaseDatabase.instance.reference();

class _HomePageState extends State<HomePage> {
  List<WeightEntry> weightSaves = new List();
  ScrollController _listViewScrollController = new ScrollController();
  double _itemExtent = 50.0;

  _HomePageState() {
    mainReference.onChildAdded.listen(_onEntryAdded);
    mainReference.onChildChanged.listen(_onEntryEdited);
  }

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
              onTap: () => _openEditEntryDialog(weightSaves[index]),
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

  _openEditEntryDialog(WeightEntry weightEntry) {
    Navigator
        .of(context)
        .push(
      new MaterialPageRoute<WeightEntry>(
        builder: (BuildContext context) {
          return new WeightEntryDialog.edit(weightEntry);
        },
        fullscreenDialog: true,
      ),
    )
        .then((WeightEntry newEntry) {
      if (newEntry != null) {
        mainReference.child(weightEntry.key).set(newEntry.toJson());
      }
    });
  }

  Future _openAddEntryDialog() async {
    WeightEntry entry =
    await Navigator.of(context).push(new MaterialPageRoute<WeightEntry>(
        builder: (BuildContext context) {
          return new WeightEntryDialog.add(
              weightSaves.isNotEmpty ? weightSaves.last.weight : 60.0);
        },
        fullscreenDialog: true));
    if (entry != null) {
      mainReference.push().set(entry.toJson());
    }
  }

  _onEntryAdded(Event event) {
    setState(() {
      weightSaves.add(new WeightEntry.fromSnapshot(event.snapshot));
      weightSaves.sort((we1, we2) => we1.dateTime.compareTo(we2.dateTime));
    });
    _scrollToTop();
  }

  _onEntryEdited(Event event) {
    var oldValue =
    weightSaves.singleWhere((entry) => entry.key == event.snapshot.key);
    setState(() {
      weightSaves[weightSaves.indexOf(oldValue)] =
      new WeightEntry.fromSnapshot(event.snapshot);
      weightSaves.sort((we1, we2) => we1.dateTime.compareTo(we2.dateTime));
    });
  }

  _scrollToTop() {
    _listViewScrollController.animateTo(
      weightSaves.length * _itemExtent,
      duration: const Duration(microseconds: 1),
      curve: new ElasticInCurve(0.01),
    );
  }
}
