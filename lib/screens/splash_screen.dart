import 'package:flutter/material.dart';
import 'package:event_management_app/screens/login.dart';
import 'package:event_management_app/screens/calendar_screen.dart';
import 'package:event_management_app/services/api_service.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  Future<void> checkAuth() async {
    final hasToken = await apiService.hasValidToken();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => hasToken ? CalendarScreen() : LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
