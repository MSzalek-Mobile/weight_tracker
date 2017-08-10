import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:weight_tracker/model/WeightSave.dart';

class AddEntryDialog extends StatefulWidget {
  final double initialWeight;
  final WeightSave weightSaveToEdit;

  AddEntryDialog.add(this.initialWeight) : weightSaveToEdit = null;

  AddEntryDialog.edit(this.weightSaveToEdit)
      : initialWeight = weightSaveToEdit.weight;

  @override
  AddEntryDialogState createState() {
    if (weightSaveToEdit != null) {
      return new AddEntryDialogState(weightSaveToEdit.dateTime,
          weightSaveToEdit.weight, weightSaveToEdit.note);
    } else {
      return new AddEntryDialogState(new DateTime.now(), initialWeight, null);
    }
  }
}

class AddEntryDialogState extends State<AddEntryDialog> {
  DateTime _dateTime = new DateTime.now();
  double _weight;
  String _note;

  AddEntryDialogState(this._dateTime, this._weight, this._note);

  @override
  Widget build(BuildContext context) {
    TextStyle headerTextStyle = Theme
        .of(context)
        .textTheme
        .subhead
        .copyWith(color: Colors.black, fontSize: 16.0);
    return new Scaffold(
        appBar: new AppBar(
          title: const Text('New entry'),
          actions: [
            new FlatButton(
                onPressed: () {
                  Navigator
                      .of(context)
                      .pop(new WeightSave(_dateTime, _weight, _note));
                },
                child: new Text('SAVE',
                    style: Theme
                        .of(context)
                        .textTheme
                        .subhead
                        .copyWith(color: Colors.white))),
          ],
        ),
        body: new DefaultTextStyle(
          style: headerTextStyle,
          child: new Container(
            padding: new EdgeInsets.all(12.0),
            child: new SingleChildScrollView(
              child: new Column(
                children: <Widget>[
                  new Padding(
                    padding: new EdgeInsets.all(8.0),
                    child: new DateTimeItem(
                      dateTime: _dateTime,
                      onChanged: (dateTime) =>
                          setState(() => _dateTime = dateTime),
                    ),
                  ),
                  new Padding(
                    padding: new EdgeInsets.symmetric(horizontal: 8.0),
                    child: new InkWell(
                      onTap: () => _showWeightPicker(context),
                      child: new Padding(
                        padding: new EdgeInsets.only(top: 8.0),
                        child: new Row(
                          children: <Widget>[
                            new Image.asset(
                              "assets/scale-bathroom.png",
                              color: Colors.grey[500],
                              height: 24.0,
                              width: 24.0,
                            ),
                            new Padding(
                              padding: new EdgeInsets.only(left: 16.0),
                              child: new Text(
                                "$_weight kg",
                                style: headerTextStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  new Padding(
                    padding: new EdgeInsets.symmetric(
                        vertical: 0.0, horizontal: 8.0),
                    child: new InkWell(
                      onTap: () => _showWeightPicker(context),
                      child: new Row(
                        children: <Widget>[
                          new Padding(
                              padding: new EdgeInsets.only(top: 4.0),
                              child: new Icon(
                                Icons.note_add,
                                color: Colors.grey[500],
                              )),
                          new Expanded(
                            child: new Padding(
                              padding: new EdgeInsets.only(left: 16.0),
                              child: new TextField(
                                decoration: new InputDecoration(
                                  labelText: 'Optional note',
                                  labelStyle: null,
                                ),
                                focusNode: new FocusNode(),
                                controller:
                                    new TextEditingController(text: _note),
                                onSubmitted: (string) =>
                                    setState(() => _note = string),
                                maxLines: null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  _showWeightPicker(BuildContext context) {
    showDialog(
      context: context,
      child: new NumberPickerDialog.decimal(
        minValue: 1,
        maxValue: 150,
        initialDoubleValue: _weight,
        title: new Text("Enter your weight"),
      ),
    ).then((value) {
      if (value != null) {
        setState(() => _weight = value);
      }
    });
  }
}

class DateTimeItem extends StatelessWidget {
  DateTimeItem({Key key, DateTime dateTime, @required this.onChanged})
      : assert(onChanged != null),
        date = dateTime == null
            ? new DateTime.now()
            : new DateTime(dateTime.year, dateTime.month, dateTime.day),
        time = dateTime == null
            ? new DateTime.now()
            : new TimeOfDay(hour: dateTime.hour, minute: dateTime.minute),
        super(key: key);

  final DateTime date;
  final TimeOfDay time;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return new Row(
      children: <Widget>[
        new Expanded(
          child: new InkWell(
            onTap: () {
              _showDatePicker(context);
            },
            child: new Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Icon(Icons.today, color: Colors.grey[500]),
                  new Padding(
                    padding: new EdgeInsets.only(left: 16.0),
                    child:
                        new Text(new DateFormat('EEEE, MMMM d').format(date)),
                  ),
                ],
              ),
            ),
          ),
        ),
        new InkWell(
          onTap: () {
            _showTimePicker(context);
          },
          child: new Container(
            margin: const EdgeInsets.only(left: 8.0),
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: new Row(
              children: <Widget>[
                new Text('$time'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future _showDatePicker(BuildContext context) async {
    DateTime dateTimePicked = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: date.subtract(const Duration(days: 20000)),
        lastDate: new DateTime.now());

    if (dateTimePicked != null) {
      onChanged(new DateTime(dateTimePicked.year, dateTimePicked.month,
          dateTimePicked.day, time.hour, time.minute));
    }
  }

  Future _showTimePicker(BuildContext context) async {
    TimeOfDay timeOfDay =
        await showTimePicker(context: context, initialTime: time);

    if (timeOfDay != null) {
      onChanged(new DateTime(
          date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute));
    }
  }
}
