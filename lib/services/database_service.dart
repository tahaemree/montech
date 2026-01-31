import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sensor_data.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService _instance = DatabaseService._internal();
  
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'sensor_data.db');
      
      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDatabase,
      );
    } catch (e) {
      debugPrint("❌ Veritabanı başlatma hatası: $e");
      rethrow;
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE sensor_data(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp INTEGER NOT NULL,
          internal_temperature REAL NOT NULL,
          external_temperature REAL NOT NULL,
          heart_rate INTEGER NOT NULL
        )
      ''');
      
      // İndeks oluştur (hızlı sorgular için)
      await db.execute('''
        CREATE INDEX idx_timestamp ON sensor_data(timestamp)
      ''');
      
      debugPrint("✅ Veritabanı tabloları oluşturuldu");
    } catch (e) {
      debugPrint("❌ Veritabanı tablo oluşturma hatası: $e");
      rethrow;
    }
  }

  // Veri ekleme
  Future<int> insertSensorData(SensorData data) async {
    try {
      final db = await database;
      final id = await db.insert('sensor_data', data.toMap());
      debugPrint("📝 Veri kaydedildi: ID=$id, ${data.toString()}");
      return id;
    } catch (e) {
      debugPrint("❌ Veri kaydetme hatası: $e");
      return -1;
    }
  }

  // Belirli zaman aralığındaki verileri getirme
  Future<List<SensorData>> getSensorDataByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'sensor_data',
        where: 'timestamp BETWEEN ? AND ?',
        whereArgs: [
          startDate.millisecondsSinceEpoch,
          endDate.millisecondsSinceEpoch,
        ],
        orderBy: 'timestamp ASC',
      );

      return List.generate(maps.length, (i) {
        return SensorData.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint("❌ Veri okuma hatası: $e");
      return [];
    }
  }

  // Son N adet veriyi getirme
  Future<List<SensorData>> getLatestSensorData(int limit) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'sensor_data',
        orderBy: 'timestamp DESC',
        limit: limit,
      );

      return List.generate(maps.length, (i) {
        return SensorData.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint("❌ Son veriler okuma hatası: $e");
      return [];
    }
  }

  // Bugünkü verileri getirme
  Future<List<SensorData>> getTodaysSensorData() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return await getSensorDataByDateRange(startOfDay, endOfDay);
  }

  // Son 1 saatteki verileri getirme
  Future<List<SensorData>> getLastHourData() async {
    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));
    
    return await getSensorDataByDateRange(oneHourAgo, now);
  }

  // Toplam kayıt sayısını getirme
  Future<int> getTotalRecordCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM sensor_data');
      return result.first['count'] as int;
    } catch (e) {
      debugPrint("❌ Kayıt sayısı okuma hatası: $e");
      return 0;
    }
  }

  // Eski verileri temizleme (performans için)
  Future<void> cleanOldData({int daysToKeep = 30}) async {
    try {
      final db = await database;
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      
      final deletedCount = await db.delete(
        'sensor_data',
        where: 'timestamp < ?',
        whereArgs: [cutoffDate.millisecondsSinceEpoch],
      );
      
      debugPrint("🧹 Eski veriler temizlendi: $deletedCount kayıt silindi");
    } catch (e) {
      debugPrint("❌ Veri temizleme hatası: $e");
    }
  }

  // Veritabanını kapat
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      debugPrint("🔒 Veritabanı kapatıldı");
    }
  }
}
