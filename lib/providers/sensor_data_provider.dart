import 'package:flutter/foundation.dart';

class SensorDataProvider with ChangeNotifier {
  int heartRate = 0;
  double bodyTemperature = 0.0;
  double externalTemperature = 0.0;
  int phoneCharge = 67;
  int battery1Charge = 34;
  int battery2Charge = 56;
  double latitude = 0.0;
  double longitude = 0.0;
  bool heatingEnabled = false;
  bool coolingEnabled = false;

  void toggleHeating() {
    heatingEnabled = !heatingEnabled;
    notifyListeners();
  }

  void updateWithBluetoothData(int bpm, double temp) {
    heartRate = bpm;
    bodyTemperature = temp;
    notifyListeners();
  }
}
