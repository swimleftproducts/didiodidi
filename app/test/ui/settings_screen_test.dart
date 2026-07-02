import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:didiodidi/data/database.dart';
import 'package:didiodidi/services/notification_service.dart';
import 'package:didiodidi/services/settings_repository.dart';
import 'package:didiodidi/services/share_service.dart';
import 'package:didiodidi/ui/settings_screen.dart';
import '../test_fakes.dart';

AppDatabase _db() => AppDatabase(NativeDatabase.memory());

void main() {
  late AppDatabase db;
  late SettingsRepository settings;
  late FakeNotificationScheduler scheduler;
  late NotificationService notificationService;

  setUp(() {
    db = _db();
    settings = SettingsRepository(InMemoryKeyValueStore());
    scheduler = FakeNotificationScheduler();
    notificationService = NotificationService(scheduler);
  });

  tearDown(() => db.close());

  Widget buildScreen({ShareService? shareService}) => MaterialApp(
        home: SettingsScreen(
          db: db,
          settings: settings,
          notificationService: notificationService,
          shareService: shareService,
        ),
      );

  testWidgets('shows default reminder times', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('8:00 AM'), findsOneWidget);
    expect(find.text('12:30 PM'), findsOneWidget);
    expect(find.text('6:00 PM'), findsOneWidget);
  });

  testWidgets('loads existing api key and username', (tester) async {
    await settings.setApiKey('sk-ant-existing');
    await settings.setUsername('alice');

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('sk-ant-existing'), findsOneWidget);
    expect(find.text('alice'), findsOneWidget);
  });

  testWidgets('saving persists api key and username', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('apiKeyField')), 'sk-ant-new');
    await tester.enterText(find.byKey(const Key('usernameField')), 'bob');
    await tester.tap(find.byKey(const Key('saveButton')));
    await tester.pumpAndSettle();

    expect(await settings.getApiKey(), 'sk-ant-new');
    expect(await settings.getUsername(), 'bob');
  });

  testWidgets('tapping Share with no username shows an error, not a network call', (tester) async {
    var called = false;
    final client = MockClient((request) async {
      called = true;
      return http.Response('{}', 200);
    });

    await tester.pumpWidget(buildScreen(shareService: ShareService(client: client)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('shareButton')));
    await tester.pumpAndSettle();

    expect(called, isFalse);
    expect(find.byKey(const Key('shareErrorText')), findsOneWidget);
    expect(find.text('Set a username before sharing'), findsOneWidget);
  });

  testWidgets('tapping Share with a username posts and shows the returned URL', (tester) async {
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode({'url': 'https://share.didiodidi.com/alice-a3b4c5d6e7'}),
        200,
      );
    });

    await settings.setUsername('alice');
    await tester.pumpWidget(buildScreen(shareService: ShareService(client: client)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('shareButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('shareUrlText')), findsOneWidget);
    expect(find.text('https://share.didiodidi.com/alice-a3b4c5d6e7'), findsOneWidget);
    expect(find.byKey(const Key('shareErrorText')), findsNothing);
  });

  testWidgets('a server error is shown as share error text', (tester) async {
    final client = MockClient((request) async {
      return http.Response(jsonEncode({'error': 'Invalid slug'}), 400);
    });

    await settings.setUsername('alice');
    await tester.pumpWidget(buildScreen(shareService: ShareService(client: client)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('shareButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('shareErrorText')), findsOneWidget);
    expect(find.text('Invalid slug'), findsOneWidget);
    expect(find.byKey(const Key('shareUrlText')), findsNothing);
  });
}
