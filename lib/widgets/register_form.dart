import 'package:flutter/material.dart';
import '../utils/constants.dart';

class RegisterForm extends StatefulWidget {
  final VoidCallback onToggleForm;

  const RegisterForm({super.key, required this.onToggleForm});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final currentState = _formKey.currentState;
    if (currentState == null || !currentState.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Register user with Supabase Auth
      final response = await supabase.auth.signUp(
        _emailController.text.trim(),
        _passwordController.text,
        userMetadata: {
          'username': _usernameController.text.trim(),
        },
      );

      final error = response.error;
      if (error != null) {
        throw error.message;
      }

      final user = response.user;
      // Create user profile in database
      if (user != null) {
        supabase.from('users').insert({
          'id': user.id,
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } else {
        throw 'Kullanıcı oluşturulamadı';
      }
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
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Kayıt Ol',
            style: AppTextStyles.heading,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Kullanıcı Adı',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Lütfen kullanıcı adı girin';
              }
              if (value.length < 3) {
                return 'Kullanıcı adı en az 3 karakter olmalı';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'E-posta',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Lütfen e-posta adresinizi girin';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Geçerli bir e-posta adresi girin';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Şifre',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Lütfen şifre girin';
              }
              if (value.length < 6) {
                return 'Şifre en az 6 karakter olmalı';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Şifre Tekrar',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Lütfen şifrenizi tekrar girin';
              }
              if (value != _passwordController.text) {
                return 'Şifreler eşleşmiyor';
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
                textAlign: TextAlign.center,
              ),
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: _isLoading ? null : _register,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text('Kayıt Ol'),
          ),
          SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: widget.onToggleForm,
            child: Text('Zaten hesabınız var mı? Giriş yapın'),
          ),
        ],
      ),
    );
  }
}
