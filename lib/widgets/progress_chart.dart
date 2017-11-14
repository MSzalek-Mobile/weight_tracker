import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';
import 'package:weight_tracker/model/weight_entry.dart';

class ProgressChart extends StatelessWidget {
  static const int NUMBER_OF_DAYS = 31;
  final List<WeightEntry> entries;

  ProgressChart(this.entries);

  @override
  Widget build(BuildContext context) {
    return new CustomPaint(
      painter: new ChartPainter(_prepareEntryList(entries)),
    );
  }

  List<WeightEntry> _prepareEntryList(List<WeightEntry> initialEntries) {
    DateTime beginningDate = _getStartDateOfChart();
    List<WeightEntry> entries = initialEntries
        .where((entry) => entry.dateTime.isAfter(beginningDate))
        .toList();
    if (_isMissingEntryFromBeginningDate(beginningDate, entries) &&
        _isAnyEntryBeforeBeginningDate(beginningDate, initialEntries)) {
      _addFakeEntryOnTheChartBeginning(initialEntries, entries, beginningDate);
    }
    return entries;
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

  bool _isMissingEntryFromBeginningDate(DateTime beginningDate,
      List<WeightEntry> entries) {
    return !entries.any((entry) =>
    entry.dateTime.day == beginningDate.day &&
        entry.dateTime.month == beginningDate.month &&
        entry.dateTime.year == beginningDate.year);
  }

  bool _isAnyEntryBeforeBeginningDate(DateTime beginningDate,
      List<WeightEntry> entries) {
    return entries.any((entry) => entry.dateTime.isBefore(beginningDate));
  }

  double _calculateWeightOnBeginningDate(WeightEntry lastEntryBeforeBeginning,
      WeightEntry firstEntryAfterBeginning, DateTime beginningDate) {
    DateTime firstEntryDateTime =
    _copyDateWithoutTime(firstEntryAfterBeginning.dateTime);
    DateTime lastEntryDateTime =
    _copyDateWithoutTime(lastEntryBeforeBeginning.dateTime);

    int differenceInDays =
        firstEntryDateTime
            .difference(lastEntryDateTime)
            .inDays;
    double differenceInWeight =
        firstEntryAfterBeginning.weight - lastEntryBeforeBeginning.weight;
    int differenceInDaysFromBeginning =
        beginningDate
            .difference(lastEntryDateTime)
            .inDays;
    double weightChangeFromLastEntry =
        (differenceInWeight * differenceInDaysFromBeginning) / differenceInDays;
    double estimatedWeight =
        lastEntryBeforeBeginning.weight + weightChangeFromLastEntry;
    return estimatedWeight;
  }

  DateTime _copyDateWithoutTime(DateTime dateTime) {
    return new DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
  }
}

class ChartPainter extends CustomPainter {
  final List<WeightEntry> entries;

  ChartPainter(this.entries);

  double leftOffsetStart;
  double topOffsetEnd;
  double drawingWidth;
  double drawingHeight;

  static const int NUMBER_OF_HORIZONTAL_LINES = 5;

  @override
  void paint(Canvas canvas, Size size) {
    leftOffsetStart = size.width * 0.05;
    topOffsetEnd = size.height * 0.9;
    drawingWidth = size.width * 0.95;
    drawingHeight = topOffsetEnd;

    if (entries.isNotEmpty) {
      Tuple2<int, int> borderLineValues = _getMinAndMaxValues(entries);
      _drawHorizontalLinesAndLabels(
          canvas, size, borderLineValues.item1, borderLineValues.item2);
      _drawBottomLabels(canvas, size);

      _drawLines(canvas, borderLineValues.item1, borderLineValues.item2);
    } else {
      //TODO: I think it should be handled at higher level
    }
  }

  @override
  bool shouldRepaint(ChartPainter old) => true;

  ///draws actual chart
  void _drawLines(ui.Canvas canvas, int minLineValue, int maxLineValue) {
    final paint = new Paint()
      ..color = Colors.blue[400]
      ..strokeWidth = 3.0;
    DateTime beginningOfChart = _getStartDateOfChart();
    for (int i = 0; i < entries.length - 1; i++) {
      Offset startEntryOffset = _getEntryOffset(
          entries[i], beginningOfChart, minLineValue, maxLineValue);
      Offset endEntryOffset = _getEntryOffset(
          entries[i + 1], beginningOfChart, minLineValue, maxLineValue);
      canvas.drawLine(startEntryOffset, endEntryOffset, paint);
      canvas.drawCircle(endEntryOffset, 3.0, paint);
    }
    canvas.drawCircle(
        _getEntryOffset(
            entries.first, beginningOfChart, minLineValue, maxLineValue),
        5.0,
        paint);
  }

  /// Draws horizontal lines and labels informing about weight values attached to those lines
  void _drawHorizontalLinesAndLabels(Canvas canvas, Size size, int minLineValue,
      int maxLineValue) {
    final paint = new Paint()
      ..color = Colors.grey[300];
    int lineStep = _calculateHorizontalLineStep(maxLineValue, minLineValue);
    double offsetStep = _calculateHorizontalOffsetStep;
    for (int line = 0; line < NUMBER_OF_HORIZONTAL_LINES; line++) {
      double yOffset = line * offsetStep;
      _drawHorizontalLabel(maxLineValue, line, lineStep, canvas, yOffset);
      _drawHorizontalLine(canvas, yOffset, size, paint);
    }
  }

  void _drawHorizontalLine(ui.Canvas canvas, double yOffset, ui.Size size,
      ui.Paint paint) {
    canvas.drawLine(
      new Offset(leftOffsetStart, 5 + yOffset),
      new Offset(size.width, 5 + yOffset),
      paint,
    );
  }

  void _drawHorizontalLabel(int maxLineValue, int line, int lineStep,
      ui.Canvas canvas, double yOffset) {
    ui.Paragraph paragraph =
    _buildParagraphForLeftLabel(maxLineValue, line, lineStep);
    canvas.drawParagraph(
      paragraph,
      new Offset(0.0, yOffset),
    );
  }

  /// Calculates offset difference between horizontal lines.
  ///
  /// e.g. between every line should be 100px space.
  double get _calculateHorizontalOffsetStep {
    return drawingHeight / (NUMBER_OF_HORIZONTAL_LINES - 1);
  }

  /// Calculates weight difference between horizontal lines.
  ///
  /// e.g. every line should increment weight by 5
  int _calculateHorizontalLineStep(int maxLineValue, int minLineValue) {
    return (maxLineValue - minLineValue) ~/ (NUMBER_OF_HORIZONTAL_LINES - 1);
  }

  void _drawBottomLabels(Canvas canvas, Size size) {
    for (int daysFromStart = ProgressChart.NUMBER_OF_DAYS;
    daysFromStart >= 0;
    daysFromStart -= 7) {
      double offsetXbyDay = drawingWidth / (ProgressChart.NUMBER_OF_DAYS);
      double offsetX = leftOffsetStart + offsetXbyDay * daysFromStart;
      ui.Paragraph paragraph = _buildParagraphForBottomLabel(daysFromStart);
      canvas.drawParagraph(
        paragraph,
        new Offset(offsetX - 50.0, 10.0 + drawingHeight),
      );
    }
  }

  ///Builds paragraph for label placed on the bottom (dates)
  ui.Paragraph _buildParagraphForBottomLabel(int daysFromStart) {
    ui.ParagraphBuilder builder = new ui.ParagraphBuilder(
        new ui.ParagraphStyle(fontSize: 10.0, textAlign: TextAlign.right))
      ..pushStyle(new ui.TextStyle(color: Colors.black))
      ..addText(new DateFormat('d MMM').format(new DateTime.now().subtract(
          new Duration(days: ProgressChart.NUMBER_OF_DAYS - daysFromStart))));
    final ui.Paragraph paragraph = builder.build()
      ..layout(new ui.ParagraphConstraints(width: 50.0));
    return paragraph;
  }

  ///Builds text paragraph for label placed on the left side of a chart (weights)
  ui.Paragraph _buildParagraphForLeftLabel(int maxLineValue, int line,
      int lineStep) {
    ui.ParagraphBuilder builder = new ui.ParagraphBuilder(
      new ui.ParagraphStyle(
        fontSize: 10.0,
        textAlign: TextAlign.right,
      ),
    )
      ..pushStyle(new ui.TextStyle(color: Colors.black))
      ..addText((maxLineValue - line * lineStep).toString());
    final ui.Paragraph paragraph = builder.build()
      ..layout(new ui.ParagraphConstraints(width: leftOffsetStart - 4));
    return paragraph;
  }

  ///Produces minimal and maximal value of horizontal line that will be displayed
  Tuple2<int, int> _getMinAndMaxValues(List<WeightEntry> entries) {
    double maxWeight = entries.map((entry) => entry.weight).reduce(math.max);
    double minWeight = entries.map((entry) => entry.weight).reduce(math.min);

    int maxLineValue = maxWeight.ceil();
    int difference = maxLineValue - minWeight.floor();
    int toSubtract = (NUMBER_OF_HORIZONTAL_LINES - 1) -
        (difference % (NUMBER_OF_HORIZONTAL_LINES - 1));
    if (toSubtract == NUMBER_OF_HORIZONTAL_LINES - 1) {
      toSubtract = 0;
    }
    int minLineValue = minWeight.floor() - toSubtract;

    return new Tuple2(minLineValue, maxLineValue);
  }

  /// Calculates offset at which given entry should be painted
  Offset _getEntryOffset(WeightEntry entry, DateTime beginningOfChart,
      int minLineValue, int maxLineValue) {
    int daysFromBeginning = entry.dateTime
        .difference(beginningOfChart)
        .inDays;
    double relativeXposition = daysFromBeginning / ProgressChart.NUMBER_OF_DAYS;
    double xOffset = leftOffsetStart + relativeXposition * drawingWidth;
    double relativeYposition =
        (entry.weight - minLineValue) / (maxLineValue - minLineValue);
    double yOffset = 5 + drawingHeight - relativeYposition * drawingHeight;
    return new Offset(xOffset, yOffset);
  }
}

DateTime _getStartDateOfChart() {
  DateTime now = new DateTime.now();
  DateTime beginningOfChart = now.subtract(new Duration(
      days: ProgressChart.NUMBER_OF_DAYS,
      hours: now.hour,
      minutes: now.minute));
  return beginningOfChart;
}
