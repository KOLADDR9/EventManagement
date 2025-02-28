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
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double logoSize = width * 0.4; // 40% of screen width

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF083E68), // Dark blue
              Color(0xFF107BCE), // Light blue
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Image.asset(
            'assets/img/logo.png',
            width: logoSize, // Dynamically calculated logo size
            height: logoSize, // Dynamically calculated logo size
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
