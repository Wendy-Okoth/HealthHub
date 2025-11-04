import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class PeriodTrackerScreen extends StatefulWidget {
  const PeriodTrackerScreen({super.key});

  @override
  State<PeriodTrackerScreen> createState() => _PeriodTrackerScreenState();
}

class _PeriodTrackerScreenState extends State<PeriodTrackerScreen> {
  DateTime? _lastPeriodDate;
  int _cycleLength = 28;
  Map<DateTime, String> _phaseMap = {};

  void _generatePhaseMap() {
    if (_lastPeriodDate == null) return;

    _phaseMap.clear();
    for (int i = 0; i < _cycleLength; i++) {
      final date = _lastPeriodDate!.add(Duration(days: i));
      String phase;
      if (i <= 4) {
        phase = 'Menstruation';
      } else if (i <= 13) {
        phase = 'Follicular';
      } else if (i == 14) {
        phase = 'Ovulation';
      } else {
        phase = 'Luteal';
      }
      _phaseMap[DateTime(date.year, date.month, date.day)] = phase;
    }
  }

  Color _getPhaseColor(String? phase) {
    switch (phase) {
      case 'Menstruation':
        return Colors.redAccent;
      case 'Follicular':
        return Colors.orangeAccent;
      case 'Ovulation':
        return Colors.green;
      case 'Luteal':
        return Colors.purpleAccent;
      default:
        return Colors.grey.shade300;
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
                  setState(() {
                    _lastPeriodDate = picked;
                    _generatePhaseMap();
                  });
                }
              },
            ),
            TextFormField(
              initialValue: _cycleLength.toString(),
              decoration: const InputDecoration(labelText: 'Cycle Length (days)'),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                _cycleLength = int.tryParse(val) ?? 28;
                _generatePhaseMap();
              },
            ),
            const SizedBox(height: 20),
            if (_phaseMap.isNotEmpty)
              Expanded(
                child: TableCalendar(
                  focusedDay: DateTime.now(),
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, _) {
                      final phase = _phaseMap[DateTime(day.year, day.month, day.day)];
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _getPhaseColor(phase),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
