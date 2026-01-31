import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/event_bus.dart';
import '../services/emergency_service.dart';

@pragma('vm:entry-point') // <<< Bu class seviyesine EKLENDİ
class BackgroundService {
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'montech_foreground',
      'Montech Servisi',
      description: 'Bu bildirim Montech\'in arka planda çalıştığını gösterir.',
      importance: Importance.high,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'montech_foreground',
        initialNotificationTitle: 'Montech',
        initialNotificationContent: 'Montech korumanız için çalışıyor',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    service.startService();
  }

  @pragma('vm:entry-point') // << iOS için gerekli
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  @pragma('vm:entry-point') // << Android onStart için gerekli
  static void onStart(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    service.on('emergencySignal').listen((event) async {
      final isolateName = event?['isolateName'];
      debugPrint(
          "🔄 BackgroundService: emergencySignal alındı, isolate=$isolateName");

      // Event bus üzerinden acil durum sinyalini ilet
      eventBus.fire(EmergencySignalEvent());

      // Arka planda çalışabilmesi için doğrudan SMS gönderme metodunu çağır
      try {
        debugPrint(
            "📤 BackgroundService: Doğrudan acil durum SMS'i gönderiliyor...");
        // Emergency service import edilmeli
        await EmergencyService.sendDirectEmergencyAlert();
      } catch (e) {
        debugPrint("⚠️ BackgroundService: SMS gönderme hatası: $e");
      }
    });

    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          service.setForegroundNotificationInfo(
            title: "Montech",
            content: "Montech korumanız için çalışıyor",
          );
        }
      }

      service.invoke(
        'update',
        {
          "current_date": DateTime.now().toIso8601String(),
        },
      );
    });
  }

  static Future<void> triggerEmergencySignal() async {
    final service = FlutterBackgroundService();
    service.invoke('emergencySignal', {'isolateName': 'main'});
  }
}
