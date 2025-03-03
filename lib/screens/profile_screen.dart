import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool _isLoading = true;
  String? _profilePictureUrl;
  File? _selectedImage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response =
          supabase.from('users').select().eq('id', userId).single();

      // response artık bir Map<String, dynamic>
      final userData = response as Map<String, dynamic>;

      setState(() {
        _usernameController.text = userData['username'] ?? '';
        _profilePictureUrl = userData['profile_picture'];
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading profile: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Upload profile picture if selected
      if (_selectedImage != null) {
        final fileName = 'profile_$userId.jpg';
        final filePath = 'profiles/$fileName';

        await supabase.storage.from('avatars').upload(
              filePath,
              _selectedImage!,
            );

        // getPublicUrl'in dönüş değerini String'e dönüştürüyoruz
        final imageUrlResponse =
            supabase.storage.from('avatars').getPublicUrl(filePath);
        _profilePictureUrl = imageUrlResponse.toString();
      }

      // Update user profile
      supabase.from('users').update({
        'username': _usernameController.text.trim(),
        'profile_picture': _profilePictureUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil güncellendi')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : _profilePictureUrl != null
                                    ? NetworkImage(_profilePictureUrl!)
                                    : null,
                            child: (_selectedImage == null &&
                                    _profilePictureUrl == null)
                                ? Icon(Icons.person, size: 50)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Kullanıcı Adı',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Kullanıcı adı gerekli';
                        }
                        if (value.length < 3) {
                          return 'Kullanıcı adı en az 3 karakter olmalı';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppSpacing.md),
                    if (_errorMessage != null)
                      Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.md),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text('Profili Güncelle'),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hesap Bilgileri',
                              style: AppTextStyles.subheading,
                            ),
                            Divider(),
                            ListTile(
                              leading: Icon(Icons.email),
                              title: Text('E-posta'),
                              subtitle:
                                  Text(supabase.auth.currentUser?.email ?? ''),
                              dense: true,
                            ),
                            ListTile(
                              leading: Icon(Icons.calendar_today),
                              title: Text('Katılma Tarihi'),
                              subtitle: Text(
                                supabase.auth.currentUser?.createdAt != null
                                    ? _formatDate(DateTime.parse(
                                        supabase.auth.currentUser!.createdAt))
                                    : '',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
