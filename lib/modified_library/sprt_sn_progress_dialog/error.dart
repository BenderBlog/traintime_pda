/*
Copyright (c) 2021 Aydın Emre Esen, 2022 SuperBart

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

/// Modified version of sn_progress_dialog https://github.com/emreesen27/Flutter-Progress-Dialog
/// I am not sure whether it needs a pull_request.
import 'package:flutter/material.dart';

/// Not to be confused with Error class in the Dart Core Library.
class ErrorSignal {
  /// [closedDelay] The time the dialog window will wait to close
  // (Default: 1500 ms)
  final int closedDelay;

  /// [completedImage] The default does not contain any value, if the value is assigned another asset image is created.
  final AssetImage? errorImage;

  ErrorSignal({
    this.closedDelay = 1500,
    this.errorImage,
  });
}
