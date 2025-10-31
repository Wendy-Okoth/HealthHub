import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
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
  List<Map<String, dynamic>> _weeklySleep = [];

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

    await _loadWeeklySleep();
  }

  Future<void> _loadWeeklySleep() async {
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

    setState(() {
      _weeklySleep = List<Map<String, dynamic>>.from(response);
    });
  }

  List<BarChartGroupData> _buildChartBars() {
    final today = DateTime.now();
    final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
    return days.map((day) {
      final dateStr = day.toIso8601String().split('T').first;
      final entry = _weeklySleep.firstWhere(
        (e) => e['date'] == dateStr,
        orElse: () => {'hours': 0},
      );
      final hours = (entry['hours'] as num).toDouble();
      return BarChartGroupData(
        x: day.weekday,
        barRods: [BarChartRodData(toY: hours, color: Colors.teal, width: 16)],
      );
    }).toList();
  }

  Widget _buildChart() {
    return _weeklySleep.isEmpty
        ? const Text('No sleep data for the past week')
        : SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        const days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun',
                        ];
                        return Text(days[(value.toInt() - 1) % 7]);
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _buildChartBars(),
              ),
            ),
          );
  }

  @override
  void initState() {
    super.initState();
    _loadWeeklySleep();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sleep Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
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
                onPressed: _sleepHours > 0 && !_loading
                    ? _submitSleepLog
                    : null,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Save Sleep Log'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await scheduleSleepReminder();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sleep reminder set for 10 PM'),
                    ),
                  );
                },
                child: const Text('Enable Sleep Reminder'),
              ),
              const SizedBox(height: 30),
              const Text(
                'Weekly Sleep Chart',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildChart(),
            ],
          ),
        ),
      ),
    );
  }
}
