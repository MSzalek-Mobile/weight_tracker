import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:weight_tracker/model/weight_entry.dart';

class WeightEntryDialog extends StatefulWidget {
  final double initialWeight;
  final WeightEntry weighEntryToEdit;

  WeightEntryDialog.add(this.initialWeight) : weighEntryToEdit = null;

  WeightEntryDialog.edit(this.weighEntryToEdit)
      : initialWeight = weighEntryToEdit.weight;

  @override
  WeightEntryDialogState createState() {
    if (weighEntryToEdit != null) {
      return new WeightEntryDialogState(weighEntryToEdit.dateTime,
          weighEntryToEdit.weight, weighEntryToEdit.note);
    } else {
      return new WeightEntryDialogState(
          new DateTime.now(), initialWeight, null);
    }
  }
}

class WeightEntryDialogState extends State<WeightEntryDialog> {
  DateTime _dateTime = new DateTime.now();
  double _weight;
  String _note;

  TextField _noteTextField;

  WeightEntryDialogState(this._dateTime, this._weight, this._note);

  @override
  Widget build(BuildContext context) {
    TextStyle defaultTextStyle = Theme
        .of(context)
        .textTheme
        .subhead
        .copyWith(color: Colors.black, fontSize: 16.0);

    _noteTextField = new TextField(
      decoration: new InputDecoration(
        labelText: 'Optional note',
      ),
      controller: new TextEditingController(text: _note),
      onSubmitted: (string) => setState(() => _note = string),
    );

    return new Scaffold(
      appBar: new AppBar(
        title: widget.weighEntryToEdit == null
            ? const Text("New entry")
            : const Text("Edit entry"),
        actions: [
          new FlatButton(
              onPressed: () {
                _note = _noteTextField.controller.text;
                Navigator
                    .of(context)
                    .pop(new WeightEntry(_dateTime, _weight, _note));
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
        style: defaultTextStyle,
        child: new Padding(
          padding: new EdgeInsets.all(12.0),
          child: new Column(
            children: <Widget>[
              new Padding(
                padding: new EdgeInsets.all(8.0),
                child: new DateTimeItem(
                  dateTime: _dateTime,
                  onChanged: (dateTime) => setState(() => _dateTime = dateTime),
                ),
              ),
              new Padding(
                padding: new EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                child: new InkWell(
                  onTap: () => _showWeightPicker(context),
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              new Padding(
                padding: new EdgeInsets.symmetric(horizontal: 8.0),
                child: new InkWell(
                  onTap: () => _showWeightPicker(context),
                  child: new Row(
                    children: <Widget>[
                      new Padding(
                        padding: new EdgeInsets.only(top: 4.0),
                        child: new Icon(
                          Icons.speaker_notes,
                          color: Colors.grey[500],
                        ),
                      ),
                      new Expanded(
                        child: new Padding(
                          padding: new EdgeInsets.only(left: 16.0),
                          child: _noteTextField,
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
    );
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
    return new Row(
      children: <Widget>[
        new Expanded(
          child: new InkWell(
            onTap: () {
              _showDatePicker(context);
            },
            child: new Padding(
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
