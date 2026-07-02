import 'package:flutter/material.dart';
import 'data/database.dart';
import 'services/key_value_store.dart';
import 'services/notification_service.dart';
import 'services/settings_repository.dart';
import 'ui/daily_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await openAppDatabase();
  final settings = SettingsRepository(const SecureKeyValueStore());
  final notificationService = NotificationService();
  await notificationService.init();
  runApp(DidiodidiApp(
    db: db,
    settings: settings,
    notificationService: notificationService,
  ));
}

class DidiodidiApp extends StatefulWidget {
  final AppDatabase db;
  final SettingsRepository settings;
  final NotificationService notificationService;

  const DidiodidiApp({
    super.key,
    required this.db,
    required this.settings,
    required this.notificationService,
  });

  @override
  State<DidiodidiApp> createState() => _DidiodidiAppState();
}

class _DidiodidiAppState extends State<DidiodidiApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _reschedule();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Notification text is baked in at schedule time and can't be recomputed
  // when a notification fires, so every foreground/background transition
  // recomputes and reschedules all three (CLAUDE.md Section 7).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _reschedule();
    }
  }

  void _reschedule() {
    widget.notificationService.rescheduleAll(
      db: widget.db,
      settings: widget.settings,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'didiodidi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A90E2)),
        useMaterial3: true,
      ),
      home: DailyListScreen(
        db: widget.db,
        settings: widget.settings,
        notificationService: widget.notificationService,
      ),
    );
  }
}
