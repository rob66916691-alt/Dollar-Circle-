import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const DollarCircleApp());
}

class DollarCircleApp extends StatefulWidget {
  const DollarCircleApp({super.key});

  @override
  State<DollarCircleApp> createState() => _DollarCircleAppState();
}

class _DollarCircleAppState extends State<DollarCircleApp> {
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService(authService);

    return MaterialApp(
      title: 'Dollar Circle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
      ),
      home: FutureBuilder<bool>(
        future: authService.isLoggedIn(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.data == true) {
            return HomeScreen(
              authService: authService,
              apiService: apiService,
            );
          }

          return LoginScreen(
            authService: authService,
            apiService: apiService,
          );
        },
      ),
    );
  }
}
