import 'package:flutter/material.dart';
import 'package:weight_tracker/HomePage.dart';


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
      home: new HomePage(title: 'Weight Tracker'),
    );
  }
}