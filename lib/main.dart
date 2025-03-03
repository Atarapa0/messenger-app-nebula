import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages, implementation_imports
import 'package:gotrue/src/subscription.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url:
        'https://bmaoxcraznlbestcszps.supabase.co', // Supabase URL'nizi buraya yazın
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJtYW94Y3Jhem5sYmVzdGNzenBzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA5MzM1ODEsImV4cCI6MjA1NjUwOTU4MX0.v6Lfx5slZ3BWkA9EpDFzpXTk5HNnfCfYMN54Z5VUMWU', // Supabase Anonim Anahtarınızı buraya yazın
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nebula Chat',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.indigo,
          brightness: Brightness.light,
          accentColor: Colors.pinkAccent,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.indigo,
          brightness: Brightness.dark,
          accentColor: Colors.pinkAccent,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: ThemeMode.system,
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        _updateUserStatus('online');
      } else if (event == AuthChangeEvent.signedOut) {
        _updateUserStatus('offline');
      }
    });
  }

  Future<void> _updateUserStatus(String status) async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        supabase.from('users').update({
          'status': status,
          'last_seen': DateTime.now().toIso8601String(),
        }).eq('id', user.id);
      } catch (e) {
        if (kDebugMode) {
          print('Error updating user status: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Stream.fromIterable([AuthState(supabase.auth.currentSession)]),
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        if (session != null) {
          return HomeScreen();
        } else {
          return AuthScreen();
        }
      },
    );
  }
}

class AuthState {
  final Session? session;
  AuthState(this.session);
}

extension on GotrueSubscription Function(Callback callback) {
  void listen(Null Function(dynamic data) param0) {}
}
