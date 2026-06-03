# 🧥 MonTech - Smart Jacket Companion App

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.x-blue?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Platform-Android-green?logo=android" alt="Android">
</p>

<p align="center">
  <b>Advanced smart jacket technology bringing safety and health monitoring to the next level.</b>
</p>

---

## 📋 Overview

MonTech is a comprehensive Flutter mobile application designed to interface seamlessly with smart jackets. Utilizing Bluetooth Low Energy (BLE), the app acts as the central hub for real-time health telemetry and an automated emergency response system, ensuring user safety in critical situations.

### 🎯 Core Capabilities

- **📡 Bluetooth Telemetry:** Robust, auto-reconnecting BLE communication with the jacket's hardware.
- **❤️ Health Monitoring:** Real-time tracking of vital signs including pulse (bpm) and body temperature.
- **🌡️ Environmental Sensors:** Continuous external ambient temperature measurement.
- **🚨 Automated SOS System:** Instantaneous dispatch of GPS coordinates via SMS/WhatsApp during emergencies.
- **📊 Data Analytics:** Interactive charts for visualizing historical health and sensor data.
- **🗺️ Location Services:** High-accuracy GPS tracking with fallback mechanisms.
- **🔔 Real-time Notifications:** Persistent connection state alerts and critical warnings.

---

## 🆕 What's New in v4.0

### ✨ Key Features

1. **Multi-Contact Emergency Dispatch**
   - Support for multiple emergency contacts with drag & drop prioritization.
   - Individualized routing preferences (SMS vs. WhatsApp) per contact.

2. **Resilient BLE Architecture**
   - Automatic reconnection to the last known device upon app launch.
   - Intelligent retry mechanisms (up to 3 attempts) on connection drop.

3. **Advanced Location Management**
   - Auto-enablement of hardware location services.
   - Fallback dispatch: Ensures SOS messages are sent even if GPS locks fail.

4. **Modernized UI/UX**
   - Fluid, animated authentication flows.
   - Native Dark Mode support.
   - Real-time connection status dashboard.

---

## 🏗️ Architecture

```text
lib/
├── main.dart                 # Application entry point
├── models/                   # Domain models (Sensors, Contacts)
├── providers/                # State management (Riverpod/Provider)
├── screens/                  # Feature-based UI workflows
├── services/                 # Core services (BLE, DB, Background, Location)
├── utils/                    # Event bus and utilities
└── widgets/                  # Reusable UI components
```

---

## 🔧 Installation & Setup

### Prerequisites

- Flutter SDK `3.x`
- Dart SDK `3.x`
- Android Device (Required for BLE and Background Service testing)

### Getting Started

1. **Clone the repository:**
```bash
git clone https://github.com/tahaemree/montech.git
cd montech
```

2. **Fetch dependencies:**
```bash
flutter pub get
```

3. **Run the application:**
```bash
flutter run
```

---

## 🚨 Emergency SOS Protocol

### Trigger Mechanisms

1. **Hardware Trigger:** The jacket transmits an `AD` (Acil Durum/Emergency) payload.
2. **Software Trigger:** Manual activation via the in-app SOS button.
3. **Background Execution:** Fully operational even when the app is minimized or terminated.

### Dispatch Payload Example

```text
EMERGENCY! [Contact Name], I need help immediately! 
My current location is: https://maps.google.com/...
```

---

## 📡 Hardware Communication Protocol

Data is streamed from the jacket to the mobile client in a strictly formatted payload:

```text
ic36.5      # Internal Body Temp (°C)
bpm72       # Heart Rate (bpm)
dis25.3     # External Ambient Temp (°C)
AD          # Emergency Trigger Flag
```

---

## 📄 License

This software is open-sourced under the **MIT License**.

You are free to use, modify, and distribute this software, provided that the original copyright and permission notice are included. Please see the [LICENSE](LICENSE) file for complete details.
