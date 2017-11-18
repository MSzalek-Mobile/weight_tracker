import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:meta/meta.dart';
import 'package:weight_tracker/logic/actions.dart';
import 'package:weight_tracker/logic/redux_core.dart';
import 'package:weight_tracker/model/weight_entry.dart';
import 'package:weight_tracker/screens/weight_entry_dialog.dart';
import 'package:weight_tracker/widgets/weight_list_item.dart';

@immutable
class HistoryPageViewModel {
  //fields
  final List<WeightEntry> entries;

  //functions
  final Function(WeightEntry) editEntryCallback;
  final Function(WeightEntry) addEntryCallback;

  HistoryPageViewModel(
      {this.entries, this.editEntryCallback, this.addEntryCallback});
}

class HistoryPage extends StatelessWidget {
  HistoryPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, HistoryPageViewModel>(
      converter: (store) {
        return new HistoryPageViewModel(
          entries: store.state.entries,
          addEntryCallback: ((entry) =>
              store.dispatch(new AddEntryAction(entry))),
          editEntryCallback: ((entry) =>
              store.dispatch(new EditEntryAction(entry))),
        );
      },
      builder: (context, viewModel) {
        if (viewModel.entries.isEmpty) {
          return new Center(child: new Text("Add your weight to see history"),);
        } else {
          return new ListView.builder(
            shrinkWrap: true,
            itemCount: viewModel.entries.length,
            itemBuilder: (buildContext, index) {
              //calculating difference
              double difference = index == viewModel.entries.length - 1
                  ? 0.0
                  : viewModel.entries[index].weight -
                  viewModel.entries[index + 1].weight;
              return new InkWell(
                  onTap: () =>
                      _openEditEntryDialog(viewModel.entries[index],
                          context, viewModel.editEntryCallback),
                  child:
                  new WeightListItem(viewModel.entries[index], difference));
            },
          );
        }
      },
    );
  }

  _openEditEntryDialog(WeightEntry weightEntry, BuildContext context,
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
}
