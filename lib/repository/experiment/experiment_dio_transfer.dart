// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR MIT

import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:charset_converter/charset_converter.dart';

/// The idea is just return bytes.
class ExperimentDioTransformer extends SyncTransformer {
  @override
  Future<dynamic> transformResponse(
    RequestOptions options,
    ResponseBody responseBody,
  ) async {
    final showDownloadProgress = options.onReceiveProgress != null;
    final int totalLength;
    if (showDownloadProgress) {
      totalLength = int.parse(
        responseBody.headers[Headers.contentLengthHeader]?.first ?? '-1',
      );
    } else {
      totalLength = 0;
    }

    int received = 0;
    final stream = responseBody.stream.transform<Uint8List>(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(data);
          if (showDownloadProgress) {
            received += data.length;
            options.onReceiveProgress?.call(received, totalLength);
          }
        },
      ),
    );

    final streamCompleter = Completer<void>();
    int finalLength = 0;
    // Keep references to the data chunks and concatenate them later.
    final chunks = <Uint8List>[];
    final subscription = stream.listen(
      (chunk) {
        finalLength += chunk.length;
        chunks.add(chunk);
      },
      onError: (Object error, StackTrace stackTrace) {
        streamCompleter.completeError(error, stackTrace);
      },
      onDone: () {
        streamCompleter.complete();
      },
      cancelOnError: true,
    );
    options.cancelToken?.whenCancel.then((_) {
      return subscription.cancel();
    });
    await streamCompleter.future;

    // Copy all chunks into the final bytes.
    final responseBytes = Uint8List(finalLength);
    int chunkOffset = 0;
    for (final chunk in chunks) {
      responseBytes.setAll(chunkOffset, chunk);
      chunkOffset += chunk.length;
    }

    String gbk = await CharsetConverter.availableCharsets().then(
        (value) => value.firstWhere((element) => element.contains("18030")));
    // For now, just return bytes.
    return await CharsetConverter.decode(gbk, responseBytes);
  }
}
