import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:watermeter/wearos/slider_captcha.dart';

void main() {
  group('Go-compatible IDS slider captcha', () {
    test('solves slide offset using the Go cross-correlation algorithm', () {
      final puzzleBytes = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAABAAAAAECAYAAACHtL/sAAAA70lEQVR4nB3OQQfCAACA0RHRrFtEh93GWIwOMRo7LRazbh1GdNsYo+MYo+PotGN02rFrx64dO8WOO40dY8QOX/QHnieMx2NkWUbXdSzLYrvdcjgcOB6PnE4niqKgLEvu9zvP55Oqqmjblr7vkSQJYT6fY5omruuy3++J45gsyxBFkclk8sdVVeX9ftM0Dd/vl9FoxGw2Q9M0hM1mg+/7RFFEmqacz2eu1yuLxYLVaoVt23ieR9d1DIdDptPpHzQMA8dxEMIwJEkS8jzncrlwu914PB68Xi/quubz+TAYDP4bRVFYLpes12t2ux1BEPADQTaOsaGO5RAAAAAASUVORK5CYII=',
      );
      final pieceBytes = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAYAAAAECAYAAACtBE5DAAAAM0lEQVR4nGNgwAe4uLj+i4iI/JeTk/uvoaHxHy5hZGT038bG5r+bm9v/gICA/3jMYGAAADvqDDHTarfFAAAAAElFTkSuQmCC',
      );

      expect(
        SliderCaptchaClientProvider.solveSlideOffsetForTesting(
          puzzleBytes: puzzleBytes,
          pieceBytes: pieceBytes,
          border: 0,
        ),
        5,
      );
    });

    test('encrypts captcha payload with the Go fixed-prefix AES-CBC shape', () {
      final key = Uint8List.fromList('1234567890abcdef'.codeUnits);
      const payload =
          '{"canvasLength":280,"moveLength":42,"tracks":[{"a":0,"b":0,"c":0},{"a":42,"b":0,"c":900}]}';

      expect(
        SliderCaptchaClientProvider.encryptCaptchaPayloadForTesting(
          payload,
          key,
        ),
        'Y2fkMlmY/KyUHnWiA9lVrnC8HHWUFePOo/JLpbpV/XfZ/zE6Tk2WrZMyCYY1f9ael+nb8OZB4B2EmFM6G18SWMo6nGxXZr4TTOiHUUTFXkeQQVaF2RoG1CsaDxyrQkchEx7YVCH+3fSUlX8CKpybb7jJnIbccr2rP1538MId2OLPck1g1XaCwAOtLK+LyyKILKYdFAT061XHTpBZZfvJOg==',
      );
    });
  });
}
