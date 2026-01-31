import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/emergency_provider.dart';
import '../models/emergency_contact.dart';
import '../widgets/custom_appbar.dart';

class EmergencyContactScreen extends StatefulWidget {
  const EmergencyContactScreen({super.key});

  @override
  State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Acil Durum Kişileri',
      ),
      body: Consumer<EmergencyProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Bilgi kartı
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Acil Durum Bilgileri',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mont acil durum sinyali gönderdiğinde, tüm kayıtlı kişilere otomatik mesaj gönderilir. Kişileri sürükleyerek öncelik sırasını değiştirebilirsiniz.',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Kişi listesi
              Expanded(
                child: provider.emergencyContacts.isEmpty
                    ? _buildEmptyState()
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: provider.emergencyContacts.length,
                        onReorder: (oldIndex, newIndex) {
                          if (newIndex > oldIndex) newIndex--;
                          provider.reorderContacts(oldIndex, newIndex);
                        },
                        itemBuilder: (context, index) {
                          final contact = provider.emergencyContacts[index];
                          return _buildContactCard(contact, index, provider);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(context, null),
        icon: const Icon(Icons.person_add),
        label: const Text('Kişi Ekle'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.contact_phone_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Henüz acil durum kişisi eklenmedi',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Güvenliğiniz için en az bir kişi ekleyin',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildContactCard(EmergencyContact contact, int index, EmergencyProvider provider) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      key: ValueKey(contact.id),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
              isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFF8F9FA),
            ],
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Stack(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.1),
                radius: 24,
                child: Text(
                  contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              // Öncelik badge
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(index),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          title: Text(
            contact.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(contact.phone),
                ],
              ),
              if (contact.relation.isNotEmpty) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.family_restroom, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(contact.relation, style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ],
              const SizedBox(height: 4),
              Row(
                children: [
                  if (contact.sendSMS)
                    _buildMethodChip('SMS', Colors.green),
                  if (contact.sendSMS && contact.sendWhatsApp)
                    const SizedBox(width: 6),
                  if (contact.sendWhatsApp)
                    _buildMethodChip('WhatsApp', Colors.teal),
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showAddEditDialog(context, contact),
                ),
              ),
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(context, contact, provider),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.drag_handle, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getPriorityColor(int index) {
    switch (index) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  void _showAddEditDialog(BuildContext context, EmergencyContact? contact) {
    final isEditing = contact != null;
    final nameController = TextEditingController(text: contact?.name ?? '');
    final phoneController = TextEditingController(text: contact?.phone ?? '');
    final relationController = TextEditingController(text: contact?.relation ?? '');
    bool sendSMS = contact?.sendSMS ?? true;
    bool sendWhatsApp = contact?.sendWhatsApp ?? false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                isEditing ? Icons.edit : Icons.person_add,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              Text(isEditing ? 'Kişiyi Düzenle' : 'Yeni Kişi Ekle'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Ad Soyad *',
                    hintText: 'Kişinin adı',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Telefon *',
                    hintText: '05XX XXX XX XX',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: relationController,
                  decoration: InputDecoration(
                    labelText: 'Yakınlık Derecesi',
                    hintText: 'Örn: Eş, Anne, Baba',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.family_restroom),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'İletişim Yöntemi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text('SMS ile bilgilendir'),
                  subtitle: const Text('Konum bilgisiyle SMS gönderilir'),
                  value: sendSMS,
                  onChanged: (value) {
                    setDialogState(() {
                      sendSMS = value ?? true;
                      if (!sendSMS && !sendWhatsApp) {
                        sendWhatsApp = true;
                      }
                    });
                  },
                  secondary: const Icon(Icons.sms, color: Colors.green),
                ),
                CheckboxListTile(
                  title: const Text('WhatsApp ile bilgilendir'),
                  subtitle: const Text('WhatsApp mesajı gönderilir'),
                  value: sendWhatsApp,
                  onChanged: (value) {
                    setDialogState(() {
                      sendWhatsApp = value ?? false;
                      if (!sendSMS && !sendWhatsApp) {
                        sendSMS = true;
                      }
                    });
                  },
                  secondary: const Icon(Icons.message, color: Colors.teal),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (nameController.text.isEmpty || phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ad ve telefon zorunludur')),
                  );
                  return;
                }

                if (phoneController.text.length < 10) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Geçerli bir telefon numarası girin')),
                  );
                  return;
                }

                final newContact = EmergencyContact(
                  id: contact?.id,
                  name: nameController.text.trim(),
                  phone: phoneController.text.trim(),
                  relation: relationController.text.trim(),
                  sendSMS: sendSMS,
                  sendWhatsApp: sendWhatsApp,
                  priority: contact?.priority ?? 999,
                );

                final provider = Provider.of<EmergencyProvider>(context, listen: false);
                
                if (isEditing) {
                  await provider.updateEmergencyContact(newContact);
                } else {
                  await provider.addEmergencyContact(newContact);
                }

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing ? 'Kişi güncellendi' : 'Kişi eklendi'),
                    ),
                  );
                }
              },
              child: Text(isEditing ? 'Güncelle' : 'Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, EmergencyContact contact, EmergencyProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Kişiyi Sil'),
          ],
        ),
        content: Text(
          '${contact.name} kişisini silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (contact.id != null) {
                await provider.deleteEmergencyContact(contact.id!);
              }
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${contact.name} silindi')),
                );
              }
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
