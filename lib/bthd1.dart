import 'package:flutter/material.dart';
import 'package:tuan08/services/notification_service.dart';
import 'package:tuan08/views/screen_noti_ex.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = NotificationService();
  await notificationService.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      home: ScreenNotiEx(),
    );
  }
}
