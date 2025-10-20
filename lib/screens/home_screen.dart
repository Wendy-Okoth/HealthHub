import 'package:flutter/material.dart';
import 'tracker_screen.dart';
import 'tips_screen.dart';
import 'checkin_screen.dart';
import 'map_view.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> features = [
    {'title': 'Health Tracker', 'screen': TrackerScreen()},
    {'title': 'Wellness Tips', 'screen': TipsScreen()},
    {'title': 'Daily Check-in', 'screen': CheckInScreen()},
    {'title': 'Nearby Clinics', 'screen': MapView()},
  ];

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HealthHub')),
      body: ListView.builder(
        itemCount: features.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(features[index]['title']),
            trailing: Icon(Icons.arrow_forward),
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
