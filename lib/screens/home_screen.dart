import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:educonnect_app/api/api_service.dart';
import 'package:educonnect_app/screens/course_detail_screen.dart';
import 'package:educonnect_app/screens/my_enrollments_screen.dart';
import 'package:educonnect_app/screens/my_assignments_screen.dart';
import 'package:educonnect_app/screens/create_course_screen.dart'; // For instructors

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _courses = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _fetchCoursesAndUserRole();
  }

  Future<void> _fetchCoursesAndUserRole() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final user = await _apiService.getMe();
      _userRole = user['role'];

      final courses = await _apiService.getCourses();
      setState(() {
        _courses = courses;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    Navigator.of(context).pushReplacementNamed('/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EduConnect Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCoursesAndUserRole,
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'my_enrollments') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyEnrollmentsScreen(),
                  ),
                );
              } else if (value == 'my_assignments') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyAssignmentsScreen(),
                  ),
                );
              } else if (value == 'create_course') {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateCourseScreen(),
                  ),
                );
                if (result == true) {
                  _fetchCoursesAndUserRole(); // Refresh courses after creating one
                }
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'my_enrollments',
                    child: Text('My Enrollments'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'my_assignments',
                    child: Text('My Assignments'),
                  ),
                  if (_userRole == 'instructor' ||
                      _userRole == 'admin') // Show for instructors/admins
                    const PopupMenuItem<String>(
                      value: 'create_course',
                      child: Text('Create Course'),
                    ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                ],
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Text(
                  'Error: $_errorMessage',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              )
              : _courses.isEmpty
              ? const Center(child: Text('No courses available yet.'))
              : ListView.builder(
                itemCount: _courses.length,
                itemBuilder: (context, index) {
                  final course = _courses[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(course['title']),
                      subtitle: Text(
                        'Instructor: ${course['instructor']['username']}',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    CourseDetailScreen(courseId: course['_id']),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
