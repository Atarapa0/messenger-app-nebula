import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _soundEffects = true;
  final String _language = 'Türkçe';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // TODO: Ayarları yükle (SharedPreferences veya Supabase'den)
    setState(() {
      // Şimdilik varsayılan değerler
      _darkMode = Theme.of(context).brightness == Brightness.dark;
    });
  }

  Future<void> _saveSettings() async {
    // TODO: Ayarları kaydet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ayarlar kaydedildi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Görünüm ayarları
          _buildSectionHeader('Görünüm'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Karanlık Mod'),
                  subtitle: Text('Uygulamayı karanlık temada görüntüle'),
                  value: _darkMode,
                  onChanged: (value) {
                    setState(() {
                      _darkMode = value;
                    });
                    // TODO: Tema değiştirme işlevselliği
                  },
                ),
                ListTile(
                  title: Text('Dil'),
                  subtitle: Text(_language),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Dil seçme diyaloğu
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Bildirim ayarları
          _buildSectionHeader('Bildirimler'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Bildirimler'),
                  subtitle: Text('Yeni mesaj ve arkadaşlık istekleri için bildirimler'),
                  value: _notifications,
                  onChanged: (value) {
                    setState(() {
                      _notifications = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: Text('Ses Efektleri'),
                  subtitle: Text('Mesaj gönderme ve alma sırasında ses çal'),
                  value: _soundEffects,
                  onChanged: (value) {
                    setState(() {
                      _soundEffects = value;
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Hesap ayarları
          _buildSectionHeader('Hesap'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.lock),
                  title: Text('Şifre Değiştir'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Şifre değiştirme ekranı
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Hesabı Sil', style: TextStyle(color: Colors.red)),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showDeleteAccountDialog();
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Hakkında
          _buildSectionHeader('Hakkında'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Uygulama Hakkında'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Hakkında ekranı
                  },
                ),
                ListTile(
                  leading: Icon(Icons.description_outlined),
                  title: Text('Gizlilik Politikası'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Gizlilik politikası ekranı
                  },
                ),
                ListTile(
                  leading: Icon(Icons.help_outline),
                  title: Text('Yardım ve Destek'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Yardım ekranı
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // Kaydet butonu
          Center(
            child: ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
              child: Text('Ayarları Kaydet'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: AppTextStyles.subheading,
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hesabı Sil'),
        content: Text(
          'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz ve tüm verileriniz silinecektir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Hesap silme işlevi
              Navigator.pop(context);
            },
            child: Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
} 