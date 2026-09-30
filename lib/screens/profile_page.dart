import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/saved_service.dart';
import '../services/theme_service.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ThemeService _themeService = ThemeService.instance;
  final SavedService _savedService = SavedService.instance;

  @override
  void initState() {
    super.initState();

    _themeService.addListener(_refresh);
    _savedService.addListener(_refresh);
  }

  @override
  void dispose() {
    _themeService.removeListener(_refresh);
    _savedService.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (!mounted) return;

    setState(() {});
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    await _savedService.clearForLogout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),

          // Profile icon
          Center(
            child: CircleAvatar(
              radius: 48,
              child: Icon(
                Icons.person_rounded,
                size: 52,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Email
          Center(
            child: Text(
              user?.email ?? 'No email',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),

          const SizedBox(height: 30),

          // Saved count
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(
                    Icons.bookmark_rounded,
                    size: 30,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_savedService.savedPhotos.length}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Text(
                        'Saved Photos',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          Text(
            'Appearance',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 10),

          RadioGroup<ThemeMode>(
            groupValue: _themeService.themeMode,
            onChanged: (mode) {
              if (mode != null) {
                _themeService.setThemeMode(mode);
              }
            },
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  title: const Text('System'),
                  subtitle: const Text(
                    'Use your device theme',
                  ),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  title: const Text('Light'),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  title: const Text('Dark'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Logout
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Logout'),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}