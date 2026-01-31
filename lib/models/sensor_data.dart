class SensorData {
  final int? id;
  final DateTime timestamp;
  final double internalTemperature;
  final double externalTemperature;
  final int heartRate;

  SensorData({
    this.id,
    required this.timestamp,
    required this.internalTemperature,
    required this.externalTemperature,
    required this.heartRate,
  });

  // Veritabanından map'e dönüştürme
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'internal_temperature': internalTemperature,
      'external_temperature': externalTemperature,
      'heart_rate': heartRate,
    };
  }

  // Map'ten SensorData nesnesine dönüştürme
  factory SensorData.fromMap(Map<String, dynamic> map) {
    return SensorData(
      id: map['id'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      internalTemperature: map['internal_temperature'],
      externalTemperature: map['external_temperature'],
      heartRate: map['heart_rate'],
    );
  }

  @override
  String toString() {
    return 'SensorData{id: $id, timestamp: $timestamp, internalTemp: $internalTemperature, externalTemp: $externalTemperature, heartRate: $heartRate}';
  }
}
