import 'package:flutter/material.dart';

class CheckInScreen extends StatefulWidget {
  @override
  _CheckInScreenState createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  String mood = 'Neutral';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daily Check-in')),
      body: Column(
        children: [
          Text('How are you feeling today?', style: TextStyle(fontSize: 18)),
          DropdownButton<String>(
            value: mood,
            items: [
              'Happy',
              'Neutral',
              'Stressed',
              'Sad',
            ].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (val) => setState(() => mood = val!),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Mood saved: $mood')));
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
