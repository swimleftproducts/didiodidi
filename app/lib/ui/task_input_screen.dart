import 'package:flutter/material.dart';
import '../data/database.dart';
import '../domain/due_logic.dart';

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
  DateTime? _endDate;
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
      _endDate =
          tw.task.endDate == null ? null : DateTime.parse(tw.task.endDate!);
      _loading = false;
    });
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _selectedWeekdays.isEmpty) return;
    final endDate = _endDate == null ? null : isoDate(_endDate!);
    if (_isAddMode) {
      await widget.db.taskDao.insertTask(
        title: title,
        description: _descController.text.trim(),
        weekdays: _selectedWeekdays.toList(),
        endDate: endDate,
      );
    } else {
      await widget.db.taskDao.updateTask(
        id: widget.taskId!,
        title: title,
        description: _descController.text.trim(),
        weekdays: _selectedWeekdays.toList(),
        endDate: endDate,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _stop() async {
    await widget.db.taskDao.deactivateTask(widget.taskId!);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _confirmDelete() async {
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
      await widget.db.taskDao.deleteTaskPermanently(widget.taskId!);
      if (mounted) Navigator.pop(context);
    }
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
            PopupMenuButton<String>(
              key: const Key('taskMenuButton'),
              onSelected: (value) {
                if (value == 'stop') _stop();
                if (value == 'delete') _confirmDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'stop', child: Text('Stop (pause)')),
                PopupMenuItem(
                    value: 'delete', child: Text('Delete permanently')),
              ],
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
            const SizedBox(height: 20),
            const Text('Ends on',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const Key('endDateButton'),
                    onPressed: _pickEndDate,
                    child: Text(
                      _endDate == null
                          ? 'Repeats weekly (no end date)'
                          : 'Ends ${isoDate(_endDate!)}',
                    ),
                  ),
                ),
                if (_endDate != null)
                  IconButton(
                    key: const Key('clearEndDateButton'),
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _endDate = null),
                  ),
              ],
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
