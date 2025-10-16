import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(HealthHubApp());

class HealthHubApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthHub',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: HomeScreen(),
    );
  }
}
