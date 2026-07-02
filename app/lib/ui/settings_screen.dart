import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../data/database.dart';
import '../domain/snapshot_builder.dart';
import '../services/notification_service.dart';
import '../services/settings_repository.dart';
import '../services/share_service.dart';

class SettingsScreen extends StatefulWidget {
  final AppDatabase db;
  final SettingsRepository settings;
  final NotificationService notificationService;
  final ShareService shareService;

  SettingsScreen({
    super.key,
    required this.db,
    required this.settings,
    required this.notificationService,
    ShareService? shareService,
  }) : shareService = shareService ?? ShareService(client: http.Client());

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  final _usernameController = TextEditingController();

  TimeOfDay _morningTime = SettingsRepository.defaultMorningTime;
  TimeOfDay _middayTime = SettingsRepository.defaultMiddayTime;
  TimeOfDay _eveningTime = SettingsRepository.defaultEveningTime;
  bool _loading = true;
  bool _sharing = false;
  String? _shareUrl;
  String? _shareError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final apiKey = await widget.settings.getApiKey();
    final username = await widget.settings.getUsername();
    final morning = await widget.settings.getMorningTime();
    final midday = await widget.settings.getMiddayTime();
    final evening = await widget.settings.getEveningTime();
    if (!mounted) return;
    _apiKeyController.text = apiKey ?? '';
    _usernameController.text = username ?? '';
    setState(() {
      _morningTime = morning;
      _middayTime = midday;
      _eveningTime = evening;
      _loading = false;
    });
  }

  Future<void> _save() async {
    await widget.settings.setApiKey(_apiKeyController.text.trim());
    await widget.settings.setUsername(_usernameController.text.trim());
    if (mounted) Navigator.pop(context);
  }

  Future<void> _share() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() {
        _shareError = 'Set a username before sharing';
        _shareUrl = null;
      });
      return;
    }

    setState(() {
      _sharing = true;
      _shareError = null;
      _shareUrl = null;
    });

    try {
      final secret = await widget.settings.getOrCreateDeviceSecret();
      final payload = await buildSnapshotPayload(
        taskDao: widget.db.taskDao,
        completionDao: widget.db.completionDao,
        username: username,
        deviceSecretBase64: secret,
        now: DateTime.now(),
        loadImageBytes: (path) => File(path).readAsBytes(),
      );
      final url = await widget.shareService.share(payload);
      if (!mounted) return;
      setState(() => _shareUrl = url);
    } on SnapshotTooLargeException catch (e) {
      if (!mounted) return;
      setState(() => _shareError = e.message);
    } on ShareException catch (e) {
      if (!mounted) return;
      setState(() => _shareError = e.message);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _pickTime(
    TimeOfDay current,
    Future<void> Function(TimeOfDay) onPicked,
  ) async {
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked == null) return;
    await onPicked(picked);
    await widget.notificationService.rescheduleAll(
      db: widget.db,
      settings: widget.settings,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const Key('apiKeyField'),
            controller: _apiKeyController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Anthropic API Key'),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('usernameField'),
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          const SizedBox(height: 24),
          const Text('Reminders', style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            key: const Key('morningTimeTile'),
            title: const Text('Morning'),
            trailing: Text(_morningTime.format(context)),
            onTap: () => _pickTime(_morningTime, (t) async {
              await widget.settings.setMorningTime(t);
              setState(() => _morningTime = t);
            }),
          ),
          ListTile(
            key: const Key('middayTimeTile'),
            title: const Text('Midday'),
            trailing: Text(_middayTime.format(context)),
            onTap: () => _pickTime(_middayTime, (t) async {
              await widget.settings.setMiddayTime(t);
              setState(() => _middayTime = t);
            }),
          ),
          ListTile(
            key: const Key('eveningTimeTile'),
            title: const Text('Evening'),
            trailing: Text(_eveningTime.format(context)),
            onTap: () => _pickTime(_eveningTime, (t) async {
              await widget.settings.setEveningTime(t);
              setState(() => _eveningTime = t);
            }),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            key: const Key('saveButton'),
            onPressed: _save,
            child: const Text('Save'),
          ),
          const SizedBox(height: 24),
          const Text('Share', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ElevatedButton(
            key: const Key('shareButton'),
            onPressed: _sharing ? null : _share,
            child: _sharing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Share last 7 days'),
          ),
          if (_shareUrl != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _shareUrl!,
                    key: const Key('shareUrlText'),
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
                IconButton(
                  key: const Key('copyShareUrlButton'),
                  icon: const Icon(Icons.copy),
                  onPressed: () =>
                      Clipboard.setData(ClipboardData(text: _shareUrl!)),
                ),
              ],
            ),
          ],
          if (_shareError != null) ...[
            const SizedBox(height: 8),
            Text(
              _shareError!,
              key: const Key('shareErrorText'),
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }
}
