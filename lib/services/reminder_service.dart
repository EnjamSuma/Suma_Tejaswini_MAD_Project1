import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ReminderService {
  ReminderService._();
  static final instance = ReminderService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'planning',
      'Planning reminders',
      channelDescription: 'Daily reminder to plan lunch',
    ),
  );

  Future<void> init() async {
    if (_ready) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));
    _ready = true;
  }

  /// Returns false if the user denied notification permission.
  Future<bool> enableDaily() async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission() ?? true;
    if (!granted) return false;
    await _plugin.periodicallyShow(
      1,
      'Plan your lunch',
      'Check your budget and pick a meal.',
      RepeatInterval.daily,
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
    return true;
  }

  Future<void> showNow() async {
    await init();
    await _plugin.show(2, 'Plan your lunch',
        'Check your budget and pick a meal.', _details);
  }

  Future<void> disable() async {
    await init();
    await _plugin.cancel(1);
  }
}