import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:weight_tracker/logic/actions.dart';
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
  TextEditingController _textController;

  WeightEntryDialogState(this._dateTime, this._weight, this._note);

  Widget _createAppBar(BuildContext context) {
    bool isInEditMode = widget.weighEntryToEdit != null;

    return new AppBar(
      title: isInEditMode ? const Text("Edit entry") : const Text("New entry"),
      actions: [
        isInEditMode ? new FlatButton(
          onPressed: () {
            Navigator.of(context).pop(
                new RemoveEntryAction(widget.weighEntryToEdit));
          },
          child: new Text('DELETE',
              style: Theme
                  .of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.white)),
        ) : new Container(),
        new FlatButton(
          onPressed: () {
            WeightEntry entry = new WeightEntry(_dateTime, _weight, _note);
            var returnedAction = isInEditMode
                ? new EditEntryAction(entry)
                : new AddEntryAction(entry);
            Navigator.of(context).pop(returnedAction);
          },
          child: new Text('SAVE',
              style: Theme
                  .of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.white)),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _textController = new TextEditingController(text: _note);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _createAppBar(context),
      body: new Column(
        children: [
          new ListTile(
            leading: new Icon(Icons.today, color: Colors.grey[500]),
            title: new DateTimeItem(
              dateTime: _dateTime,
              onChanged: (dateTime) => setState(() => _dateTime = dateTime),
            ),
          ),
          new ListTile(
            leading: new Image.asset(
              "assets/scale-bathroom.png",
              color: Colors.grey[500],
              height: 24.0,
              width: 24.0,
            ),
            title: new Text(
              "$_weight kg",
            ),
            onTap: () => _showWeightPicker(context),
          ),
          new ListTile(
            leading: new Icon(Icons.speaker_notes, color: Colors.grey[500]),
            title: new TextField(
              decoration: new InputDecoration(
                hintText: 'Optional note',
              ),
              controller: _textController,
              onChanged: (value) => _note = value,
            ),
          ),
        ],
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
            onTap: (() => _showDatePicker(context)),
            child: new Padding(
                padding: new EdgeInsets.symmetric(vertical: 8.0),
                child: new Text(new DateFormat('EEEE, MMMM d').format(date))),
          ),
        ),
        new InkWell(
          onTap: (() => _showTimePicker(context)),
          child: new Padding(
              padding: new EdgeInsets.symmetric(vertical: 8.0),
              child: new Text(time.format(context))),
        ),
      ],
    );
  }

  Future _showDatePicker(BuildContext context) async {
    DateTime dateTimePicked = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: date.subtract(const Duration(days: 365)),
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
