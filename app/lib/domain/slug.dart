import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

// Standard base32 alphabet (RFC 4648), lowercased — matches slug pattern ^[a-z2-7]{10}$
const _kAlphabet = 'abcdefghijklmnopqrstuvwxyz234567';

/// Computes the 10-char slug: base32_lower(HMAC-SHA256(key=deviceSecret, msg=username))[:10]
///
/// [deviceSecretBase64] must be a base64-encoded 32-byte secret from secure storage.
String computeSlug(String deviceSecretBase64, String username) {
  final key = base64.decode(deviceSecretBase64);
  final msg = utf8.encode(username);
  final digest = Hmac(sha256, key).convert(msg);
  return _base32Lower(Uint8List.fromList(digest.bytes)).substring(0, 10);
}

String _base32Lower(Uint8List bytes) {
  final out = StringBuffer();
  var buffer = 0;
  var bitsLeft = 0;
  for (final byte in bytes) {
    buffer = (buffer << 8) | byte;
    bitsLeft += 8;
    while (bitsLeft >= 5) {
      bitsLeft -= 5;
      out.write(_kAlphabet[(buffer >> bitsLeft) & 0x1f]);
    }
  }
  if (bitsLeft > 0) {
    out.write(_kAlphabet[(buffer << (5 - bitsLeft)) & 0x1f]);
  }
  return out.toString();
}
