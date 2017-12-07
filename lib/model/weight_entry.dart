import 'package:firebase_database/firebase_database.dart';
import 'package:quiver/core.dart';

class WeightEntry {
  String key;
  DateTime dateTime;
  double weight;
  String note;

  WeightEntry(this.dateTime, this.weight, this.note);

  WeightEntry.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        dateTime =
        new DateTime.fromMillisecondsSinceEpoch(snapshot.value["date"]),
        weight = snapshot.value["weight"].toDouble(),
        note = snapshot.value["note"];

  WeightEntry.copy(WeightEntry weightEntry)
      : key = weightEntry.key,
  //copy datetime
        dateTime = new DateTime.fromMillisecondsSinceEpoch(
            weightEntry.dateTime.millisecondsSinceEpoch),
        weight = weightEntry.weight,
        note = weightEntry.note;

  WeightEntry._internal(this.key, this.dateTime, this.weight, this.note);

  WeightEntry copyWith(
      {String key, DateTime dateTime, double weight, String note}) {
    return new WeightEntry._internal(
      key ?? this.key,
      dateTime ?? this.dateTime,
      weight ?? this.weight,
      note ?? this.note,
    );
  }

  toJson() {
    return {
      "weight": weight,
      "date": dateTime.millisecondsSinceEpoch,
      "note": note
    };
  }

  @override
  int get hashCode => hash4(key, dateTime, weight, note);

  @override
  bool operator ==(other) =>
      other is WeightEntry &&
          key == other.key &&
          dateTime.millisecondsSinceEpoch == other.dateTime
              .millisecondsSinceEpoch &&
          weight == other.weight &&
          note == other.note;
}
