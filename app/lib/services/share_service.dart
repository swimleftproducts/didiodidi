// The only HTTP boundary in the app (CLAUDE.md Section 7) — POSTs a built
// SnapshotPayload to /ingest and returns the public share URL.
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../domain/snapshot_models.dart';

class ShareException implements Exception {
  final String message;
  ShareException(this.message);

  @override
  String toString() => 'ShareException: $message';
}

class ShareService {
  final http.Client _client;
  final String ingestUrl;

  ShareService({required http.Client client, this.ingestUrl = kIngestUrl})
      : _client = client;

  /// POSTs [payload] to the ingest endpoint. Returns the public share URL on
  /// success; throws [ShareException] with a message suitable for display
  /// on any non-200 response or malformed reply.
  Future<String> share(SnapshotPayload payload) async {
    late final http.Response response;
    try {
      response = await _client.post(
        Uri.parse(ingestUrl),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(payload.toJson()),
      );
    } catch (e) {
      throw ShareException('Could not reach the share server: $e');
    }

    Map<String, dynamic>? decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      decoded = null;
    }

    if (response.statusCode != 200) {
      final serverMessage = decoded?['error']?.toString();
      throw ShareException(
        serverMessage ?? 'Share failed (HTTP ${response.statusCode})',
      );
    }

    final url = decoded?['url'] as String?;
    if (url == null) {
      throw ShareException('Malformed response from the share server');
    }
    return url;
  }
}
