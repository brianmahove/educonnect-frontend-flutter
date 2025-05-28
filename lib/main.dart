import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:educonnect_app/screens/auth_screen.dart';
import 'package:educonnect_app/screens/home_screen.dart';
// Import other screens if they are part of your initial routes configuration
import 'package:educonnect_app/screens/create_course_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Initially, set it to a loading screen or auth screen
  Widget _initialRoute = const Scaffold(
    // Added a simple loading screen
    body: Center(child: CircularProgressIndicator()),
  );

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  // Check if a token exists to determine initial route
  Future<void> _checkAuthStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    // Corrected line: Safely check if token is not null AND if it's not empty
    if (token != null && token.isNotEmpty) {
      setState(() {
        _initialRoute = const HomeScreen();
      });
    } else {
      setState(() {
        _initialRoute = const AuthScreen();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduConnect',
      debugShowCheckedModeBanner: false, // Optional: remove debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue, // Consistent app bar color
          foregroundColor: Colors.white, // Text/icon color on app bar
        ),
      ),
      home: _initialRoute, // Set initial route based on auth status
      routes: {
        // Define all your routes here
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const HomeScreen(),
        '/create-course': (context) => const CreateCourseScreen(),
      },
    );
  }
}
