// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:watermeter/repository/single_flight.dart';

void main() {
  group('SingleFlight', () {
    test('shares one in-flight operation between concurrent callers', () async {
      final completer = Completer<int>();
      final flight = SingleFlight<int>();
      var callCount = 0;

      Future<int> action() {
        callCount++;
        return completer.future;
      }

      final first = flight.run(action);
      final second = flight.run(action);

      expect(identical(first, second), isTrue);
      expect(callCount, 1);
      expect(flight.isRunning, isTrue);

      completer.complete(42);

      expect(await Future.wait([first, second]), [42, 42]);
      expect(flight.isRunning, isFalse);
    });

    test('starts a new operation after completion', () async {
      final flight = SingleFlight<int>();
      var callCount = 0;

      Future<int> action() async => ++callCount;

      expect(await flight.run(action), 1);
      expect(await flight.run(action), 2);
    });

    test('clears the operation after an asynchronous error', () async {
      final flight = SingleFlight<int>();
      var callCount = 0;

      Future<int> action() async {
        callCount++;
        throw StateError('failed');
      }

      await expectLater(flight.run(action), throwsStateError);
      await expectLater(flight.run(action), throwsStateError);
      expect(callCount, 2);
    });

    test('converts a synchronous throw into a Future error', () async {
      final flight = SingleFlight<int>();

      await expectLater(
        flight.run(() => throw StateError('failed synchronously')),
        throwsStateError,
      );
      expect(flight.isRunning, isFalse);
    });
  });
}
