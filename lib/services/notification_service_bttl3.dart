import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();

    final localTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone.identifier));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> showSavedNotification(String title) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'todo_saved_channel',
        'Thông báo công việc',
        channelDescription: 'Thông báo khi lưu công việc',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Đã thêm lịch',
      'Đã lưu "$title". Hãy nhớ hoàn thành công việc nhé!',
      details,
    );
  }

  Future<void> scheduleTodoNotification({
    required int id,
    required String title,
    required DateTime scheduledTime,
  }) async {
    if (!scheduledTime.isAfter(DateTime.now())) {
      return;
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'todo_reminder_channel',
        'Nhắc nhở công việc',
        channelDescription: 'Nhắc công việc theo giờ đã chọn',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _notifications.zonedSchedule(
      id,
      'Đến giờ làm việc!',
      title,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
  
Future<void> showCompletedCount(int count) async {
  const details = NotificationDetails(
    android: AndroidNotificationDetails(
      'todo_completed_channel',
      'Nhiệm vụ hoàn thành',
      channelDescription: 'Thông báo số lượng nhiệm vụ đã hoàn thành',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  await _notifications.show(
    900001,
    'Cập nhật nhiệm vụ',
    'Bạn đã hoàn thành $count nhiệm vụ!',
    details,
  );
}

}
