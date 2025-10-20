import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://amnttxgxzsmcrxijnvkr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFtbnR0eGd4enNtY3J4aWpudmtyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA5NjY1MDEsImV4cCI6MjA3NjU0MjUwMX0.kP4Z2_eAX5uf0Ez1IhWXUAe0pfRbmmsTi_jdPK8aVuo',
  );
  runApp(const HealthHubApp());
}

class HealthHubApp extends StatelessWidget {
  const HealthHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      title: 'HealthHub',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: session == null ? const LoginScreen() : HomeScreen(),
    );
  }
}
