import 'package:flutter/material.dart';
import '../data/database.dart';
import '../data/daos/task_dao.dart';
import '../domain/due_logic.dart';
import 'task_input_screen.dart';

const _weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class AllTasksScreen extends StatefulWidget {
  final AppDatabase db;

  const AllTasksScreen({super.key, required this.db});

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen> {
  List<TaskWithWeekdays> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tasks = await widget.db.taskDao.getAllTasksWithWeekdays();
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _loading = false;
    });
  }

  Future<void> _navigateToAdd() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskInputScreen(db: widget.db)),
    );
    await _load();
  }

  Future<void> _navigateToEdit(String taskId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskInputScreen(db: widget.db, taskId: taskId),
      ),
    );
    await _load();
  }

  Future<void> _delete(String taskId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete task?'),
        content: const Text(
          'This permanently removes the task and its history. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.db.taskDao.deleteTaskPermanently(taskId);
      await _load();
    }
  }

  bool _isStopped(TaskWithWeekdays tw) {
    if (!tw.task.active) return true;
    final endDate = tw.task.endDate;
    return endDate != null && !taskStillActiveOn(endDate, DateTime.now());
  }

  String _scheduleLabel(TaskWithWeekdays tw) {
    final days = tw.weekdays.map((d) => _weekdayNames[d - 1]).join(', ');
    final endDate = tw.task.endDate;
    return endDate == null ? days : '$days · until $endDate';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('All Tasks')),
      body: _tasks.isEmpty
          ? const Center(
              child: Text(
                'No tasks yet.\nTap + to add one.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, i) {
                final tw = _tasks[i];
                final stopped = _isStopped(tw);
                final greyStyle = stopped ? const TextStyle(color: Colors.grey) : null;
                return ListTile(
                  key: Key('taskRow_${tw.task.id}'),
                  title: Text(tw.task.title, style: greyStyle),
                  subtitle: Text(
                    stopped
                        ? '${_scheduleLabel(tw)} · Stopped'
                        : _scheduleLabel(tw),
                    style: greyStyle,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        key: Key('editButton_${tw.task.id}'),
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _navigateToEdit(tw.task.id),
                      ),
                      IconButton(
                        key: Key('deleteButton_${tw.task.id}'),
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _delete(tw.task.id),
                      ),
                    ],
                  ),
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
