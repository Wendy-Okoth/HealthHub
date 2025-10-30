import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  String? _gender;
  final List<String> _genderOptions = ['Male', 'Female'];
  bool _loading = false;

  String? _selectedAvatar;
  final List<String> _avatarPaths = List.generate(
    36,
    (index) => 'assets/image${index + 1}.png',
  );

  final ScrollController _avatarScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _avatarScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final data = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (data != null) {
      _firstNameController.text = data['first_name'] ?? '';
      _lastNameController.text = data['last_name'] ?? '';
      _locationController.text = data['location'] ?? '';
      _clinicController.text = data['preferred_clinic'] ?? '';
      _goalController.text = data['wellness_goal'] ?? '';
      _selectedAvatar = data['profile_avatar'];
      _gender = data['gender'];
      if (data['birthday'] != null) {
        _birthday = DateTime.tryParse(data['birthday']);
      }
      setState(() {});
    }
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate() || _birthday == null) return;
    setState(() => _loading = true);

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    await Supabase.instance.client.from('profiles').upsert({
      'user_id': userId,
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'birthday': _birthday!.toIso8601String(),
      'location': _locationController.text.trim(),
      'preferred_clinic': _clinicController.text.trim(),
      'wellness_goal': _goalController.text.trim(),
      'profile_avatar': _selectedAvatar,
      'gender': _gender,
    });

    if (!mounted) return;
    Navigator.pop(context);
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
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: _genderOptions.map((gender) {
                  return DropdownMenuItem(value: gender, child: Text(gender));
                }).toList(),
                onChanged: (value) => setState(() => _gender = value),
                validator: (value) =>
                    value == null ? 'Please select your gender' : null,
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
                    initialDate: _birthday ?? DateTime(2000),
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
              const Text(
                'Choose an Avatar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                height: 100,
                width: double.infinity,
                child: Scrollbar(
                  controller: _avatarScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _avatarScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _avatarPaths.map((path) {
                        final isSelected = _selectedAvatar == path;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedAvatar = path),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.transparent,
                                width: 2,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              backgroundImage: AssetImage(path),
                              radius: 30,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
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
