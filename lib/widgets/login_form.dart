import 'package:flutter/material.dart';
import '../utils/constants.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onToggleForm;

  const LoginForm({super.key, required this.onToggleForm});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final currentState = _formKey.currentState;
    if (currentState == null || !currentState.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await supabase.auth.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Hata kontrolü
      if (response.data == null) {
        throw 'Giriş başarısız. Lütfen e-posta ve şifrenizi kontrol edin.';
      }

      // Kullanıcı kontrolü
      if (response.user == null) {
        throw 'Kullanıcı bulunamadı. Lütfen önce kayıt olun.';
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
            'Giriş Yap',
            style: AppTextStyles.heading,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
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
                return 'Lütfen şifrenizi girin';
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
            onPressed: _isLoading ? null : _login,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text('Giriş Yap'),
          ),
          SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: widget.onToggleForm,
            child: Text('Hesabınız yok mu? Kayıt olun'),
          ),
        ],
      ),
    );
  }
}
