import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tracker_screen.dart';
import 'tips_screen.dart';
import 'checkin_screen.dart';
import 'map_view.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> features = [
    {'title': 'Health Tracker', 'screen': TrackerScreen()},
    {'title': 'Wellness Tips', 'screen': TipsScreen()},
    {'title': 'Daily Check-in', 'screen': CheckInScreen()},
    {'title': 'Nearby Clinics', 'screen': MapView()},
  ];

  HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthHub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: features.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(features[index]['title']),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => features[index]['screen']),
            ),
          );
        },
      ),
    );
  }
}
