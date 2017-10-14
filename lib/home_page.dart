import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:meta/meta.dart';
import 'package:weight_tracker/logic/actions.dart';
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

@immutable
class HomePageViewModel {
  //fields
  final bool hasEntryBeenAdded;
  final List<WeightEntry> entries;

  //functions
  final Function() acceptEntryAddedCallback;
  final Function(WeightEntry) editEntryCallback;
  final Function(WeightEntry) addEntryCallback;

  HomePageViewModel({this.hasEntryBeenAdded,
    this.entries,
    this.acceptEntryAddedCallback,
    this.editEntryCallback,
    this.addEntryCallback});
}

class _HomePageState extends State<HomePage> {
  ScrollController _listViewScrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, HomePageViewModel>(
      converter: (store) {
        return new HomePageViewModel(
          hasEntryBeenAdded: store.state.hasEntryBeenAdded,
          entries: store.state.entries,
          acceptEntryAddedCallback: (() =>
              store.dispatch(new AcceptEntryAddedAction())),
          addEntryCallback: ((entry) =>
              store.dispatch(new AddEntryAction(entry))),
          editEntryCallback: ((entry) =>
              store.dispatch(new EditEntryAction(entry))),
        );
      },
      builder: (context, viewModel) {
        if (viewModel.hasEntryBeenAdded) {
          _scrollToTop();
          viewModel.acceptEntryAddedCallback();
        }
        return new Scaffold(
          appBar: new AppBar(
            title: new Text(widget.title),
          ),
          body: new ListView.builder(
            shrinkWrap: true,
            controller: _listViewScrollController,
            itemCount: viewModel.entries.length,
            itemBuilder: (buildContext, index) {
              //calculating difference
              double difference = index == viewModel.entries.length - 1
                  ? 0.0
                  : viewModel.entries[index].weight -
                  viewModel.entries[index + 1].weight;
              return new InkWell(
                  onTap: () =>
                      _openEditEntryDialog(
                          viewModel.entries[index],
                          viewModel.editEntryCallback),
                  child:
                  new WeightListItem(viewModel.entries[index], difference));
            },
          ),
          floatingActionButton: new FloatingActionButton(
            onPressed: () =>
                _openAddEntryDialog(
                    viewModel.entries, viewModel.addEntryCallback),
            tooltip: 'Add new weight entry',
            child: new Icon(Icons.add),
          ),
        );
      },
    );
  }

  _openEditEntryDialog(WeightEntry weightEntry,
      Function(WeightEntry) onSubmittedCallback) async {
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
        onSubmittedCallback(newEntry);
      }
    });
  }

  _openAddEntryDialog(List<WeightEntry> entries,
      Function(WeightEntry) onSubmittedCallback) async {
    WeightEntry entry =
    await Navigator.of(context).push(new MaterialPageRoute<WeightEntry>(
        builder: (BuildContext context) {
          return new WeightEntryDialog.add(
              entries.isNotEmpty ? entries.first.weight : 60.0);
        },
        fullscreenDialog: true));
    if (entry != null) {
      onSubmittedCallback(entry);
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
