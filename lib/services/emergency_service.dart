import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class EmergencyService {
  static const platform = MethodChannel('com.example.montech/emergency');

  static Future<void> sendEmergencySMS() async {
    try {
      await platform.invokeMethod('sendSMS');
    } catch (e) {
      debugPrint("SMS gönderme hatası: $e");
    }
  }

  static Future<void> sendWhatsAppWithLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final latitude = position.latitude;
      final longitude = position.longitude;
      final message =
          "Acil durum! Lütfen yardım edin!\nKonumum: https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";

      await platform.invokeMethod('sendWhatsApp', {"message": message});
    } catch (e) {
      debugPrint("WhatsApp gönderim hatası: $e");
    }
  }
}





// import 'package:url_launcher/url_launcher.dart';
// import 'package:geolocator/geolocator.dart';

// class EmergencyService {
//   static Future<void> sendEmergencySMS() async {
//     final Uri smsUri = Uri(
//       scheme: 'sms',
//       path: '+905443471929',
//       queryParameters: {'body': 'Acil durum! Lütfen yardım edin!'},
//     );

//     if (await canLaunchUrl(smsUri)) {
//       await launchUrl(smsUri, mode: LaunchMode.externalApplication);
//     } else {
//       print("SMS uygulaması başlatılamadı.");
//     }
//   }

//   static Future<void> sendWhatsAppWithLocation() async {
//     try {
//       final position = await _getCurrentPosition();
//       final latitude = position.latitude;
//       final longitude = position.longitude;

//       final message = Uri.encodeComponent(
//         "Acil durum! Lütfen yardım edin!\nKonumum: https://www.google.com/maps/search/?api=1&query=$latitude,$longitude",
//       );

//       final whatsappUrl = Uri.parse("https://wa.me/905443471929?text=$message");

//       if (await canLaunchUrl(whatsappUrl)) {
//         await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
//       } else {
//         print("WhatsApp açılamadı.");
//       }
//     } catch (e) {
//       print("Konum alınamadı veya hata oluştu: $e");
//     }
//   }

//   static Future<Position> _getCurrentPosition() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       await Geolocator.openLocationSettings();
//       throw Exception('Konum servisi kapalı');
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         throw Exception('Konum izni reddedildi');
//       }
//     }

//     return await Geolocator.getCurrentPosition();
//   }
// }




// import 'package:url_launcher/url_launcher.dart';

// class EmergencyService {
//   static Future<void> sendEmergencySMS() async {
//     final Uri smsUri = Uri(
//       scheme: 'sms',
//       path: '+905443471929',
//       queryParameters: {'body': 'Acil durum! Lütfen yardım edin!'},
//     );

//     if (await canLaunchUrl(smsUri)) {
//       await launchUrl(smsUri, mode: LaunchMode.externalApplication);
//     } else {
//       print("SMS uygulaması başlatılamadı.");
//     }
//   }

//   static Future<void> sendWhatsAppMessage() async {
//     final phone = '905538354440'; // ✅ Başında '90' olacak, '+' veya '0' OLMAYACAK
//     final message = Uri.encodeComponent("Acil durum! Lütfen yardım edin!");
//     final url = Uri.parse("https://wa.me/$phone?text=$message");

//     if (await canLaunchUrl(url)) {
//       await launchUrl(url, mode: LaunchMode.externalApplication);
//     } else {
//       print("WhatsApp mesajı başlatılamadı. WhatsApp yüklü mü?");
//     }
//   }
// }
