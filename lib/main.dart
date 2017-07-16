import 'package:flutter/material.dart';
import 'package:weight_tracker/WeightListItem.dart';
import 'package:weight_tracker/model/WeightSave.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Weight Tracker',
      theme: new ThemeData(
        primarySwatch: Colors.green,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<WeightSave> weightSaves = new List();


  void _addWeightSave() {
    setState(() {
      weightSaves.add(new WeightSave(new DateTime.now(), 23.6));
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new ListView(
          children:
          weightSaves.map((WeightSave weightSave) {
            return new WeightListItem(weightSave);
          }).toList(),
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _addWeightSave,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ),
    );
  }

  void _showAddingWeightSaveDialog() {
    //TODO
  }
}