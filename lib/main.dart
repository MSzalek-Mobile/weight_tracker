import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:weight_tracker/home_page.dart';

void main() {
  FirebaseDatabase.instance.setPersistenceEnabled(true);
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
