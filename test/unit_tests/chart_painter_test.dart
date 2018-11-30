import 'dart:ui';

import 'package:mockito/mockito.dart';
import 'package:test_api/test_api.dart';
import 'package:weight_tracker/model/weight_entry.dart';
import 'package:weight_tracker/widgets/progress_chart.dart';

class MockCanvas extends Mock implements Canvas {}

void main() {
  test("Given empty list ChartPainter draws only Paragraph", () {
    //given
    MockCanvas mockCanvas = new MockCanvas();
    Size size = new Size(600.0, 600.0);
    ChartPainter chartPainter = new ChartPainter([], 30, true);
    //when
    chartPainter.paint(mockCanvas, size);
    //then
    verifyNever(mockCanvas.drawCircle(any, any, any));
    verifyNever(mockCanvas.drawLine(any, any, any));
    verify(mockCanvas.drawParagraph(any, any)).called(1);
  });

  ///There are 5 horizontal lines
  test("Given one value, ChartPainter draws 5 lines and 1 point", () {
    //given
    MockCanvas mockCanvas = new MockCanvas();
    Size size = new Size(600.0, 600.0);
    WeightEntry weightEntry = new WeightEntry(new DateTime.now(), 70.0, null);
    ChartPainter chartPainter = new ChartPainter([weightEntry], 30, true);
    //when
    chartPainter.paint(mockCanvas, size);
    //then
    verify(mockCanvas.drawCircle(any, any, any)).called(1);
    verify(mockCanvas.drawLine(any, any, any)).called(5);
  });

  test("Given two values, ChartPainter draws 6 lines and 2 points", () {
    //given
    MockCanvas mockCanvas = new MockCanvas();
    Size size = new Size(600.0, 600.0);
    DateTime now = new DateTime.now();
    WeightEntry weightEntry1 = new WeightEntry(now, 70.0, null);
    WeightEntry weightEntry2 =
        new WeightEntry(now.subtract(const Duration(days: 1)), 70.0, null);
    ChartPainter chartPainter =
    new ChartPainter([weightEntry1, weightEntry2], 30, true);
    //when
    chartPainter.paint(mockCanvas, size);
    //then
    verify(mockCanvas.drawCircle(any, any, any)).called(2);
    verify(mockCanvas.drawLine(any, any, any)).called(6);
  });
}
