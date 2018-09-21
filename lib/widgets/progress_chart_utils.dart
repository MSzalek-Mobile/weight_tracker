import 'package:weight_tracker/model/weight_entry.dart';

/// Removes entries that are before beginningDate
/// Adds an entry at the beginning of list if there is one before and after beginningDate
List<WeightEntry> prepareEntryList(
    List<WeightEntry> initialEntries, DateTime beginningDate) {
  List<WeightEntry> entries = initialEntries
      .where((entry) =>
          entry.dateTime.isAfter(beginningDate) ||
          copyDateWithoutTime(entry.dateTime)
              .isAtSameMomentAs(copyDateWithoutTime(beginningDate)))
      .toList();
  if (entries.isNotEmpty &&
      _isMissingEntryFromBeginningDate(beginningDate, entries) &&
      _isAnyEntryBeforeBeginningDate(beginningDate, initialEntries)) {
    _addFakeEntryOnTheChartBeginning(initialEntries, entries, beginningDate);
  }
  return entries;
}

DateTime getStartDateOfChart(DateTime now, int daysToShow) {
  DateTime beginningOfChart = now.subtract(
      new Duration(days: daysToShow - 1, hours: now.hour, minutes: now.minute));
  return beginningOfChart;
}

DateTime copyDateWithoutTime(DateTime dateTime) {
  return new DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
}

/// Adds missing entry at the start of a chart.
///
/// If user has not put entry on the date which is first date of a chart,
/// it takes last known weight before that date and estimates linearly weight on the beginning date.
/// Then it creates and adds fake [WeightEntry] with that weight and date.
void _addFakeEntryOnTheChartBeginning(List<WeightEntry> initialEntries,
    List<WeightEntry> entries, DateTime beginningDate) {
  List<WeightEntry> entriesNotInChart =
      initialEntries.where((entry) => !entries.contains(entry)).toList();
  WeightEntry firstEntryAfterBeginning = entries.last;
  WeightEntry lastEntryBeforeBeginning = entriesNotInChart.first;
  WeightEntry fakeEntry = new WeightEntry(
      beginningDate,
      _calculateWeightOnBeginningDate(
          lastEntryBeforeBeginning, firstEntryAfterBeginning, beginningDate),
      null);
  entries.add(fakeEntry);
}

bool _isMissingEntryFromBeginningDate(
    DateTime beginningDate, List<WeightEntry> entries) {
  return !entries.any((entry) =>
      entry.dateTime.day == beginningDate.day &&
      entry.dateTime.month == beginningDate.month &&
      entry.dateTime.year == beginningDate.year);
}

bool _isAnyEntryBeforeBeginningDate(
    DateTime beginningDate, List<WeightEntry> entries) {
  return entries.any((entry) => entry.dateTime.isBefore(beginningDate));
}

double _calculateWeightOnBeginningDate(WeightEntry lastEntryBeforeBeginning,
    WeightEntry firstEntryAfterBeginning, DateTime beginningDate) {
  DateTime firstEntryDateTime =
      copyDateWithoutTime(firstEntryAfterBeginning.dateTime);
  DateTime lastEntryDateTime =
      copyDateWithoutTime(lastEntryBeforeBeginning.dateTime);

  int differenceInDays =
      firstEntryDateTime.difference(lastEntryDateTime).inDays;
  double differenceInWeight =
      firstEntryAfterBeginning.weight - lastEntryBeforeBeginning.weight;
  int differenceInDaysFromBeginning =
      beginningDate.difference(lastEntryDateTime).inDays;
  double weightChangeFromLastEntry =
      (differenceInWeight * differenceInDaysFromBeginning) / differenceInDays;
  double estimatedWeight =
      lastEntryBeforeBeginning.weight + weightChangeFromLastEntry;
  return estimatedWeight;
}
