import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:weight_tracker/logic/actions.dart';
import 'package:weight_tracker/logic/redux_state.dart';
import 'package:weight_tracker/screens/history_page.dart';
import 'package:weight_tracker/screens/settings_screen.dart';
import 'package:weight_tracker/screens/statistics_page.dart';
import 'package:weight_tracker/screens/weight_entry_dialog.dart';

class MainPageViewModel {
  final double defaultWeight;
  final bool hasEntryBeenAdded;
  final String unit;
  final Function() openAddEntryDialog;
  final Function() acceptEntryAddedCallback;

  MainPageViewModel({
    this.openAddEntryDialog,
    this.defaultWeight,
    this.hasEntryBeenAdded,
    this.acceptEntryAddedCallback,
    this.unit,
  });
}

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title, this.analytics}) : super(key: key);
  final FirebaseAnalytics analytics;
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
          hasEntryBeenAdded: store.state.mainPageState.hasEntryBeenAdded,
          acceptEntryAddedCallback: () =>
              store.dispatch(new AcceptEntryAddedAction()),
          openAddEntryDialog: () {
            store.dispatch(new OpenAddEntryDialog());
            Navigator.of(context).push(new MaterialPageRoute(
              builder: (BuildContext context) {
                return new WeightEntryDialog();
              },
              fullscreenDialog: true,
            ));
            widget.analytics.logEvent(name: 'open_add_dialog');
          },
          unit: store.state.unit,
        );
      },
      onInit: (store) {
        store.dispatch(new GetSavedWeightNote());
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
                        key: new Key('StatisticsTab'),
                        text: "STATISTICS",
                        icon: new Icon(Icons.show_chart),
                      ),
                      new Tab(
                        key: new Key('HistoryTab'),
                        text: "HISTORY",
                        icon: new Icon(Icons.history),
                      ),
                    ],
                    controller: _tabController,
                  ),
                  actions: _buildMenuActions(context),
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
            onPressed: () => viewModel.openAddEntryDialog(),
            tooltip: 'Add new weight entry',
            child: new Icon(Icons.add),
          ),
        );
      },
    );
  }

  List<Widget> _buildMenuActions(BuildContext context) {
    return [
      IconButton(
          icon: new Icon(Icons.settings),
          onPressed: () => _openSettingsPage(context)),
    ];
  }

  _scrollToTop() {
    _scrollViewController.animateTo(
      0.0,
      duration: const Duration(microseconds: 1),
      curve: new ElasticInCurve(0.01),
    );
  }

  _openSettingsPage(BuildContext context) async {
    Navigator.of(context).push(new MaterialPageRoute(
      builder: (BuildContext context) {
        return new SettingsPage();
      },
    ));
  }
}
