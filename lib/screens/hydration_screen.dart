import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HydrationScreen extends StatefulWidget {
  const HydrationScreen({super.key});

  @override
  State<HydrationScreen> createState() => _HydrationScreenState();
}

class _HydrationScreenState extends State<HydrationScreen> {
  final supabase = Supabase.instance.client;
  int glasses = 0;
  bool isLoading = false;

  Future<void> logWaterIntake() async {
    setState(() => isLoading = true);
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    final today = DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD

    final existing = await supabase
        .from('hydration_logs')
        .select()
        .eq('user_id', userId)
        .eq('date', today)
        .maybeSingle();

    if (existing != null) {
      await supabase
          .from('hydration_logs')
          .update({'glasses': glasses})
          .eq('id', existing['id']);
    } else {
      await supabase.from('hydration_logs').insert({
        'user_id': userId,
        'date': today,
        'glasses': glasses,
      });
    }

    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged $glasses glasses of water')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hydration Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'How many glasses of water have you had today?',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Glasses'),
              keyboardType: TextInputType.number,
              onChanged: (val) => glasses = int.tryParse(val) ?? 0,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : logWaterIntake,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Log Water Intake'),
            ),
          ],
        ),
      ),
    );
  }
}
