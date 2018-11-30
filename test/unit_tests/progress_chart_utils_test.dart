import 'package:test_api/test_api.dart';
import 'package:weight_tracker/model/weight_entry.dart';
import 'package:weight_tracker/widgets/progress_chart_utils.dart' as utils;

void main() {
  test('general filtring list test', () {
    //given
    DateTime now = new DateTime.utc(2017, 1, 1, 8, 0);
    WeightEntry entry1 = new WeightEntry(now, 70.0, null);
    WeightEntry entry2 =
        new WeightEntry(now.subtract(new Duration(days: 6)), 70.0, null);
    WeightEntry entry3 =
        new WeightEntry(now.subtract(new Duration(days: 7)), 70.0, null);
    WeightEntry entry4 =
        new WeightEntry(now.subtract(new Duration(days: 8)), 70.0, null);
    int daysToShow = 7;
    List<WeightEntry> entries = [entry1, entry2, entry3, entry4];
    //when
    List<WeightEntry> newEntries =
        utils.prepareEntryList(entries, now.subtract(Duration(days: daysToShow-1)));
    //then
    expect(newEntries, contains(entry1));
    expect(newEntries, contains(entry2));
    expect(newEntries, isNot(contains(entry3)));
    expect(newEntries, isNot(contains(entry4)));
  });

  test('adds fake weight entry', () {
    //given
    int daysToShow = 2;
    DateTime now = new DateTime.utc(2017, 10, 10, 8, 0);
    WeightEntry firstEntryAfterBorder = new WeightEntry(now, 70.0, null);
    WeightEntry lastEntryBeforeBorder =
        new WeightEntry(now.subtract(new Duration(days: 2)), 90.0, null);
    List<WeightEntry> entries = [firstEntryAfterBorder, lastEntryBeforeBorder];
    //when
    List<WeightEntry> newEntries =
        utils.prepareEntryList(entries, now.subtract(Duration(days: daysToShow-1)));
    //then
    expect(newEntries, contains(firstEntryAfterBorder));
    expect(newEntries, isNot(contains(lastEntryBeforeBorder)));
    expect(
        newEntries,
        anyElement((WeightEntry entry) =>
            entry.weight == 80.0 && entry.dateTime.day == now.day - 1));
  });
}
