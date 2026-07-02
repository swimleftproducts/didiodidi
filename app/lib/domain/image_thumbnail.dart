// Downscales a full-res task photo into the thumbnail embedded in share
// snapshots. See CLAUDE.md Section 7 (share flow) / Section 3 (1.8MB ceiling).
import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

const kThumbnailLongestEdge = 500;
const kThumbnailJpegQuality = 60;

class ThumbnailEncodingException implements Exception {
  final String message;
  ThumbnailEncodingException(this.message);

  @override
  String toString() => 'ThumbnailEncodingException: $message';
}

/// Decodes [bytes] (any format `package:image` supports), downscales so the
/// longest edge is [kThumbnailLongestEdge] px (no upscaling), re-encodes as
/// JPEG at [kThumbnailJpegQuality], and returns a `data:image/jpeg;base64,...`
/// URI ready to embed in a [SnapshotTask.image] field.
String encodeThumbnailDataUri(Uint8List bytes) {
  img.Image? decoded;
  try {
    decoded = img.decodeImage(bytes);
  } catch (_) {
    decoded = null;
  }
  if (decoded == null) {
    throw ThumbnailEncodingException('Could not decode image bytes');
  }

  final longestEdge =
      decoded.width > decoded.height ? decoded.width : decoded.height;
  final resized = longestEdge <= kThumbnailLongestEdge
      ? decoded
      : (decoded.width >= decoded.height
          ? img.copyResize(decoded, width: kThumbnailLongestEdge)
          : img.copyResize(decoded, height: kThumbnailLongestEdge));

  final jpegBytes =
      img.encodeJpg(resized, quality: kThumbnailJpegQuality);
  return 'data:image/jpeg;base64,${base64Encode(jpegBytes)}';
}
