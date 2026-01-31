import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../services/emergency_service.dart';
import '../providers/bluetooth_provider.dart';
import '../utils/event_bus.dart';

class EmergencyHandler extends StatefulWidget {
  final Widget child;

  const EmergencyHandler({
    super.key,
    required this.child,
  });

  @override
  State<EmergencyHandler> createState() => _EmergencyHandlerState();
}

class _EmergencyHandlerState extends State<EmergencyHandler>
    with WidgetsBindingObserver {
  late StreamSubscription _emergencySubscription;
  bool _isEmergencyActive = false;
  Timer? _timer;
  bool _smsSent = false;
  final FlutterBackgroundService _backgroundService =
      FlutterBackgroundService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenForEmergencySignals();
      _setupBackgroundServiceListener();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Uygulama arka plana geçtiğinde veya ön plana geldiğinde gerekli ayarlamaları yap
    if (state == AppLifecycleState.paused) {
      // Uygulama arka plana geçti
      _backgroundService.invoke('setAsBackground');
    } else if (state == AppLifecycleState.resumed) {
      // Uygulama ön plana geldi
      _backgroundService.invoke('setAsForeground');
    }
  }

  void _setupBackgroundServiceListener() {
    // Arka plan servisinden gelen mesajları dinle
    _backgroundService.on('update').listen((event) {
      // Arka plan servisi güncelleme mesajları
    });
  }

  late StreamSubscription _bluetoothEmergencySubscription;

  void _listenForEmergencySignals() {
    // Normal acil durum sinyallerini dinle
    _emergencySubscription = eventBus.on<EmergencySignalEvent>().listen((_) {
      if (!_isEmergencyActive) {
        debugPrint("📱 EmergencyHandler: EmergencySignalEvent alındı!");
        _showEmergencyNotification();
      }
    });

    // Bluetooth'dan gelen acil durum sinyallerini de dinle
    _bluetoothEmergencySubscription =
        eventBus.on<BluetoothEmergencySignalEvent>().listen((_) {
      if (!_isEmergencyActive) {
        debugPrint(
            "📱 EmergencyHandler: BluetoothEmergencySignalEvent alındı!");
        _showEmergencyNotification();
      }
    });
  }

  void _showEmergencyNotification() {
    debugPrint("🚨 EmergencyHandler: Acil durum bildirimi gösteriliyor...");

    // Aktif bir context olup olmadığını kontrol et
    if (!mounted) {
      debugPrint(
          "⚠️ EmergencyHandler: Context bulunamadı, doğrudan SMS gönderiliyor!");
      // Context yok (arka planda olabilir), direkt SMS gönder
      _sendEmergencyMessage();
      return;
    }

    setState(() {
      _isEmergencyActive = true;
      _smsSent = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        // 5 saniye sonra otomatik SMS gönder
        _timer = Timer(const Duration(seconds: 5), () async {
          if (!_smsSent && mounted) {
            _smsSent = true;
            try {
              Navigator.of(context, rootNavigator: true).pop();
            } catch (e) {
              debugPrint("Navigator pop hatası: $e");
            }
            await _sendEmergencyMessage();
            if (mounted) {
              _showSentDialog();
            }
          }
        });
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.red, size: 24),
              const SizedBox(width: 8),
              const Text('ACİL DURUM!'),
            ],
          ),
          content: const Text(
            'Montech cihazından acil durum sinyali alındı.\n\n5 saniye içinde iptal etmezseniz acil durum kişinize otomatik olarak SMS gönderilecek.',
          ),
          actions: [
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                _timer?.cancel();
                _smsSent = true;
                Navigator.of(context, rootNavigator: true).pop();
                setState(() {
                  _isEmergencyActive = false;
                });
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('HEMEN GÖNDER',
                  style: TextStyle(color: Colors.white)),
              onPressed: () async {
                _timer?.cancel();
                if (!_smsSent) {
                  _smsSent = true;
                  Navigator.of(context, rootNavigator: true).pop();
                  await _sendEmergencyMessage();
                  _showSentDialog();
                }
              },
            ),
          ],
        );
      },
    ).then((_) {
      _timer?.cancel();
      setState(() {
        _isEmergencyActive = false;
      });
    });
  }

  void _showSentDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: Colors.green, size: 24),
            const SizedBox(width: 8),
            const Text('SMS Gönderildi'),
          ],
        ),
        content: const Text('Acil durum kişinize SMS gönderildi.'),
        actions: [
          TextButton(
            child: const Text('Tamam'),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _sendEmergencyMessage() async {
    try {
      debugPrint("📤 EmergencyHandler: Acil durum mesajı gönderiliyor...");

      // Context varsa normal servis üzerinden gönder
      if (mounted) {
        debugPrint("📱 Context mevcut, normal servis üzerinden gönderiliyor");
        await EmergencyService.sendAutomaticEmergencyAlert(context);
      } else {
        // Context yoksa doğrudan gönder
        debugPrint("🔄 Context yok, doğrudan servis üzerinden gönderiliyor");
        await EmergencyService.sendDirectEmergencyAlert();
      }

      debugPrint("✅ Acil durum mesajı başarıyla gönderildi");
    } catch (e) {
      debugPrint("⚠️ Acil durum mesajı gönderirken hata: $e");
    }
  }

  @override
  void dispose() {
    _emergencySubscription.cancel();
    _bluetoothEmergencySubscription.cancel();
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
