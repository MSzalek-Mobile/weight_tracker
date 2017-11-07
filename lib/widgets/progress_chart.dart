import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  @override
  void paint(Canvas canvas, Size size) {
    leftOffsetStart = size.width * 0.1;
    topOffsetEnd = size.height * 0.8;
    drawingWidth = size.width * 0.9;
    drawingHeight = topOffsetEnd;

    final paint = new Paint()
      ..color = Colors.blue[400]
      ..strokeWidth = 3.0
      ..style = PaintingStyle.fill;

    final helpLinePaint = new Paint()..color = Colors.grey[400];

    //entries.removeWhere((entry) => entries.any((entry1) => entry1.dateTime.))

    double maxWeight = entries.map((entry) => entry.weight).reduce(math.max);
    double minWeight = entries.map((entry) => entry.weight).reduce(math.min);

    drawHorizontalLines(canvas, size, helpLinePaint, minWeight, maxWeight);
    drawVerticalLines(canvas, size, helpLinePaint);

    for (int i = 0; i < entries.length - 1; i++) {
      int point1dayFromStart = entries[i]
          .dateTime
          .difference(new DateTime.now().subtract(new Duration(days: 31)))
          .inDays;
      double point1Xoffset =
          leftOffsetStart + point1dayFromStart / 30 * drawingWidth;
      double point1Yoffset = 5 +
          drawingHeight -
          ((entries[i].weight - minWeight) / (maxWeight - minWeight)) *
              drawingHeight;
      int point2dayFromStart = entries[i + 1]
          .dateTime
          .difference(new DateTime.now().subtract(new Duration(days: 31)))
          .inDays;
      double point2Xoffset =
          leftOffsetStart + point2dayFromStart / 30 * drawingWidth;
      double point2Yoffset = 5 +
          drawingHeight -
          ((entries[i + 1].weight - minWeight) / (maxWeight - minWeight)) *
              drawingHeight;
      canvas.drawLine(new Offset(point1Xoffset, point1Yoffset),
          new Offset(point2Xoffset, point2Yoffset), paint);
    }
  }

  @override
  bool shouldRepaint(ChartPainter old) => true;

  void drawHorizontalLines(Canvas canvas, Size size, Paint helpLinePaint,
      double minWeight, double maxWeight) {
    for (int line = 0; line < 11; line++) {
      ui.ParagraphBuilder builder = new ui.ParagraphBuilder(
          new ui.ParagraphStyle(fontSize: 8.0, textAlign: TextAlign.right))
        ..pushStyle(new ui.TextStyle(color: Colors.black))
        ..addText((minWeight + (maxWeight - minWeight) / 10 * (10 - line))
            .toInt()
            .toString());
      final ui.Paragraph paragraph = builder.build()
        ..layout(new ui.ParagraphConstraints(width: leftOffsetStart - 2));

      canvas.drawLine(
          new Offset(leftOffsetStart, 5 + drawingHeight * line * 0.1),
          new Offset(size.width, 5 + drawingHeight * line * 0.1),
          helpLinePaint);
      canvas.drawParagraph(
          paragraph, new Offset(0.0, drawingHeight * line * 0.1));
    }
  }

  void drawVerticalLines(Canvas canvas, Size size, Paint helpLinePaint) {
    for (int line = 0; line < 31; line++) {
      double offsetX = leftOffsetStart + (drawingWidth / 30) * line;

      //every week ending on today
      if ((30 - line) % 7 == 0) {
        // helpLinePaint.strokeWidth = helpLinePaint.strokeWidth*2;
        ui.ParagraphBuilder builder = new ui.ParagraphBuilder(
            new ui.ParagraphStyle(fontSize: 8.0, textAlign: TextAlign.right))
          ..pushStyle(new ui.TextStyle(color: Colors.black))
          ..addText(new DateFormat('d MMM').format(
              new DateTime.now().subtract(new Duration(days: 30 - line))));
        final ui.Paragraph paragraph = builder.build()
          ..layout(new ui.ParagraphConstraints(width: 50.0));
        canvas.drawParagraph(
            paragraph, new Offset(offsetX - 50.0, 10.0 + drawingHeight));
      }

      canvas.drawLine(new Offset(offsetX, 5.0),
          new Offset(offsetX, 5.0 + drawingHeight), helpLinePaint);
    }
  }
}
