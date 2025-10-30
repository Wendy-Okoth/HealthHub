import 'package:flutter/material.dart';

class SleepTrackerScreen extends StatefulWidget {
  const SleepTrackerScreen({super.key});

  @override
  State<SleepTrackerScreen> createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> {
  DateTime _selectedDate = DateTime.now();
  double _sleepHours = 0;

  void _submitSleepLog() {
    // TODO: Save to Supabase or local storage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sleep log saved: $_sleepHours hrs on ${_selectedDate.toLocal().toString().split(' ')[0]}',
        ),
      ),
    );
    setState(() {
      _sleepHours = 0;
      _selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sleep Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: Text(
                'Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Hours Slept'),
              keyboardType: TextInputType.number,
              onChanged: (val) => _sleepHours = double.tryParse(val) ?? 0,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sleepHours > 0 ? _submitSleepLog : null,
              child: const Text('Save Sleep Log'),
            ),
          ],
        ),
      ),
    );
  }
}
