import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:didiodidi/data/database.dart';
import 'package:didiodidi/services/notification_service.dart';
import 'package:didiodidi/services/settings_repository.dart';
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

  Widget buildScreen() => MaterialApp(
        home: SettingsScreen(
          db: db,
          settings: settings,
          notificationService: notificationService,
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
}
