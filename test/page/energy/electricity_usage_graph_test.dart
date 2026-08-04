// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_test/flutter_test.dart';
import 'package:watermeter/model/xidian_ids/energy.dart';
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
}
