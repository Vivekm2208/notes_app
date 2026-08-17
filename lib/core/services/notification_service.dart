import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:notes_app/core/features/notes/domain/entities/note.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'notes_channel',
    'Notes Reminder',
    description: 'Reminder notifications for notes',
    importance: Importance.max,
  );

  Future<void> initialize() async {
    // Load timezone database
    tz.initializeTimeZones();

    // Get device timezone
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();

    String timezone = timezoneInfo.identifier;

    // Older Android versions/emulators sometimes return Asia/Calcutta
    if (timezone == 'Asia/Calcutta') {
      timezone = 'Asia/Kolkata';
    }

    tz.setLocalLocation(tz.getLocation(timezone));

    debugPrint('Device Timezone : ${timezoneInfo.identifier}');
    debugPrint('Using Timezone  : $timezone');
    debugPrint('TZ Local        : ${tz.local.name}');

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _notifications.initialize(settings: initializationSettings);

    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (android != null) {
      // Android 13+
      await android.requestNotificationsPermission();

      // Android 14+
      await android.requestExactAlarmsPermission();

      // Explicitly create notification channel
      await android.createNotificationChannel(_channel);

      final canScheduleExact = await android.canScheduleExactNotifications();

      debugPrint('Can schedule exact alarms: $canScheduleExact');
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required ReminderRecurrence recurrence,
  }) async {
    final scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

    debugPrint('--------------------------------');
    debugPrint('DateTime       : $scheduledTime');
    debugPrint('TZDateTime     : $scheduledDate');
    debugPrint('Local Timezone : ${tz.local.name}');
    debugPrint('--------------------------------');

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'notes_channel',
        'Notes Reminder',
        channelDescription: 'Reminder notifications for notes',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,

        onlyAlertOnce: false,
      ),
    );

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: _dateTimeComponents(recurrence),
      payload: id.toString(),
    );

    final pending = await _notifications.pendingNotificationRequests();

    debugPrint('Pending Notifications: ${pending.length}');

    for (final notification in pending) {
      debugPrint(
        'ID: ${notification.id}, '
        'Title: ${notification.title}',
      );
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id: id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> showNotification() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'notes_channel',
        'Notes Reminder',
        channelDescription: 'Reminder notifications for notes',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _notifications.show(
      id: 0,
      title: 'Test Notification',
      body: 'If you see this, notifications work.',
      notificationDetails: details,
    );
  }

  DateTimeComponents? _dateTimeComponents(ReminderRecurrence recurrence) {
    switch (recurrence) {
      case ReminderRecurrence.none:
        return null;

      case ReminderRecurrence.daily:
        return DateTimeComponents.time;

      case ReminderRecurrence.weekly:
        return DateTimeComponents.dayOfWeekAndTime;

      case ReminderRecurrence.monthly:
        return DateTimeComponents.dayOfMonthAndTime;

      case ReminderRecurrence.yearly:
        return DateTimeComponents.dateAndTime;
    }
  }
}
