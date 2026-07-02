import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:didiodidi/domain/slug.dart';

String _secret(int fill) => base64.encode(List.generate(32, (_) => fill));

void main() {
  group('computeSlug', () {
    test('output is exactly 10 characters', () {
      expect(computeSlug(_secret(1), 'alice').length, 10);
    });

    test('output only contains base32 alphabet [a-z2-7]', () {
      final slug = computeSlug(_secret(1), 'alice');
      expect(RegExp(r'^[a-z2-7]{10}$').hasMatch(slug), isTrue,
          reason: 'slug "$slug" contains invalid characters');
    });

    test('deterministic — same inputs produce same slug', () {
      expect(computeSlug(_secret(42), 'bob'), computeSlug(_secret(42), 'bob'));
    });

    test('different usernames produce different slugs', () {
      expect(computeSlug(_secret(1), 'alice'),
          isNot(equals(computeSlug(_secret(1), 'bob'))));
    });

    test('different secrets produce different slugs', () {
      expect(computeSlug(_secret(1), 'alice'),
          isNot(equals(computeSlug(_secret(2), 'alice'))));
    });

    test('varying secret bytes all produce valid slugs', () {
      for (var i = 0; i < 10; i++) {
        final slug = computeSlug(base64.encode(List.generate(32, (j) => (i * j) & 0xff)), 'user');
        expect(slug.length, 10);
        expect(RegExp(r'^[a-z2-7]{10}$').hasMatch(slug), isTrue);
      }
    });
  });
}
