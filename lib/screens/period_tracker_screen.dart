import 'package:flutter/material.dart';

class PeriodTrackerScreen extends StatefulWidget {
  const PeriodTrackerScreen({super.key});

  @override
  State<PeriodTrackerScreen> createState() => _PeriodTrackerScreenState();
}

class _PeriodTrackerScreenState extends State<PeriodTrackerScreen> {
  DateTime? _lastPeriodDate;
  int _cycleLength = 28;
  DateTime? _nextPeriodDate;

  void _calculateNextPeriod() {
    if (_lastPeriodDate != null && _cycleLength > 0) {
      setState(() {
        _nextPeriodDate = _lastPeriodDate!.add(Duration(days: _cycleLength));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Period Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: Text(
                _lastPeriodDate == null
                    ? 'Select Last Period Start Date'
                    : 'Last Period: ${_lastPeriodDate!.toLocal().toString().split(' ')[0]}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _lastPeriodDate = picked);
                  _calculateNextPeriod();
                }
              },
            ),
            TextFormField(
              initialValue: _cycleLength.toString(),
              decoration: const InputDecoration(
                labelText: 'Cycle Length (days)',
              ),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                _cycleLength = int.tryParse(val) ?? 28;
                _calculateNextPeriod();
              },
            ),
            const SizedBox(height: 20),
            if (_nextPeriodDate != null)
              Card(
                color: Colors.pink[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Next Expected Period: ${_nextPeriodDate!.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
