import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';
import 'package:weight_tracker/logic/actions.dart';
import 'package:weight_tracker/logic/redux_state.dart';
import 'package:weight_tracker/model/weight_entry.dart';
import 'package:weight_tracker/widgets/progress_chart_utils.dart' as utils;

class ProgressChartViewModel {
  final List<WeightEntry> entriesToShow;
  final int daysToShow;
  final int previousDaysToShow;
  final Function(int) changeDaysToShow;
  final Function() snapShotDaysToShow;
  final Function() endGesture;

  ProgressChartViewModel({this.entriesToShow,
    this.daysToShow,
    this.previousDaysToShow,
    this.changeDaysToShow,
    this.snapShotDaysToShow,
    this.endGesture,});
}

class ProgressChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, ProgressChartViewModel>(
      converter: (store) {
        int daysToShow = store.state.progressChartState.daysToShow;
        return new ProgressChartViewModel(
          entriesToShow: utils.prepareEntryList(
              store.state.entries, new DateTime.now(), daysToShow),
          daysToShow: daysToShow,
          previousDaysToShow: store.state.progressChartState.previousDaysToShow,
          snapShotDaysToShow: () => store.dispatch(new SnapShotDaysToShow()),
          changeDaysToShow: (days) =>
              store.dispatch(new ChangeDaysToShowOnChart(days)),
          endGesture: () => store.dispatch(new EndGestureOnProgress()),
        );
      },
      builder: (BuildContext context, ProgressChartViewModel viewModel) {
        //print("Total: " + viewModel.daysToShow.toString());
        return new GestureDetector(
          onScaleStart: (details) {
            viewModel.snapShotDaysToShow();
            print("Start " + viewModel.daysToShow.toString() + " " + viewModel
                .previousDaysToShow.toString());
          },
          onScaleUpdate: (ScaleUpdateDetails scaleDetails) {
            int newNumberOfDays = (viewModel.previousDaysToShow / scaleDetails
                .scale).round();
            if (newNumberOfDays >= 8) {
              viewModel.changeDaysToShow(newNumberOfDays);
            }
            print("update " + viewModel.daysToShow.toString() + " " + viewModel
                .previousDaysToShow.toString());
          },
          onScaleEnd: (details) {
            viewModel.endGesture();
            this.build(context);
            print("end " + viewModel.daysToShow.toString() + " " + viewModel
                .previousDaysToShow.toString());
          },
          child: new CustomPaint(
            painter: new ChartPainter(
                utils.prepareEntryList(viewModel.entriesToShow,
                    new DateTime.now(), viewModel.daysToShow),
                viewModel.daysToShow),
          ),
        );
      },
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<WeightEntry> entries;
  final int numberOfDays;

  ChartPainter(this.entries, this.numberOfDays);

  double leftOffsetStart;
  double topOffsetEnd;
  double drawingWidth;
  double drawingHeight;

  static const int NUMBER_OF_HORIZONTAL_LINES = 5;

  @override
  void paint(Canvas canvas, Size size) {
    leftOffsetStart = size.width * 0.07;
    topOffsetEnd = size.height * 0.9;
    drawingWidth = size.width * 0.93;
    drawingHeight = topOffsetEnd;

    if (entries.isEmpty) {
      _drawParagraphInsteadOfChart(
          canvas, size, "Add your current weight to see history");
    } else {
      Tuple2<int, int> borderLineValues = _getMinAndMaxValues(entries);
      _drawHorizontalLinesAndLabels(
          canvas, size, borderLineValues.item1, borderLineValues.item2);
      _drawBottomLabels(canvas, size);

      _drawLines(canvas, borderLineValues.item1, borderLineValues.item2);
    }
  }

  @override
  bool shouldRepaint(ChartPainter old) => true;

  ///draws actual chart
  void _drawLines(ui.Canvas canvas, int minLineValue, int maxLineValue) {
    final paint = new Paint()
      ..color = Colors.blue[400]
      ..strokeWidth = 3.0;
    DateTime beginningOfChart =
    utils.getStartDateOfChart(new DateTime.now(), numberOfDays);
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
    for (int daysFromStart = numberOfDays;
    daysFromStart > 0;
    daysFromStart = (daysFromStart - (numberOfDays / 4)).round()) {
      double offsetXbyDay = drawingWidth / numberOfDays;
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
      ..addText(new DateFormat('d MMM').format(new DateTime.now()
          .subtract(new Duration(days: numberOfDays - daysFromStart))));
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

    int maxLineValue;
    int minLineValue;

    if (maxWeight == minWeight) {
      maxLineValue = maxWeight.ceil() + 1;
      minLineValue = maxLineValue - 4;
    } else {
      maxLineValue = maxWeight.ceil();
      int difference = maxLineValue - minWeight.floor();
      int toSubtract = (NUMBER_OF_HORIZONTAL_LINES - 1) -
          (difference % (NUMBER_OF_HORIZONTAL_LINES - 1));
      if (toSubtract == NUMBER_OF_HORIZONTAL_LINES - 1) {
        toSubtract = 0;
      }
      minLineValue = minWeight.floor() - toSubtract;
    }
    return new Tuple2(minLineValue, maxLineValue);
  }

  /// Calculates offset at which given entry should be painted
  Offset _getEntryOffset(WeightEntry entry, DateTime beginningOfChart,
      int minLineValue, int maxLineValue) {
    int daysFromBeginning = entry.dateTime
        .difference(beginningOfChart)
        .inDays;
    double relativeXposition = daysFromBeginning / numberOfDays;
    double xOffset = leftOffsetStart + relativeXposition * drawingWidth;
    double relativeYposition =
        (entry.weight - minLineValue) / (maxLineValue - minLineValue);
    double yOffset = 5 + drawingHeight - relativeYposition * drawingHeight;
    return new Offset(xOffset, yOffset);
  }

  _drawParagraphInsteadOfChart(ui.Canvas canvas, ui.Size size, String text) {
    double fontSize = 14.0;
    ui.ParagraphBuilder builder = new ui.ParagraphBuilder(
      new ui.ParagraphStyle(
        fontSize: fontSize,
        textAlign: TextAlign.center,
      ),
    )
      ..pushStyle(new ui.TextStyle(color: Colors.black))
      ..addText(text);
    final ui.Paragraph paragraph = builder.build()
      ..layout(new ui.ParagraphConstraints(width: size.width));

    canvas.drawParagraph(
        paragraph, new Offset(0.0, size.height / 2 - fontSize));
  }
}
