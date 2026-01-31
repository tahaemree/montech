# 🧥 MonTech - Akıllı Mont Mobil Uygulaması

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.x-blue?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Platform-Android-green?logo=android" alt="Android">
  <img src="https://img.shields.io/badge/Version-4.0-orange" alt="Version">
</p>

<p align="center">
  <b>Akıllı mont teknolojisi ile güvenliğiniz bir adım önde!</b>
</p>

---

## 📋 Proje Hakkında

MonTech, akıllı mont ile entegre çalışan bir Flutter mobil uygulamasıdır. Uygulama, Bluetooth üzerinden akıllı mont ile iletişim kurarak kullanıcının sağlık verilerini izler ve acil durumlarda otomatik olarak yardım çağrısı gönderir.

### 🎯 Temel Özellikler

- **📡 Bluetooth Bağlantısı**: Mont ile kablosuz iletişim
- **❤️ Sağlık İzleme**: Nabız ve vücut sıcaklığı takibi
- **🌡️ Çevre Sıcaklığı**: Dış ortam sıcaklık ölçümü
- **🚨 Acil Durum Sistemi**: Otomatik SMS/WhatsApp ile konum paylaşımı
- **📊 Grafik Analizi**: Sağlık verilerinin görsel takibi
- **🗺️ Konum Servisleri**: GPS ile konum takibi
- **🔔 Bildirimler**: Bağlantı durumu ve uyarı bildirimleri

---

## 🆕 v4.0 Yenilikler

### ✨ Yeni Özellikler

1. **Çoklu Acil Durum Kişisi Desteği**
   - Birden fazla acil durum kişisi ekleyebilme
   - Drag & drop ile öncelik sıralaması
   - Her kişi için ayrı SMS/WhatsApp tercihi

2. **Otomatik Bluetooth Yeniden Bağlanma**
   - Uygulama açıldığında son bağlı cihaza otomatik bağlanma
   - Bağlantı koptuğunda 3 deneme ile yeniden bağlanma
   - Bağlantı durumu bildirimleri

3. **Gelişmiş Konum Yönetimi**
   - Konum kapalıysa otomatik açma özelliği
   - Konum doğruluğu için 5 saniye bekleme
   - Konum alınamazsa bile mesaj gönderme (fallback)

4. **Modern Login Ekranı**
   - Animasyonlu giriş deneyimi
   - Dark mode desteği
   - Yeniden tasarlanmış UI/UX

5. **Ana Sayfa Bluetooth Durumu**
   - Bağlantı durumu kartı
   - Son bağlı cihaz bilgisi
   - Tek tıkla yeniden tarama

---

## 🏗️ Proje Yapısı

```
lib/
├── main.dart                 # Uygulama giriş noktası
├── models/
│   ├── emergency_contact.dart    # Acil durum kişisi modeli
│   └── sensor_data.dart          # Sensör veri modeli
├── providers/
│   ├── auth_provider.dart        # Kimlik doğrulama
│   ├── bluetooth_provider.dart   # Bluetooth yönetimi
│   ├── emergency_provider.dart   # Acil durum kişileri
│   ├── navigation_provider.dart  # Navigasyon
│   ├── sensor_data_provider.dart # Sensör verileri
│   └── theme_provider.dart       # Tema yönetimi
├── screens/
│   ├── login_screen.dart         # Giriş ekranı
│   ├── navigation_screen.dart    # Ana navigasyon
│   ├── home_screen.dart          # Ana sayfa
│   ├── bluetooth_screen.dart     # Bluetooth ayarları
│   ├── chart_screen.dart         # Grafikler
│   ├── map_screen.dart           # Harita
│   ├── settings_screen.dart      # Ayarlar
│   └── emergency_contact_screen.dart  # Acil durum kişileri
├── services/
│   ├── background_service.dart   # Arka plan servisi
│   ├── database_service.dart     # SQLite veritabanı
│   └── emergency_service.dart    # Acil durum işlemleri
├── utils/
│   └── event_bus.dart            # Event yönetimi
└── widgets/
    ├── custom_appbar.dart        # Özel uygulama çubuğu
    ├── custom_button.dart        # Özel buton
    └── emergency_handler.dart    # Acil durum işleyici
```

---

## 📱 Ekran Görüntüleri

| Ana Sayfa | Bluetooth | Grafikler | Acil Durum |
|:---------:|:---------:|:---------:|:----------:|
| Sensör verileri | Cihaz bağlantısı | Veri analizi | Kişi yönetimi |

---

## 🔧 Kurulum

### Gereksinimler

- Flutter SDK 3.x
- Dart SDK 3.x
- Android Studio / VS Code
- Android cihaz (Bluetooth test için)

### Adımlar

1. **Repoyu klonlayın**
```bash
git clone https://github.com/tahaemree/montech.git
cd montech
```

2. **Bağımlılıkları yükleyin**
```bash
flutter pub get
```

3. **Uygulamayı çalıştırın**
```bash
flutter run
```

---

## 📦 Bağımlılıklar

| Paket | Kullanım |
|-------|----------|
| `provider` | State management |
| `flutter_blue_plus` | Bluetooth iletişimi |
| `geolocator` | Konum servisleri |
| `google_maps_flutter` | Harita görüntüleme |
| `fl_chart` | Grafik çizimi |
| `sqflite` | Yerel veritabanı |
| `shared_preferences` | Ayar depolama |
| `flutter_local_notifications` | Bildirimler |
| `flutter_background_service` | Arka plan servisi |
| `battery_plus` | Batarya durumu |
| `permission_handler` | İzin yönetimi |

---

## 🚨 Acil Durum Sistemi

### Tetikleme Yolları

1. **Mont Üzerinden**: Mont "AD" (Acil Durum) kodu gönderdiğinde
2. **Uygulama Üzerinden**: Ana sayfadaki acil durum butonu
3. **Arka Plan**: Uygulama kapalıyken bile çalışır

### Mesaj İçeriği

```
ACİL DURUM! [Kişi Adı], yardım gerekiyor! 
Şu an bu konumdayım: https://maps.google.com/...
```

---

## 📡 Bluetooth Protokolü

### Veri Formatı (Mont → Uygulama)

```
ic36.5      # İç sıcaklık (°C)
bpm72       # Nabız (bpm)
dis25.3     # Dış sıcaklık (°C)
```

### Acil Durum Sinyali

```
AD          # Acil Durum tetikleyici
```

---

## 🔐 İzinler

| İzin | Açıklama |
|------|----------|
| `BLUETOOTH` | Bluetooth bağlantısı |
| `BLUETOOTH_SCAN` | Cihaz tarama |
| `BLUETOOTH_CONNECT` | Cihaz bağlantısı |
| `ACCESS_FINE_LOCATION` | Hassas konum |
| `ACCESS_BACKGROUND_LOCATION` | Arka plan konum |
| `SEND_SMS` | SMS gönderme |
| `FOREGROUND_SERVICE` | Arka plan servisi |

---

## 👥 Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Commit edin (`git commit -m 'Add some AmazingFeature'`)
4. Push edin (`git push origin feature/AmazingFeature`)
5. Pull Request açın

---

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

---

## 📞 İletişim

- **Geliştirici**: Taha Emre
- **GitHub**: [@tahaemree](https://github.com/tahaemree)

---

<p align="center">
  <b>MonTech v4.0</b> - Güvenliğiniz bizim önceliğimiz 🛡️
</p>
