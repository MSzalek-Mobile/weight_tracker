import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:weight_tracker/logic/redux_core.dart';
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
  ScrollController _listViewScrollController = new ScrollController();
  Store<ReduxState> _store;

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, Null>(
      converter: (store) {
        _store = store;
      },
      builder: (context, nil) {
        if (_store.state.hasEntryBeenAdded) {
          _scrollToTop();
          _store.dispatch(new AcceptEntryAddedAction());
        }
        return new Scaffold(
          appBar: new AppBar(
            title: new Text(widget.title),
          ),
          body: new ListView.builder(
            shrinkWrap: true,
            controller: _listViewScrollController,
            itemCount: _store.state.entries.length,
            itemBuilder: (buildContext, index) {
              //calculating difference
              double difference = index == _store.state.entries.length - 1
                  ? 0.0
                  : _store.state.entries[index].weight -
                  _store.state.entries[index + 1].weight;
              return new InkWell(
                  onTap: () =>
                      _openEditEntryDialog(_store.state.entries[index]),
                  child: new WeightListItem(
                      _store.state.entries[index], difference));
            },
          ),
          floatingActionButton: new FloatingActionButton(
            onPressed: _openAddEntryDialog,
            tooltip: 'Add new weight entry',
            child: new Icon(Icons.add),
          ),
        );
      },
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
        newEntry.key = weightEntry.key;
        _store.dispatch(new LocalEditAction(newEntry));
      }
    });
  }

  Future _openAddEntryDialog() async {
    WeightEntry entry =
    await Navigator.of(context).push(new MaterialPageRoute<WeightEntry>(
        builder: (BuildContext context) {
          return new WeightEntryDialog.add(_store.state.entries.isNotEmpty
              ? _store.state.entries.first.weight
              : 60.0);
        },
        fullscreenDialog: true));
    if (entry != null) {
      _store.dispatch(new LocalAddAction(entry));
    }
  }

  _scrollToTop() {
    _listViewScrollController.animateTo(
      0.0,
      duration: const Duration(microseconds: 1),
      curve: new ElasticInCurve(0.01),
    );
  }
}
