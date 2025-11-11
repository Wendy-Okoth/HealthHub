import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/notifications.dart';
import 'services/theme_service.dart'; // ✅ ThemeService

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://amnttxgxzsmcrxijnvkr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFtbnR0eGd4enNtY3J4aWpudmtyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA5NjY1MDEsImV4cCI6MjA3NjU0MjUwMX0.kP4Z2_eAX5uf0Ez1IhWXUAe0pfRbmmsTi_jdPK8aVuo',
  );

  await initializeNotifications();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: const HealthHubApp(),
    ),
  );
}

class HealthHubApp extends StatelessWidget {
  const HealthHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    final themeService = Provider.of<ThemeService>(context);

    return MaterialApp(
      title: 'HealthHub',
      themeMode: themeService.themeMode, // ✅ Controlled by ThemeService
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent,
            foregroundColor: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.greenAccent),
      ),
      home: session == null ? const LoginScreen() : const HomeScreen(),
    );
  }
}
