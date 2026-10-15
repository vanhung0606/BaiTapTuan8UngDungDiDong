import 'package:flutter/material.dart';
import 'package:tuan08/services/notification_service.dart';

class ScreenNotiEx extends StatelessWidget {
  const ScreenNotiEx({super.key});
  @override
  Widget build(BuildContext context) {
    NotificationService notificatiosnservice = NotificationService();
    notificatiosnservice.init();
    return Scaffold(
      appBar: AppBar(title: Text("Screen Noti Example")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                notificatiosnservice.showSimpleNotification();
              },
              child: Text("Gửi thông báo nhắc học Ngoại ngữ"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                notificatiosnservice.scheduleNotificationAfter(
                  Duration(minutes: 2),
                  'drink_water_channel',
                  'Uống nước',
                  'Nhắc uống nước đúng giờ',
                );
              },
              child: Text("Gửi thông báo nhắc uống nước sau 2 phút"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                notificatiosnservice.scheduleNotificationAfter(
                  Duration(minutes: 10),
                  'language_learning_channel',
                  'Học Ngoại ngữ',
                  'Nhắc học Ngoại ngữ đúng giờ',
                );
              },
              child: Text("Hẹn giờ gửi thông báo học Ngoại ngữ sau 10 phút"),
            ),
          ],
        ),
      ),
    );
  }
}
