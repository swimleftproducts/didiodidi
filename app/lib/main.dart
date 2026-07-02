import 'package:flutter/material.dart';
import 'data/database.dart';
import 'ui/daily_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await openAppDatabase();
  runApp(DidiodidiApp(db: db));
}

class DidiodidiApp extends StatelessWidget {
  final AppDatabase db;
  const DidiodidiApp({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'didiodidi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A90E2)),
        useMaterial3: true,
      ),
      home: DailyListScreen(db: db),
    );
  }
}
