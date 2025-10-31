import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/notifications.dart';

class SleepTrackerScreen extends StatefulWidget {
  const SleepTrackerScreen({super.key});

  @override
  State<SleepTrackerScreen> createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> {
  DateTime _selectedDate = DateTime.now();
  double _sleepHours = 0;
  bool _loading = false;

  Future<void> _submitSleepLog() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _loading = true);

    await Supabase.instance.client.from('sleep_logs').upsert({
      'user_id': userId,
      'date': _selectedDate.toIso8601String().split('T').first,
      'hours': _sleepHours,
    });

    setState(() {
      _sleepHours = 0;
      _selectedDate = DateTime.now();
      _loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sleep log saved: $_sleepHours hrs on ${_selectedDate.toLocal().toString().split(' ')[0]}',
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchWeeklySleep() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final today = DateTime.now();
    final weekAgo = today.subtract(const Duration(days: 6));

    final response = await Supabase.instance.client
        .from('sleep_logs')
        .select()
        .eq('user_id', userId!)
        .gte('date', weekAgo.toIso8601String().split('T').first)
        .lte('date', today.toIso8601String().split('T').first)
        .order('date');

    return List<Map<String, dynamic>>.from(response);
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
              onPressed: _sleepHours > 0 && !_loading ? _submitSleepLog : null,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Save Sleep Log'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await scheduleSleepReminder();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sleep reminder set for 10 PM')),
                );
              },
              child: const Text('Enable Sleep Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
