import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  DateTime? _birthday;
  final _locationController = TextEditingController();
  final _clinicController = TextEditingController();
  final _goalController = TextEditingController();
  bool _loading = false;

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate() || _birthday == null) return;
    setState(() => _loading = true);

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final response = await Supabase.instance.client.from('profiles').upsert({
      'user_id': userId,
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'birthday': _birthday!.toIso8601String(),
      'location': _locationController.text.trim(),
      'preferred_clinic': _clinicController.text.trim(),
      'wellness_goal': _goalController.text.trim(),
    });

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter your first name'
                    : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter your last name'
                    : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  _birthday == null
                      ? 'Select Birthday'
                      : 'Birthday: ${_birthday!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _birthday = picked);
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter your location' : null,
              ),
              TextFormField(
                controller: _clinicController,
                decoration: const InputDecoration(
                  labelText: 'Preferred Clinic',
                ),
              ),
              TextFormField(
                controller: _goalController,
                decoration: const InputDecoration(labelText: 'Wellness Goal'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submitProfile,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
