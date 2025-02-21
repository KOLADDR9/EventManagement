import 'package:flutter/material.dart';
import 'package:event_management_app/screens/calendar_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_management_app/services/api_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final ApiService apiService = ApiService();
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());

  Future<void> _handleLogin(BuildContext context) async {
    String code = _controllers.map((c) => c.text).join();

    if (code.length != 6 || !RegExp(r'^\d{6}$').hasMatch(code)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit code.')),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      final success = await apiService.login(code);

      // Hide loading indicator
      Navigator.pop(context);

      if (success == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CalendarScreen()),
        );
      } else {
        // Show error message and clear input
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid code. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        // Clear input fields
        for (var controller in _controllers) {
          controller.clear();
        }
      }
    } catch (e) {
      // Hide loading indicator if showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      // Clear input fields
      for (var controller in _controllers) {
        controller.clear();
      }
    }
  }

  Future<String> _getTokenFromApi(String code) async {
    // Simulate an API call to get the token
    // Replace this with your actual API logic
    await Future.delayed(Duration(seconds: 2));
    return 'mock_token_for_$code';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF083E68), // #083E68
              Color(0xFF107BCE), // #107BCE
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'សូមបំពេញលេខកូដ ៦ ខ្ទង់',
              style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _controllers[index].text.isNotEmpty
                        ? Colors.white
                        : Colors.white54,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            _buildNumberPad(),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    List<List<String>> keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];

    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            return key.isEmpty
                ? const SizedBox(width: 80)
                : _buildKeyboardButton(
                    label: key,
                    onTap: () {
                      setState(() {
                        if (key == '⌫') {
                          for (int i = _controllers.length - 1; i >= 0; i--) {
                            if (_controllers[i].text.isNotEmpty) {
                              _controllers[i].clear();
                              break;
                            }
                          }
                        } else {
                          for (var controller in _controllers) {
                            if (controller.text.isEmpty) {
                              controller.text = key;
                              break;
                            }
                          }
                        }
                      });

                      // Auto-submit when all fields are filled
                      if (_controllers.every((c) => c.text.isNotEmpty)) {
                        _handleLogin(context);
                      }
                    });
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildKeyboardButton(
      {required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
