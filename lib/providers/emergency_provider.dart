import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/emergency_contact.dart';

class EmergencyProvider with ChangeNotifier {
  List<EmergencyContact> _emergencyContacts = [];
  bool _isLoading = false;

  List<EmergencyContact> get emergencyContacts => _emergencyContacts;
  bool get isLoading => _isLoading;
  bool get hasEmergencyContact =>
      _emergencyContacts.isNotEmpty &&
      _emergencyContacts.any((c) => c.phone.isNotEmpty);

  // İlk acil durum kişisini getir (eski API uyumluluğu için)
  EmergencyContact? get emergencyContact =>
      _emergencyContacts.isNotEmpty ? _emergencyContacts.first : null;

  // Tüm aktif kişileri öncelik sırasına göre getir
  List<EmergencyContact> get sortedContacts {
    final sorted = List<EmergencyContact>.from(_emergencyContacts);
    sorted.sort((a, b) => a.priority.compareTo(b.priority));
    return sorted;
  }

  EmergencyProvider() {
    _loadEmergencyContacts();
  }

  Future<void> _loadEmergencyContacts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Önce yeni format (çoklu kişi) dene
      final contactsJson = prefs.getString('emergency_contacts');
      
      if (contactsJson != null) {
        final List<dynamic> contactsList = jsonDecode(contactsJson);
        _emergencyContacts = contactsList
            .map((e) => EmergencyContact.fromMap(e as Map<String, dynamic>))
            .toList();
        debugPrint("✅ ${_emergencyContacts.length} acil durum kişisi yüklendi");
      } else {
        // Eski format (tek kişi) uyumluluğu
        final oldContactJson = prefs.getString('emergency_contact');
        if (oldContactJson != null) {
          final contactMap = jsonDecode(oldContactJson) as Map<String, dynamic>;
          final contact = EmergencyContact.fromMap(contactMap);
          if (contact.phone.isNotEmpty) {
            _emergencyContacts = [contact];
            // Yeni formata migrate et
            await _saveEmergencyContacts();
            debugPrint("✅ Eski format yeni formata migrate edildi");
          }
        }
      }
    } catch (e) {
      debugPrint('Acil durum kişileri yüklenirken hata: $e');
      _emergencyContacts = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveEmergencyContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsList = _emergencyContacts.map((c) => c.toMap()).toList();
      await prefs.setString('emergency_contacts', jsonEncode(contactsList));
      
      // Eski API uyumluluğu için ilk kişiyi de kaydet
      if (_emergencyContacts.isNotEmpty) {
        await prefs.setString('emergency_contact', 
            jsonEncode(_emergencyContacts.first.toMap()));
      }
      
      debugPrint("✅ ${_emergencyContacts.length} acil durum kişisi kaydedildi");
    } catch (e) {
      debugPrint('Acil durum kişileri kaydedilirken hata: $e');
    }
  }

  // Yeni kişi ekle
  Future<void> addEmergencyContact(EmergencyContact contact) async {
    _isLoading = true;
    notifyListeners();

    try {
      // ID yoksa oluştur
      final newContact = contact.id == null
          ? contact.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString())
          : contact;
      
      _emergencyContacts.add(newContact);
      await _saveEmergencyContacts();
    } catch (e) {
      debugPrint('Acil durum kişisi eklenirken hata: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Kişi güncelle
  Future<void> updateEmergencyContact(EmergencyContact contact) async {
    _isLoading = true;
    notifyListeners();

    try {
      final index = _emergencyContacts.indexWhere((c) => c.id == contact.id);
      if (index != -1) {
        _emergencyContacts[index] = contact;
        await _saveEmergencyContacts();
      }
    } catch (e) {
      debugPrint('Acil durum kişisi güncellenirken hata: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Kişi sil
  Future<void> deleteEmergencyContact(String contactId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _emergencyContacts.removeWhere((c) => c.id == contactId);
      await _saveEmergencyContacts();
    } catch (e) {
      debugPrint('Acil durum kişisi silinirken hata: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Eski API uyumluluğu - tek kişi kaydet
  Future<void> saveEmergencyContact(EmergencyContact contact) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Eğer aynı ID varsa güncelle, yoksa ekle
      final existingIndex = _emergencyContacts.indexWhere((c) => c.id == contact.id);
      
      if (existingIndex != -1) {
        _emergencyContacts[existingIndex] = contact;
      } else if (_emergencyContacts.isEmpty) {
        // Hiç kişi yoksa ekle
        final newContact = contact.id == null
            ? contact.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString())
            : contact;
        _emergencyContacts.add(newContact);
      } else {
        // İlk kişiyi güncelle
        _emergencyContacts[0] = contact.copyWith(id: _emergencyContacts[0].id);
      }
      
      await _saveEmergencyContacts();
    } catch (e) {
      debugPrint('Acil durum kişisi kaydedilirken hata: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Öncelik sırasını değiştir
  Future<void> reorderContacts(int oldIndex, int newIndex) async {
    final contact = _emergencyContacts.removeAt(oldIndex);
    _emergencyContacts.insert(newIndex, contact);
    
    // Öncelikleri yeniden ata
    for (int i = 0; i < _emergencyContacts.length; i++) {
      _emergencyContacts[i] = _emergencyContacts[i].copyWith(priority: i + 1);
    }
    
    await _saveEmergencyContacts();
    notifyListeners();
  }

  // Tümünü sil
  Future<void> deleteAllContacts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('emergency_contacts');
      await prefs.remove('emergency_contact');
      _emergencyContacts = [];
    } catch (e) {
      debugPrint('Acil durum kişileri silinirken hata: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
