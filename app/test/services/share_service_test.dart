import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:didiodidi/domain/snapshot_models.dart';
import 'package:didiodidi/services/share_service.dart';

SnapshotPayload _payload() => const SnapshotPayload(
      schemaVersion: 1,
      username: 'alice',
      slug: 'a3b4c5d6e7',
      generatedAt: '2026-07-01',
      window: SnapshotWindow(start: '2026-06-25', end: '2026-07-01'),
      stats: SnapshotStats(completed: 1, total: 1),
      days: [
        SnapshotDay(
          date: '2026-07-01',
          weekday: 3,
          tasks: [
            SnapshotTask(
              id: '1',
              title: 'Hamstring stretch',
              description: '3x10',
              completed: true,
            ),
          ],
        ),
      ],
    );

void main() {
  group('ShareService', () {
    test('POSTs the exact payload JSON to the ingest URL', () async {
      Uri? capturedUri;
      Map<String, String>? capturedHeaders;
      String? capturedBody;

      final client = MockClient((request) async {
        capturedUri = request.url;
        capturedHeaders = request.headers;
        capturedBody = request.body;
        return http.Response(
          jsonEncode({'url': 'https://share.didiodidi.com/alice-a3b4c5d6e7'}),
          200,
        );
      });

      final service = ShareService(
        client: client,
        ingestUrl: 'https://api.didiodidi.com/didiodidi/ingest',
      );
      final url = await service.share(_payload());

      expect(url, 'https://share.didiodidi.com/alice-a3b4c5d6e7');
      expect(capturedUri.toString(), 'https://api.didiodidi.com/didiodidi/ingest');
      expect(capturedHeaders?['content-type'], contains('application/json'));
      expect(jsonDecode(capturedBody!), _payload().toJson());
    });

    test('throws ShareException with the server error message on 400', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({'error': 'Invalid slug'}), 400);
      });
      final service = ShareService(client: client);

      expect(
        () => service.share(_payload()),
        throwsA(isA<ShareException>().having(
          (e) => e.message,
          'message',
          'Invalid slug',
        )),
      );
    });

    test('throws ShareException with a generic message on malformed error body', () async {
      final client = MockClient((request) async => http.Response('not json', 500));
      final service = ShareService(client: client);

      expect(
        () => service.share(_payload()),
        throwsA(isA<ShareException>().having(
          (e) => e.message,
          'message',
          contains('500'),
        )),
      );
    });

    test('throws ShareException when the response has no url', () async {
      final client = MockClient((request) async => http.Response('{}', 200));
      final service = ShareService(client: client);

      expect(() => service.share(_payload()), throwsA(isA<ShareException>()));
    });

    test('throws ShareException when the client throws (network error)', () async {
      final client = MockClient((request) async => throw Exception('no network'));
      final service = ShareService(client: client);

      expect(() => service.share(_payload()), throwsA(isA<ShareException>()));
    });
  });
}
