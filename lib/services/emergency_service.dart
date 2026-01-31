import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/emergency_provider.dart';
import '../models/emergency_contact.dart';

class EmergencyService {
  static const platform = MethodChannel('com.example.montech/emergency');

  // Konum almak için gelişmiş metod - konum kapalıysa açar ve bekler
  static Future<Position?> _getLocationWithAutoEnable() async {
    try {
      // Konum servisinin açık olup olmadığını kontrol et
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      
      if (!serviceEnabled) {
        debugPrint("⚠️ Konum servisi kapalı, açılması isteniyor...");
        
        // Konum servisini açmak için sistem ayarlarını aç
        bool opened = await Geolocator.openLocationSettings();
        
        if (opened) {
          debugPrint("📍 Konum ayarları açıldı, kullanıcının açmasını bekliyoruz...");
          
          // 5 saniye boyunca konum servisinin açılmasını bekle
          for (int i = 0; i < 10; i++) {
            await Future.delayed(const Duration(milliseconds: 500));
            serviceEnabled = await Geolocator.isLocationServiceEnabled();
            if (serviceEnabled) {
              debugPrint("✅ Konum servisi açıldı! ${(i + 1) * 500}ms sonra");
              // Konum doğruluğu için 5 saniye daha bekle
              debugPrint("⏳ Konum doğruluğu için 5 saniye bekleniyor...");
              await Future.delayed(const Duration(seconds: 5));
              break;
            }
          }
          
          if (!serviceEnabled) {
            debugPrint("⚠️ Konum servisi 5 saniye içinde açılmadı");
            return null;
          }
        } else {
          debugPrint("⚠️ Konum ayarları açılamadı");
          return null;
        }
      } else {
        debugPrint("✅ Konum servisi zaten açık");
      }

      // İzin kontrolü
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint("⚠️ Konum izni reddedildi");
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint("⚠️ Konum izni kalıcı olarak reddedildi");
        return null;
      }

      // 15 saniye timeout ile konum al
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
    } catch (e) {
      debugPrint("⚠️ Konum alınırken hata: $e");
      return null;
    }
  }

  // Hızlı konum kontrolü (zaten açıksa anında al)
  static Future<Position?> _getLocationQuick() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint("⚠️ Hızlı konum alınırken hata: $e");
      return null;
    }
  }

  static Future<void> sendEmergencySMS({
    BuildContext? context,
    String? phoneNumber,
    String? name,
  }) async {
    try {
      String phone = phoneNumber ?? '';

      if (context != null && (phone.isEmpty || name == null || name.isEmpty)) {
        final provider = Provider.of<EmergencyProvider>(context, listen: false);
        if (provider.hasEmergencyContact) {
          phone = provider.emergencyContact!.phone;
          name = provider.emergencyContact!.name;
        }
      }

      if (phone.isEmpty) {
        debugPrint("Acil durum: Telefon numarası bulunamadı!");
        return;
      }

      // Önce hızlı konum dene, yoksa konum açmayı dene
      debugPrint("📍 Konum alınıyor...");
      Position? position = await _getLocationQuick();
      
      if (position == null) {
        debugPrint("📍 Konum kapalı, açılması deneniyor...");
        position = await _getLocationWithAutoEnable();
      }

      String message;
      if (position != null) {
        final latitude = position.latitude;
        final longitude = position.longitude;
        message = "ACİL DURUM! ${name != null && name.isNotEmpty ? '$name,' : ''} yardım gerekiyor! Şu an bu konumdayım: https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
        debugPrint("✅ Konum ile mesaj hazırlandı");
      } else {
        message = "ACİL DURUM! ${name != null && name.isNotEmpty ? '$name,' : ''} yardım gerekiyor! (Konum bilgisi alınamadı)";
        debugPrint("⚠️ Konum alınamadı ama SMS yine de gönderilecek");
      }

      await platform.invokeMethod('sendSMS', {"phone": phone, "message": message});
      debugPrint("✅ Acil durum SMS gönderildi: $phone");
    } catch (e) {
      debugPrint("SMS gönderme hatası: $e");
    }
  }

  static Future<void> sendWhatsAppWithLocation({
    BuildContext? context,
    String? phoneNumber,
    String? name,
  }) async {
    try {
      String phone = phoneNumber ?? '';

      if (context != null && (phone.isEmpty || name == null || name.isEmpty)) {
        final provider = Provider.of<EmergencyProvider>(context, listen: false);
        if (provider.hasEmergencyContact) {
          phone = provider.emergencyContact!.phone;
          name = provider.emergencyContact!.name;
        }
      }

      if (phone.isEmpty) {
        debugPrint("Acil durum: Telefon numarası bulunamadı!");
        return;
      }

      // Önce hızlı konum dene, yoksa konum açmayı dene
      Position? position = await _getLocationQuick();
      
      if (position == null) {
        position = await _getLocationWithAutoEnable();
      }

      String message;
      if (position != null) {
        final latitude = position.latitude;
        final longitude = position.longitude;
        message = "ACİL DURUM! ${name != null && name.isNotEmpty ? '$name,' : ''} yardım gerekiyor! Şu an bu konumdayım: https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
      } else {
        message = "ACİL DURUM! ${name != null && name.isNotEmpty ? '$name,' : ''} yardım gerekiyor! (Konum bilgisi alınamadı)";
        debugPrint("⚠️ Konum alınamadı ama WhatsApp yine de gönderilecek");
      }

      await platform.invokeMethod('sendWhatsApp', {"phone": phone, "message": message});
      debugPrint("✅ Acil durum WhatsApp mesajı gönderildi");
    } catch (e) {
      debugPrint("WhatsApp gönderim hatası: $e");
    }
  }

  // Tüm acil durum kişilerine mesaj gönder
  static Future<void> sendToAllContacts(BuildContext context) async {
    final provider = Provider.of<EmergencyProvider>(context, listen: false);

    if (!provider.hasEmergencyContact) {
      debugPrint("Acil durum: Kayıtlı acil durum kişisi bulunamadı!");
      return;
    }

    // Önce konumu bir kere al
    debugPrint("📍 Tüm kişiler için konum alınıyor...");
    Position? position = await _getLocationQuick();
    
    if (position == null) {
      debugPrint("📍 Konum kapalı, açılması deneniyor...");
      position = await _getLocationWithAutoEnable();
    }

    String locationInfo;
    if (position != null) {
      locationInfo = "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";
    } else {
      locationInfo = "(Konum bilgisi alınamadı)";
    }

    // Tüm kişilere gönder
    for (final contact in provider.sortedContacts) {
      if (contact.phone.isEmpty) continue;

      String message = "ACİL DURUM! ${contact.name.isNotEmpty ? '${contact.name},' : ''} yardım gerekiyor! Şu an bu konumdayım: $locationInfo";

      if (contact.sendSMS) {
        try {
          await platform.invokeMethod('sendSMS', {"phone": contact.phone, "message": message});
          debugPrint("✅ SMS gönderildi: ${contact.name} (${contact.phone})");
        } catch (e) {
          debugPrint("⚠️ SMS gönderme hatası (${contact.name}): $e");
        }
      }

      if (contact.sendWhatsApp) {
        try {
          await platform.invokeMethod('sendWhatsApp', {"phone": contact.phone, "message": message});
          debugPrint("✅ WhatsApp gönderildi: ${contact.name} (${contact.phone})");
        } catch (e) {
          debugPrint("⚠️ WhatsApp gönderme hatası (${contact.name}): $e");
        }
      }
      
      // Kişiler arasında küçük bir bekleme (rate limiting için)
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  static Future<void> sendAutomaticEmergencyAlert(BuildContext context) async {
    final provider = Provider.of<EmergencyProvider>(context, listen: false);

    if (!provider.hasEmergencyContact) {
      debugPrint("Acil durum: Kayıtlı acil durum kişisi bulunamadı!");
      return;
    }

    // Tüm kişilere gönder
    await sendToAllContacts(context);
  }

  // Arka planda çalışması için context gerektirmeyen metod
  static Future<void> sendDirectEmergencyAlert() async {
    try {
      debugPrint("⏱️ Arka plan acil durum mesajı başlatılıyor");
      
      final prefs = await SharedPreferences.getInstance();
      
      // Önce yeni format (çoklu kişi) dene
      List<EmergencyContact> contacts = [];
      final contactsJson = prefs.getString('emergency_contacts');
      
      if (contactsJson != null) {
        final List<dynamic> contactsList = jsonDecode(contactsJson);
        contacts = contactsList
            .map((e) => EmergencyContact.fromMap(e as Map<String, dynamic>))
            .toList();
      } else {
        // Eski format uyumluluğu
        final oldContactJson = prefs.getString('emergency_contact');
        if (oldContactJson != null) {
          final contactMap = jsonDecode(oldContactJson) as Map<String, dynamic>;
          contacts = [EmergencyContact.fromMap(contactMap)];
        }
      }

      if (contacts.isEmpty) {
        debugPrint("Acil durum: Kayıtlı acil durum kişisi bulunamadı!");
        return;
      }

      // Konum bilgisini al
      debugPrint("📍 Arka plan için konum alınıyor...");
      Position? position = await _getLocationQuick();
      
      if (position == null) {
        position = await _getLocationWithAutoEnable();
      }

      String locationInfo;
      if (position != null) {
        locationInfo = "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";
        debugPrint("✅ Konum alındı: ${position.latitude}, ${position.longitude}");
      } else {
        locationInfo = "(Konum bilgisi alınamadı)";
        debugPrint("⚠️ Konum alınamadı ama acil durum mesajı yine de gönderilecek");
      }

      // Tüm kişilere gönder
      for (final contact in contacts) {
        if (contact.phone.isEmpty) continue;

        String message = "ACİL DURUM! ${contact.name.isNotEmpty ? '${contact.name},' : ''} yardım gerekiyor! Şu an bu konumdayım: $locationInfo";

        if (contact.sendSMS) {
          try {
            debugPrint("📤 Direkt SMS gönderiliyor: ${contact.phone}");
            await platform.invokeMethod('sendSMS', {"phone": contact.phone, "message": message});
            debugPrint("✅ SMS gönderildi: ${contact.name}");
          } catch (e) {
            debugPrint("⚠️ SMS gönderme hatası: $e");
          }
        }

        if (contact.sendWhatsApp) {
          try {
            debugPrint("📤 Direkt WhatsApp gönderiliyor: ${contact.phone}");
            await platform.invokeMethod('sendWhatsApp', {"phone": contact.phone, "message": message});
            debugPrint("✅ WhatsApp gönderildi: ${contact.name}");
          } catch (e) {
            debugPrint("⚠️ WhatsApp gönderme hatası: $e");
          }
        }

        await Future.delayed(const Duration(milliseconds: 500));
      }

      debugPrint("✅ Tüm acil durum mesajları gönderildi");
    } catch (e) {
      debugPrint("⚠️ Direkt acil durum mesajı gönderirken hata: $e");
    }
  }
}
