// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/electricity.dart';
import 'package:watermeter/repository/logger.dart';

class ElectricityUsageGraph extends StatelessWidget {
  final List<ElectricityInfo> historyElectricityInfo;
  late final SplayTreeMap<DateTime, double> data;
  final double graphHeight;
  final double graphWidth;
  ElectricityUsageGraph({
    super.key,
    required this.historyElectricityInfo,
    required this.graphHeight,
    required this.graphWidth,
  }) {
    data = SplayTreeMap();
    // Parsing number, store the latest data.
    // Notice that the historyElectricityInfo have sorted.
    for (final info in historyElectricityInfo) {
      final v = double.tryParse(info.remain);
      if (v == null) continue;

      final dayTime = DateTime(
        info.fetchDay.year,
        info.fetchDay.month,
        info.fetchDay.day,
      );
      // If historyElectricityInfo have not sorted,
      // This line should be rewrite to ensure that the
      // latest data have been fetched.
      data[dayTime] = v;
    }

    log.info("[ElectricityWindow][ElectricityUsageGraph] Based on $data");
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      log.info(
        "[ElectricityWindow][ElectricityUsageGraph] "
        "Not enough data, quit!",
      );

      return Text(
        FlutterI18n.translate(context, "electricity.not_enough_data"),
        textAlign: TextAlign.center,

        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ).width(double.infinity);
    }

    return GestureDetector(
      onTapDown: (details) {
        // 获取点击相对于画布左上角的坐标
        final Offset localPosition = details.localPosition;
        print(localPosition);
      },
      child: RepaintBoundary(
        child: CustomPaint(
          painter: LineChartPainter(data: data),
          child: RepaintBoundary(
            child: SizedBox(width: graphWidth, height: graphHeight),
          ),
        ),
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final SplayTreeMap<DateTime, double> data;
  late final Paint _strokePaint;
  late final Paint _dotPaint;

  LineChartPainter({required this.data}) {
    _strokePaint = Paint()
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    _dotPaint = Paint()
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round;
  }

  List<Offset> _getOffsets(Size size) {
    // Horizontal Step
    int step = data.keys.last.difference(data.keys.first).inDays + 2;
    final horizontalStep = size.width / step;
    log.info(
      "[SelfGraph] horizontalstep $horizontalStep, from width ${size.width} and step $step",
    );

    // Vertical Step
    // Point's initial point is at the upper left corner
    double minY = size.height;
    double maxY = 20;
    double biggestValue = data.values.reduce((a, b) => a > b ? a : b);
    double smallestValue = data.values.reduce((a, b) => a > b ? b : a);
    double verticalStep = (biggestValue - smallestValue) / (minY - maxY);
    log.info(
      "[SelfGraph] verticalstep $verticalStep, "
      "from ($biggestValue - $smallestValue) / (${minY - maxY}), "
      "height ${size.height}",
    );

    // List of Points based on horizontal and vertical step
    return data.keys.map<Offset>((k) {
      return Offset(
        horizontalStep * (k.difference(data.keys.first).inDays + 1),
        size.height - (data[k]! - smallestValue) / verticalStep,
      );
    }).toList();
  }

  Path _getPath(List<Offset> points) {
    if (data.isEmpty) return Path();

    // Calculate Paths
    final path = Path()..moveTo(points.first.dx, points.first.dy);

    // At least four points is required to paint the curve
    if (points.length < 2) {
    } else if (points.length < 3) {
      path.lineTo(points.last.dx, points.last.dy);
    } else {
      // CatmullRomSpline require at least 4 dots, copy the head and tail dots.
      if (points.length == 3) {
        points.insert(0, points.first);
        points.add(points.last);
      }

      // AI-generated how to paint Catmull-Rom splines with Flutter
      final spline = CatmullRomSpline(points, tension: 0.0);
      final List<Curve2DSample> samples = spline.generateSamples().toList();
      if (samples.isNotEmpty) {
        path.moveTo(samples.first.value.dx, samples.first.value.dy);
        for (var sample in samples.skip(1)) {
          path.lineTo(sample.value.dx, sample.value.dy);
        }
      }
    }

    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    //final strokeWidth = 2.0;
    final chartSize = Size(size.width, size.height);
    final points = _getOffsets(chartSize);
    final path = _getPath(points);

    //if (gradient) {
    //  final fillPath = Path.from(path);
    //  fillPath.lineTo(size.width, size.height + strokeWidth * 2);
    //  fillPath.lineTo(0, size.height + strokeWidth * 2);
    //  fillPath.close();
    //
    //  _fillPaint.shader = _getShader(size);
    //  canvas.drawPath(fillPath, _fillPaint);
    //}

    canvas.drawPath(path, _strokePaint);
    canvas.drawPoints(PointMode.points, points, _dotPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
