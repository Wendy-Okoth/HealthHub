import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tracker_screen.dart';
import 'tips_screen.dart';
import 'checkin_screen.dart';
import 'map_view.dart';
import 'login_screen.dart';
import 'profile_setup_screen.dart';
import 'step_tracker_screen.dart';
import 'period_tracker_screen.dart';
import 'sleep_tracker_screen.dart';
import 'hydration_screen.dart';
import 'calorie_tracker_screen.dart'; // ✅ NEW IMPORT

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? profile;

  final List<Map<String, dynamic>> features = [
    {
      'title': 'Health Tracker',
      'icon': Icons.favorite,
      'screen': TrackerScreen(),
    },
    {
      'title': 'Wellness Tips',
      'icon': Icons.lightbulb,
      'screen': TipsScreen(),
    },
    {
      'title': 'Daily Check-in',
      'icon': Icons.check_circle,
      'screen': CheckInScreen(),
    },
    {
      'title': 'Nearby Clinics',
      'icon': Icons.local_hospital,
      'screen': MapView(),
    },
    {
      'title': 'Step Tracker',
      'icon': Icons.directions_walk,
      'screen': StepTrackerScreen(),
    },
    {
      'title': 'Sleep Tracker',
      'icon': Icons.bedtime,
      'screen': SleepTrackerScreen(),
    },
    {
      'title': 'Period Tracker',
      'icon': Icons.calendar_today,
      'screen': PeriodTrackerScreen(),
    },
    {
      'title': 'Hydration Tracker',
      'icon': Icons.local_drink,
      'screen': HydrationScreen(),
    },
    {
      'title': 'Calorie Tracker', // ✅ NEW FEATURE
      'icon': Icons.local_fire_department,
      'screen': CalorieTrackerScreen(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final data = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (mounted) setState(() => profile = data);
  }

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _openProfile(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
    );
    _loadProfile(); // Refresh profile after editing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthHub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () => _openProfile(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          if (profile != null)
            Card(
              margin: const EdgeInsets.all(16),
              child: ListTile(
                leading: profile!['profile_avatar'] != null
                    ? CircleAvatar(
                        backgroundImage: AssetImage(profile!['profile_avatar']),
                        radius: 25,
                      )
                    : const Icon(Icons.account_circle, size: 40),
                title: Text(
                  '${profile!['first_name'] ?? ''} ${profile!['last_name'] ?? ''}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gender: ${profile!['gender'] ?? 'Not set'}'),
                    Text('Goal: ${profile!['wellness_goal'] ?? 'Not set'}'),
                  ],
                ),
                trailing: Text(
                  profile!['birthday'] != null
                      ? profile!['birthday'].toString().split('T').first
                      : '',
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: features.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(features[index]['icon'], color: Colors.green),
                  title: Text(features[index]['title']),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => features[index]['screen'],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
