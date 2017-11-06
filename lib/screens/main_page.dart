import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:weight_tracker/logic/actions.dart';
import 'package:weight_tracker/logic/redux_core.dart';
import 'package:weight_tracker/model/weight_entry.dart';
import 'package:weight_tracker/screens/history_page.dart';
import 'package:weight_tracker/screens/statistics_page.dart';
import 'package:weight_tracker/screens/weight_entry_dialog.dart';

class MainPageViewModel {
  final double defaultWeight;
  final bool hasEntryBeenAdded;
  final Function(WeightEntry) addEntryCallback;
  final Function() acceptEntryAddedCallback;

  MainPageViewModel(
      {this.addEntryCallback,
      this.defaultWeight,
      this.hasEntryBeenAdded,
      this.acceptEntryAddedCallback});
}

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  State<MainPage> createState() {
    return new MainPageState();
  }
}

class MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  ScrollController _scrollViewController;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _scrollViewController = new ScrollController();
    _tabController = new TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _scrollViewController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, MainPageViewModel>(
      converter: (store) {
        return new MainPageViewModel(
          defaultWeight: store.state.entries.isEmpty
              ? 60.0
              : store.state.entries.first.weight,
          hasEntryBeenAdded: store.state.hasEntryBeenAdded,
          acceptEntryAddedCallback: () =>
              store.dispatch(new AcceptEntryAddedAction()),
          addEntryCallback: (entry) =>
              store.dispatch(new AddEntryAction(entry)),
        );
      },
      builder: (context, viewModel) {
        if (viewModel.hasEntryBeenAdded) {
          _scrollToTop();
          viewModel.acceptEntryAddedCallback();
        }
        return new Scaffold(
          body: new NestedScrollView(
            controller: _scrollViewController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                new SliverAppBar(
                  title: new Text(widget.title),
                  pinned: true,
                  floating: true,
                  forceElevated: innerBoxIsScrolled,
                  bottom: new TabBar(
                    tabs: <Tab>[
                      new Tab(
                        text: "STATISTICS",
                        icon: new Icon(Icons.show_chart),
                      ),
                      new Tab(
                        text: "HISTORY",
                        icon: new Icon(Icons.history),
                      ),
                    ],
                    controller: _tabController,
                  ),
                ),
              ];
            },
            body: new TabBarView(
              children: <Widget>[
                new StatisticsPage(),
                new HistoryPage(),
              ],
              controller: _tabController,
            ),
          ),
          floatingActionButton: new FloatingActionButton(
            onPressed: () =>
                _openAddEntryDialog(
                    viewModel.defaultWeight, context,
                    viewModel.addEntryCallback),
            tooltip: 'Add new weight entry',
            child: new Icon(Icons.add),
          ),
        );
      },
    );
  }

  _openAddEntryDialog(double defaultWeight, BuildContext context,
      Function(WeightEntry) onSubmittedCallback) async {
    WeightEntry entry =
        await Navigator.of(context).push(new MaterialPageRoute<WeightEntry>(
            builder: (BuildContext context) {
              return new WeightEntryDialog.add(defaultWeight);
            },
            fullscreenDialog: true));
    if (entry != null) {
      onSubmittedCallback(entry);
    }
  }

  _scrollToTop() {
    _scrollViewController.animateTo(
      0.0,
      duration: const Duration(microseconds: 1),
      curve: new ElasticInCurve(0.01),
    );
  }
}
