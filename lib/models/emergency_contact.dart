class EmergencyContact {
  final String? id; // Benzersiz ID (birden fazla kişi için)
  final String name;
  final String phone;
  final String relation;
  final bool sendSMS;
  final bool sendWhatsApp;
  final int priority; // Öncelik sırası (1 = en yüksek)

  EmergencyContact({
    this.id,
    required this.name,
    required this.phone,
    required this.relation,
    this.sendSMS = true,
    this.sendWhatsApp = false,
    this.priority = 1,
  });

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'],
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      relation: map['relation'] ?? '',
      sendSMS: map['sendSMS'] ?? true,
      sendWhatsApp: map['sendWhatsApp'] ?? false,
      priority: map['priority'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'phone': phone,
      'relation': relation,
      'sendSMS': sendSMS,
      'sendWhatsApp': sendWhatsApp,
      'priority': priority,
    };
  }

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phone,
    String? relation,
    bool? sendSMS,
    bool? sendWhatsApp,
    int? priority,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relation: relation ?? this.relation,
      sendSMS: sendSMS ?? this.sendSMS,
      sendWhatsApp: sendWhatsApp ?? this.sendWhatsApp,
      priority: priority ?? this.priority,
    );
  }
}
