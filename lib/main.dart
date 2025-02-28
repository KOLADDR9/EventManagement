import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'screens/calendar_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login.dart';
import 'screens/splash_screen.dart'; // Import your custom SplashScreen
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Future.delayed(const Duration(seconds: 1)); // Move delay here

  if (kIsWeb) {
    try {
      String? token = html.window.localStorage['auth_token'];
      if (token == null || token.isEmpty) {
        token = await AuthService.getToken();
        if (token != null && token.isNotEmpty) {
          html.window.localStorage['auth_token'] = token;
        }
      }
      print('🔑 Web token found: $token');
    } catch (e) {
      print('🚨 Error handling localStorage: $e');
    }
  }

  await initializeDateFormatting();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    String? token;
    if (kIsWeb) {
      try {
        token = html.window.localStorage['auth_token'];
        print('🔑 Web token found in localStorage: $token');
      } catch (e) {
        print('🚨 Error reading localStorage: $e');
      }
    } else {
      token = await _secureStorage.read(key: 'auth_token');
    }

    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Event Calendar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'KantumruyPro-Regular', // Set default font family
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontFamily: 'KantumruyPro-Regular',
          ),
          bodyMedium: TextStyle(
            fontFamily: 'KantumruyPro-Regular',
          ),
          titleLarge: TextStyle(
            fontFamily: 'KantumruyPro-Regular',
          ),
          // Add other text styles as needed
        ),
      ),
      home: _isLoading
          ? SplashScreen() // Your existing SplashScreen
          : _isLoggedIn
              ? const MainScreen()
              : LoginPage(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const CalendarScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: Color(0xFF083E68),
        unselectedItemColor: Color(0xFF083E68).withOpacity(0.5),
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'KantumruyPro-Regular',
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'KantumruyPro-Regular',
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
