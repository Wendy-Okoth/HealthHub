import 'package:flutter/material.dart';

class TipsScreen extends StatelessWidget {
  final List<String> tips = [
    'Drink 2L of water daily 💧',
    'Get atleast 8 hours of sleep 😴',
    'Practice mindfulness 🧘‍♀️',
    'Eat fruits and vegetables 🥗',
    'Take screen breaks every hour 👀',
  ];

  TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wellness Tips')),
      body: ListView.builder(
        itemCount: tips.length,
        itemBuilder: (context, index) => ListTile(
          leading: Icon(Icons.health_and_safety),
          title: Text(tips[index]),
        ),
      ),
    );
  }
}
