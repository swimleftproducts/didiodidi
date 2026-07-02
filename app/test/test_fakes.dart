// Shared test doubles — the injected-fake pattern used elsewhere for
// external I/O boundaries (e.g. ShareService's injected HTTP client).
import 'package:didiodidi/services/key_value_store.dart';
import 'package:didiodidi/services/notification_scheduler.dart';

class InMemoryKeyValueStore implements KeyValueStore {
  final Map<String, String> _map = {};

  @override
  Future<String?> read(String key) async => _map[key];

  @override
  Future<void> write(String key, String value) async => _map[key] = value;
}

class ScheduledCall {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledDate;

  ScheduledCall({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
  });
}

class FakeNotificationScheduler implements NotificationScheduler {
  final List<ScheduledCall> scheduled = [];
  final List<int> cancelled = [];
  bool initialized = false;

  @override
  Future<void> initialize() async => initialized = true;

  @override
  Future<void> cancel(int id) async => cancelled.add(id);

  @override
  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    scheduled.add(ScheduledCall(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
    ));
  }
}
