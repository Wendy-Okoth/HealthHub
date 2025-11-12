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
  String? _tip;
  String? _summaryText;

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

  final Map<String, String> wellnessTips = {
    'Cramps':
        'Try magnesium-rich foods like spinach or bananas, and use a warm compress.',
    'Fatigue':
        'Stay hydrated and prioritize sleep. Gentle movement can boost energy.',
    'Mood Swings':
        'Practice mindfulness or journaling. Omega-3s may help stabilize mood.',
    'Headache': 'Limit caffeine and try peppermint oil or hydration.',
    'Bloating':
        'Avoid salty foods and drink herbal teas like ginger or fennel.',
    'Sad':
        'Connect with someone you trust. Light exercise and sunlight help lift mood.',
    'Anxious': 'Deep breathing and grounding exercises can ease tension.',
    'Irritable':
        'Take short breaks and reduce overstimulation. Magnesium may help.',
  };

  List<String> selectedSymptoms = [];
  String? selectedMood;

  @override
  void initState() {
    super.initState();
    _loadPrediction();
    _loadSummary();
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

    setState(() {
      _predictedNextStart = baseDate?.add(Duration(days: cycle));
    });
  }

  Future<void> _loadSummary() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final logs = await supabase
        .from('period_logs')
        .select('start_date, cycle_length, symptoms, mood')
        .eq('user_id', userId)
        .order('start_date', ascending: true);

    if (logs == null || logs.isEmpty) return;

    final cycleLengths = logs.map((log) => log['cycle_length'] as int).toList();
    final avgCycle =
        cycleLengths.reduce((a, b) => a + b) ~/ cycleLengths.length;

    final symptomCounts = <String, int>{};
    final moodCounts = <String, int>{};

    for (final log in logs) {
      final rawSymptoms = log['symptoms'];
      final symptoms = rawSymptoms is List
          ? List<String>.from(rawSymptoms)
          : rawSymptoms is String
          ? [rawSymptoms]
          : [];

      final mood = log['mood'] ?? '';

      for (final s in symptoms) {
        symptomCounts[s] = (symptomCounts[s] ?? 0) + 1;
      }
      if (mood.isNotEmpty) {
        moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
      }
    }

    final topSymptom = symptomCounts.isNotEmpty
        ? symptomCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'N/A';
    final topMood = moodCounts.isNotEmpty
        ? moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'N/A';

    setState(() {
      _summaryText =
          'Average cycle length: $avgCycle days\nMost common symptom: $topSymptom\nMost common mood: $topMood';
    });
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
      case 'Follicular Phase':
        return Colors.orangeAccent;
      case 'Ovulation':
        return Colors.green;
      case 'Luteal Phase':
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

    final symptomTip = selectedSymptoms.isNotEmpty
        ? wellnessTips[selectedSymptoms.first]
        : null;
    final moodTip = selectedMood != null ? wellnessTips[selectedMood!] : null;

    setState(() {
      _tip = symptomTip ?? moodTip;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Period log saved')));

    _loadPrediction(overrideDate: _lastPeriodDate, overrideCycle: _cycleLength);
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(width: 16, height: 16, color: color),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
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
              DropdownButtonFormField<String>(
                value: selectedSymptoms.isNotEmpty
                    ? selectedSymptoms.first
                    : null,
                hint: const Text('Select Symptom'),
                items: symptoms.map((symptom) {
                  return DropdownMenuItem<String>(
                    value: symptom,
                    child: Text(symptom),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedSymptoms = val != null ? [val] : [];
                  });
                },
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
              if (_tip != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Wellness Tip: $_tip',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              const SizedBox(height: 20),
              if (_phaseMap.isNotEmpty) ...[
                TableCalendar(
                  focusedDay: DateTime.now(),
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, _) {
                      final phase =
                          _phaseMap[DateTime(day.year, day.month, day.day)];
                      return Container(
                        margin: const EdgeInsets.all(2), // reduced spacing
                        decoration: BoxDecoration(
                          color: _getPhaseColor(phase),
                          borderRadius: BorderRadius.circular(
                            4,
                          ), // tighter rounding
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ), // smaller text
                        ),
                      );
                    },
                  ),
                  rowHeight: 32, // reduces calendar height
                ),
                const SizedBox(height: 12),
                const Text(
                  'Calendar Color Key:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem('Menstruation', Colors.redAccent),
                    _buildLegendItem('Follicular', Colors.orangeAccent),
                    _buildLegendItem('Ovulation', Colors.green),
                    _buildLegendItem('Luteal', Colors.purpleAccent),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
