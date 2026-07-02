import 'package:flutter/material.dart';
import '../data/database.dart';

class TaskInputScreen extends StatefulWidget {
  final AppDatabase db;
  final String? taskId; // null = add mode

  const TaskInputScreen({super.key, required this.db, this.taskId});

  @override
  State<TaskInputScreen> createState() => _TaskInputScreenState();
}

class _TaskInputScreenState extends State<TaskInputScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final Set<int> _selectedWeekdays = {};
  bool _loading = false;

  bool get _isAddMode => widget.taskId == null;

  @override
  void initState() {
    super.initState();
    if (!_isAddMode) _loadExisting();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    setState(() => _loading = true);
    final tw = await widget.db.taskDao.getTaskWithWeekdays(widget.taskId!);
    if (!mounted) return;
    _titleController.text = tw.task.title;
    _descController.text = tw.task.description;
    setState(() {
      _selectedWeekdays
        ..clear()
        ..addAll(tw.weekdays);
      _loading = false;
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _selectedWeekdays.isEmpty) return;
    if (_isAddMode) {
      await widget.db.taskDao.insertTask(
        title: title,
        description: _descController.text.trim(),
        weekdays: _selectedWeekdays.toList(),
      );
    } else {
      await widget.db.taskDao.updateTask(
        id: widget.taskId!,
        title: title,
        description: _descController.text.trim(),
        weekdays: _selectedWeekdays.toList(),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    await widget.db.taskDao.deactivateTask(widget.taskId!);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_isAddMode ? 'Add Task' : 'Edit Task'),
        actions: [
          if (!_isAddMode)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              key: const Key('titleField'),
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('descField'),
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            const Text('Due on',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            _WeekdayPicker(
              selected: _selectedWeekdays,
              onToggle: (day) => setState(() {
                if (_selectedWeekdays.contains(day)) {
                  _selectedWeekdays.remove(day);
                } else {
                  _selectedWeekdays.add(day);
                }
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('saveFab'),
        onPressed: _save,
        child: const Icon(Icons.check),
      ),
    );
  }
}

class _WeekdayPicker extends StatelessWidget {
  final Set<int> selected;
  final void Function(int day) onToggle;

  const _WeekdayPicker({required this.selected, required this.onToggle});

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (i) {
        final day = i + 1; // ISO: 1=Mon, 7=Sun
        final isSelected = selected.contains(day);
        final color = Theme.of(context).colorScheme.primary;
        return GestureDetector(
          key: Key('weekday_$day'),
          onTap: () => onToggle(day),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? color : null,
              border: Border.all(color: color),
            ),
            alignment: Alignment.center,
            child: Text(
              _labels[i],
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }
}
