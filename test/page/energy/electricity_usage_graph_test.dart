// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_test/flutter_test.dart';
import 'package:watermeter/model/xidian_ids/energy.dart';
import 'package:watermeter/page/energy/electricity_average_usage_graph.dart';
import 'package:watermeter/page/energy/electricity_usage_graph.dart';

void main() {
  const graphHeight = 200.0;
  const graphWidth = 320.0;
  const plotTop = 10.0;
  const plotBottom = graphHeight - 30.0;

  ElectricityHistoryInfo history(int day, double remain) {
    return ElectricityHistoryInfo(
      fetchDay: DateTime(2026, 8, day),
      remain: remain.toString(),
    );
  }

  MeterInfo meterRow({
    required DateTime time,
    required double start,
    required double end,
  }) {
    return MeterInfo(
      ReadTime: time,
      ReadNum: end - start,
      StartNum: start,
      EndNum: end,
    );
  }

  test('keeps points in bounds when electricity balance crosses zero', () {
    final graph = ElectricityUsageGraph(
      historyElectricityInfo: [history(1, -10), history(2, 20)],
      graphHeight: graphHeight,
      graphWidth: graphWidth,
    );

    expect(
      graph.points.map((point) => point.dy),
      everyElement(inInclusiveRange(plotTop, plotBottom)),
    );
    expect(graph.points.first.dy, greaterThan(graph.points.last.dy));
    expect(graph.lines, contains(0));
  });

  test('keeps points in bounds when all electricity balances are negative', () {
    final graph = ElectricityUsageGraph(
      historyElectricityInfo: [history(1, -120), history(2, -80)],
      graphHeight: graphHeight,
      graphWidth: graphWidth,
    );

    expect(
      graph.points.map((point) => point.dy),
      everyElement(inInclusiveRange(plotTop, plotBottom)),
    );
    expect(graph.points.first.dy, greaterThan(graph.points.last.dy));
    expect(graph.lines, contains(0));
  });

  test('gives a flat negative balance a visible range around zero', () {
    final graph = ElectricityUsageGraph(
      historyElectricityInfo: [history(1, -80), history(2, -80)],
      graphHeight: graphHeight,
      graphWidth: graphWidth,
    );

    expect(
      graph.points.map((point) => point.dy),
      everyElement(inInclusiveRange(plotTop, plotBottom)),
    );
    expect(graph.lines, contains(0));
  });

  test('sums multiple readings on the same day', () {
    final graph = ElectricityAverageUsageGraph(
      graphWidth: graphWidth,
      historyElectricityInfo: [
        meterRow(time: DateTime(2026, 8, 1, 2), start: 100, end: 103),
        meterRow(time: DateTime(2026, 8, 1, 14), start: 103, end: 105),
        meterRow(time: DateTime(2026, 8, 2, 2), start: 105, end: 108),
      ],
    );
    final result = graph.plotData;

    expect(result, hasLength(2));
    expect(result[0].date, DateTime(2026, 8, 1));
    expect(result[0].usage, 5);
    expect(result[1].usage, 3);
  });

  test('keeps signed corrections and ignores exact duplicate readings', () {
    final graph = ElectricityAverageUsageGraph(
      graphWidth: graphWidth,
      historyElectricityInfo: [
        meterRow(time: DateTime(2026, 8, 1, 2), start: 100, end: 103),
        meterRow(time: DateTime(2026, 8, 1, 3), start: 100, end: 103),
        meterRow(time: DateTime(2026, 8, 1, 4), start: 103, end: 100),
      ],
    );
    final result = graph.plotData;

    expect(result, hasLength(1));
    expect(result.single.usage, 0);
  });

  test('keeps a zero-usage day and normalizes read time to a calendar day', () {
    final graph = ElectricityAverageUsageGraph(
      graphWidth: graphWidth,
      historyElectricityInfo: [
        meterRow(time: DateTime(2026, 8, 1, 2, 10), start: 100, end: 100),
      ],
    );
    final result = graph.plotData;

    expect(result, hasLength(1));
    expect(result.single.date, DateTime(2026, 8, 1));
    expect(result.single.usage, 0);
  });
}
