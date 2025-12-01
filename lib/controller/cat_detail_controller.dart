import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CatDetailController {
  final _notifications = FlutterLocalNotificationsPlugin();
  
  CatDetailController() {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    _notifications.initialize(initSettings);
  }

  Future<String> loadImage(String breed) async {
    await Future.delayed(const Duration(seconds: 1));
    return 'https://cataas.com/cat/says/$breed';
  }

  Future<void> sendNotification(String breed) async {
    const androidDetails = AndroidNotificationDetails('channel_id', 'Adopsi', importance: Importance.max);
    const details = NotificationDetails(android: androidDetails);
    await _notifications.show(0, 'Adopsi Berhasil!', 'Kucing $breed siap dijemput!', details);
  }
}