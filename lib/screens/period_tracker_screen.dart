import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

class PeriodTrackerScreen extends StatefulWidget {
  const PeriodTrackerScreen({super.key});

  @override
  State<PeriodTrackerScreen> createState() => _PeriodTrackerScreenState();
}

class _PeriodTrackerScreenState extends State<PeriodTrackerScreen> {
  final supabase = Supabase.instance.client;

  DateTime? _lastPeriodDate;
  int _cycleLength = 28;
  Map<DateTime, String> _phaseMap = {};
  DateTime? _predictedNextStart;

  final List<String> symptoms = [
    'Cramps',
    'Headache',
    'Bloating',
    'Fatigue',
    'Mood Swings',
  ];
  final List<String> moods = [
    'Happy',
    'Sad',
    'Irritable',
    'Anxious',
    'Neutral',
  ];

  List<String> selectedSymptoms = [];
  String? selectedMood;

  @override
  void initState() {
    super.initState();
    _loadPrediction(); // default: use Supabase
  }

  Future<void> _loadPrediction({
    DateTime? overrideDate,
    int? overrideCycle,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    DateTime? baseDate;
    int cycle = overrideCycle ?? _cycleLength;

    if (overrideDate != null) {
      baseDate = overrideDate;
    } else {
      final response = await supabase
          .from('period_logs')
          .select('start_date, cycle_length')
          .eq('user_id', userId)
          .order('start_date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null && response['start_date'] != null) {
        baseDate = DateTime.parse(response['start_date']);
        cycle = response['cycle_length'] ?? cycle;
      }
    }

    if (baseDate != null) {
      setState(() {
        _predictedNextStart = baseDate!.add(Duration(days: cycle));
      });
    }
  }

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

  Future<void> _savePeriodLog() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null || _lastPeriodDate == null) return;

    await supabase.from('period_logs').insert({
      'user_id': userId,
      'start_date': _lastPeriodDate!.toIso8601String(),
      'cycle_length': _cycleLength,
      'symptoms': selectedSymptoms,
      'mood': selectedMood,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Period log saved')));

    _loadPrediction(); // refresh prediction after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Period Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    _loadPrediction(
                      overrideDate: picked,
                      overrideCycle: _cycleLength,
                    );
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
                  _generatePhaseMap();
                  if (_lastPeriodDate != null) {
                    _loadPrediction(
                      overrideDate: _lastPeriodDate,
                      overrideCycle: _cycleLength,
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Symptoms:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                children: symptoms.map((symptom) {
                  return FilterChip(
                    label: Text(symptom),
                    selected: selectedSymptoms.contains(symptom),
                    onSelected: (selected) {
                      setState(() {
                        selected
                            ? selectedSymptoms.add(symptom)
                            : selectedSymptoms.remove(symptom);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedMood,
                hint: const Text('Select Mood'),
                items: moods.map((mood) {
                  return DropdownMenuItem<String>(
                    value: mood,
                    child: Text(mood),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedMood = val),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePeriodLog,
                child: const Text('Save Period Log'),
              ),
              const SizedBox(height: 20),
              if (_predictedNextStart != null)
                Text(
                  'Next expected period: ${_predictedNextStart!.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 20),
              if (_phaseMap.isNotEmpty)
                TableCalendar(
                  focusedDay: DateTime.now(),
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, _) {
                      final phase =
                          _phaseMap[DateTime(day.year, day.month, day.day)];
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
            ],
          ),
        ),
      ),
    );
  }
}
