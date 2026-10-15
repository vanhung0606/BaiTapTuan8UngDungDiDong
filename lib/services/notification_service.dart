import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(settings);

    await _requestPermission();
  }

  Future<void> _requestPermission() async {
    var status = await Permission.notification.status;

    if (status.isDenied) {
      await Permission.notification.request();
    }

    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  static AndroidNotificationDetails _createAndroidDetails({
    required String channelId,
    required String channelName,
    String? channelDescription,
  }) {
    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
      playSound: true,
      enableVibration: true,
      showWhen: true,
    );
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required AndroidNotificationDetails androidDetails,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> showSimpleNotification({
    int id = 0,
    String title = 'Nhắc học từ vựng',
    String body = 'Bạn đã học 5 từ mới hôm nay chưa?',
  }) async {
    final details = _createAndroidDetails(
      channelId: 'learn_english_channel',
      channelName: 'Học Anh Văn',
    );

    await _plugin.show(id, title, body, NotificationDetails(android: details));
  }

  Future<void> scheduleNotificationAfter(
    Duration delay,
    String channelId,
    String channelName,
    String channelDescription,
  ) async {
    final details = _createAndroidDetails(
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDescription,
    );

    final scheduledTime = tz.TZDateTime.now(tz.local).add(delay);

    await _scheduleNotification(
      id: 1,
      title: channelName,
      body: channelDescription,
      scheduledTime: scheduledTime,
      androidDetails: details,
    );
  }
}
