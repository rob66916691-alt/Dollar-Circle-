import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../contributions/contribute_screen.dart';
import '../profile/profile_screen.dart';
import '../requests/create_request_screen.dart';
import '../requests/request_list_screen.dart';

class HomeScreen extends StatefulWidget {
  final AuthService authService;
  final ApiService apiService;

  const HomeScreen({
    super.key,
    required this.authService,
    required this.apiService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardTab(apiService: widget.apiService),
      RequestListScreen(apiService: widget.apiService),
      ProfileScreen(
        apiService: widget.apiService,
        onLogout: () async {
          await widget.authService.logout();
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => LoginScreen(
                authService: widget.authService,
                apiService: widget.apiService,
              ),
            ),
            (_) => false,
          );
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dollar Circle'),
        actions: [
          IconButton(
            tooltip: 'Request help',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreateRequestScreen(apiService: widget.apiService),
              ),
            ),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.volunteer_activism_outlined), label: 'Requests'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  final ApiService apiService;
  const DashboardTab({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Welcome to the Circle', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text('Members help one another with small, transparent contributions.'),
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.request_page_outlined)),
            title: const Text('Request emergency help'),
            subtitle: const Text('Submit a bill or urgent financial need for review.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreateRequestScreen(apiService: apiService),
              ),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.attach_money)),
            title: const Text('Contribute to a member'),
            subtitle: const Text('View approved requests and pledge a contribution.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ContributeScreen(apiService: apiService),
              ),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.history)),
            title: const Text('My requests'),
            subtitle: const Text('Track pending, approved, funded, or rejected requests.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RequestListScreen(apiService: apiService, mineOnly: true),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
