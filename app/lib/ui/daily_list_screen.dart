import 'package:flutter/material.dart';
import '../data/database.dart';
import '../domain/due_logic.dart';
import '../services/notification_service.dart';
import '../services/settings_repository.dart';
import 'all_tasks_screen.dart';
import 'settings_screen.dart';
import 'task_input_screen.dart';

class DailyListScreen extends StatefulWidget {
  final AppDatabase db;
  final SettingsRepository settings;
  final NotificationService notificationService;

  const DailyListScreen({
    super.key,
    required this.db,
    required this.settings,
    required this.notificationService,
  });

  @override
  State<DailyListScreen> createState() => _DailyListScreenState();
}

class _DailyListScreenState extends State<DailyListScreen> {
  List<Task> _dueTasks = [];
  Set<String> _completedIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final today = isoDate(DateTime.now());
    final weekday = DateTime.now().weekday;
    final tasks = await widget.db.taskDao.getTasksDueOn(weekday, today: today);
    final completions =
        await widget.db.completionDao.getCompletionsForDate(today);
    if (!mounted) return;
    setState(() {
      _dueTasks = tasks;
      _completedIds = completions.map((c) => c.taskId).toSet();
      _loading = false;
    });
  }

  Future<void> _toggle(String taskId) async {
    await widget.db.completionDao.toggleCompletion(taskId, isoDate(DateTime.now()));
    await _load();
  }

  Future<void> _navigateToAdd() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskInputScreen(db: widget.db)),
    );
    await _load();
  }

  Future<void> _navigateToEdit(Task task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => TaskInputScreen(db: widget.db, taskId: task.id)),
    );
    await _load();
  }

  Future<void> _navigateToAllTasks() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AllTasksScreen(db: widget.db)),
    );
    await _load();
  }

  Future<void> _navigateToSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          db: widget.db,
          settings: widget.settings,
          notificationService: widget.notificationService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final stats = computeStats(
      _dueTasks.map((t) => t.id).toList(),
      _completedIds,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${stats.completed}/${stats.total}  ·  ${isoDate(DateTime.now())}',
        ),
        actions: [
          IconButton(
            key: const Key('allTasksButton'),
            icon: const Icon(Icons.list_alt),
            onPressed: _navigateToAllTasks,
          ),
          IconButton(
            key: const Key('settingsButton'),
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
          ),
        ],
      ),
      body: _dueTasks.isEmpty
          ? const Center(
              child: Text(
                'No tasks due today.\nTap + to add one.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: _dueTasks.length,
              itemBuilder: (context, i) {
                final task = _dueTasks[i];
                final done = _completedIds.contains(task.id);
                return ListTile(
                  leading: Icon(
                    done ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: done
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                  title: Text(
                    task.title,
                    style: done
                        ? const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                  subtitle: task.description.isNotEmpty
                      ? Text(task.description)
                      : null,
                  trailing: IconButton(
                    key: Key('editButton_${task.id}'),
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _navigateToEdit(task),
                  ),
                  onTap: () => _toggle(task.id),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}
