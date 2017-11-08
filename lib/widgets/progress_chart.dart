import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';
import 'package:weight_tracker/model/weight_entry.dart';

class ProgressChart extends StatelessWidget {
  final List<WeightEntry> entries;

  ProgressChart(this.entries);

  @override
  Widget build(BuildContext context) {
    return new CustomPaint(
      painter: new ChartPainter(entries
          .where((entry) => entry.dateTime
              .isAfter(new DateTime.now().subtract(new Duration(days: 31))))
          .toList()),
    );
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
  static const int NUMBER_OF_DAYS = 31;

  @override
  void paint(Canvas canvas, Size size) {
    leftOffsetStart = size.width * 0.05;
    topOffsetEnd = size.height * 0.9;
    drawingWidth = size.width * 0.95;
    drawingHeight = topOffsetEnd;
    //entries.removeWhere((entry) => entries.any((entry1) => entry1.dateTime.))

    Tuple2<int, int> borderLineValues = _getMinAndMaxValues(entries);

    _drawHorizontalLinesAndLabels(
        canvas, size, borderLineValues.item1, borderLineValues.item2);
    _drawBottomLabels(canvas, size);

    _drawLines(canvas, borderLineValues.item1, borderLineValues.item2);
  }

  void _drawLines(ui.Canvas canvas, int minLineValue, int maxLineValue) {
    final paint = new Paint()
      ..color = Colors.blue[400]
      ..strokeWidth = 3.0;
    DateTime beginningOfChart =
    new DateTime.now().subtract(new Duration(days: NUMBER_OF_DAYS));
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

  @override
  bool shouldRepaint(ChartPainter old) => true;

  void _drawHorizontalLinesAndLabels(Canvas canvas, Size size, int minLineValue,
      int maxLineValue) {
    final paint = new Paint()
      ..color = Colors.grey[300];
    int lineStep =
        (maxLineValue - minLineValue) ~/ (NUMBER_OF_HORIZONTAL_LINES - 1);
    double offsetStep = drawingHeight / (NUMBER_OF_HORIZONTAL_LINES - 1);
    for (int line = 0; line < NUMBER_OF_HORIZONTAL_LINES; line++) {
      double yOffset = line * offsetStep;
      ui.Paragraph paragraph =
      _buildParagraphForLeftLabel(maxLineValue, line, lineStep);
      canvas.drawParagraph(paragraph, new Offset(0.0, yOffset));
      canvas.drawLine(new Offset(leftOffsetStart, 5 + yOffset),
          new Offset(size.width, 5 + yOffset), paint);
    }
  }

  void _drawBottomLabels(Canvas canvas, Size size) {
    for (int line = 30; line >= 0; line -= 7) {
      double offsetX = leftOffsetStart + (drawingWidth / 30) * line;
      ui.Paragraph paragraph = _buildParagraphForBottomLabel(line);
      canvas.drawParagraph(
          paragraph, new Offset(offsetX - 50.0, 10.0 + drawingHeight));
    }
  }

  ui.Paragraph _buildParagraphForBottomLabel(int line) {
    ui.ParagraphBuilder builder = new ui.ParagraphBuilder(
        new ui.ParagraphStyle(fontSize: 10.0, textAlign: TextAlign.right))
      ..pushStyle(new ui.TextStyle(color: Colors.black))
      ..addText(new DateFormat('d MMM')
          .format(new DateTime.now().subtract(new Duration(days: 30 - line))));
    final ui.Paragraph paragraph = builder.build()
      ..layout(new ui.ParagraphConstraints(width: 50.0));
    return paragraph;
  }

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

  Offset _getEntryOffset(WeightEntry entry, DateTime beginningOfChart,
      int minLineValue, int maxLineValue) {
    int daysFromBeginning = entry.dateTime
        .difference(beginningOfChart)
        .inDays;
    double xOffset = leftOffsetStart +
        daysFromBeginning / (NUMBER_OF_DAYS - 1) * drawingWidth;
    double relativeYposition =
        (entry.weight - minLineValue) / (maxLineValue - minLineValue);
    double yOffset = 5 + drawingHeight - relativeYposition * drawingHeight;
    return new Offset(xOffset, yOffset);
  }
}
