import 'package:flutter/material.dart';
import 'package:event_management_app/services/auth_service.dart';
import 'package:event_management_app/screens/login.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  Map<String, dynamic>? _userData;
  bool _isLoading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      // Simulate network delay based on connection
      final minDelay = Duration(milliseconds: 800); // Minimum delay for UX
      final start = DateTime.now();

      // Replace with your actual API call
      // final userData = await ApiService().getUserProfile();

      // Calculate remaining delay after API call
      final elapsed = DateTime.now().difference(start);
      if (elapsed < minDelay) {
        await Future.delayed(minDelay - elapsed);
      }

      // setState(() => _userData = userData);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _clearLocalStorage() async {
    if (kIsWeb) {
      html.window.localStorage.clear();
    }
  }

  Future<void> _handleLogout() async {
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red.shade600),
              const SizedBox(width: 8),
              const Text(
                'Confirm Logout',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(
              fontFamily: 'KantumruyPro-Regular',
              fontSize: 16.0,
              color: Colors.black54,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'KantumruyPro-Regular',
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontFamily: 'KantumruyPro-Regular',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                await _clearLocalStorage();
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      try {
        await AuthService.removeToken();
        if (!mounted) return;

        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double imageSize = constraints.maxWidth < 600
                ? constraints.maxWidth * 0.8
                : constraints.maxWidth * 0.3;

            final double buttonWidth = constraints.maxWidth < 600
                ? constraints.maxWidth * 0.6
                : constraints.maxWidth * 0.3;

            return Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF083E68), Color(0xFF107BCE)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (_isLoading)
                        const CircularProgressIndicator(color: Colors.white)
                      else ...[
                        SizedBox(
                          width: imageSize,
                          height: imageSize,
                          child: Image.asset(
                            'assets/img/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: buttonWidth,
                          child: ElevatedButton.icon(
                            onPressed: _handleLogout,
                            icon: const Icon(
                              Icons.logout,
                              color: Color(0xFF083E68),
                            ),
                            label: const Text(
                              'Logout',
                              style: TextStyle(
                                fontFamily: 'KantumruyPro-Regular',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF083E68),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
