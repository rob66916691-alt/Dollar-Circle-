import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ProfileScreen extends StatelessWidget {
  final ApiService apiService;
  final Future<void> Function() onLogout;

  const ProfileScreen({
    super.key,
    required this.apiService,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: apiService.getProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        final profile = snapshot.data ?? {};
        final name = [
          profile['firstName'],
          profile['lastName'],
        ].where((value) => value != null && value.toString().isNotEmpty).join(' ');

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const CircleAvatar(radius: 46, child: Icon(Icons.person, size: 46)),
            const SizedBox(height: 16),
            Text(
              name.isEmpty ? 'Dollar Circle Member' : name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              profile['email']?.toString() ?? '',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: const Text('Membership role'),
              subtitle: Text(profile['role']?.toString() ?? 'member'),
            ),
            const Divider(),
            OutlinedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}
