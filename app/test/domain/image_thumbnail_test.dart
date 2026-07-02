import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:didiodidi/domain/image_thumbnail.dart';

Uint8List _pngBytes(int width, int height) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(200, 50, 50));
  return Uint8List.fromList(img.encodePng(image));
}

void main() {
  group('encodeThumbnailDataUri', () {
    test('returns a valid data:image/jpeg;base64 URI', () {
      final uri = encodeThumbnailDataUri(_pngBytes(800, 400));
      expect(
        RegExp(r'^data:image/jpeg;base64,').hasMatch(uri),
        isTrue,
        reason: uri.substring(0, 40),
      );
    });

    test('downscales so the longest edge is exactly 500px', () {
      final uri = encodeThumbnailDataUri(_pngBytes(2000, 1000));
      final b64 = uri.split(',')[1];
      final decoded = img.decodeJpg(base64Decode(b64))!;
      expect(decoded.width, 500);
      expect(decoded.height, 250);
    });

    test('downscales a tall image so height becomes 500px', () {
      final uri = encodeThumbnailDataUri(_pngBytes(600, 1200));
      final b64 = uri.split(',')[1];
      final decoded = img.decodeJpg(base64Decode(b64))!;
      expect(decoded.height, 500);
      expect(decoded.width, 250);
    });

    test('does not upscale images already smaller than the target', () {
      final uri = encodeThumbnailDataUri(_pngBytes(100, 50));
      final b64 = uri.split(',')[1];
      final decoded = img.decodeJpg(base64Decode(b64))!;
      expect(decoded.width, 100);
      expect(decoded.height, 50);
    });

    test('throws ThumbnailEncodingException for garbage bytes', () {
      expect(
        () => encodeThumbnailDataUri(Uint8List.fromList([1, 2, 3, 4])),
        throwsA(isA<ThumbnailEncodingException>()),
      );
    });
  });
}
