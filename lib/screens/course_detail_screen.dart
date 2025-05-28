import 'package:flutter/material.dart';
import 'package:educonnect_app/api/api_service.dart';
import 'package:educonnect_app/screens/submit_assignment_screen.dart'; // For assignment submission
import 'package:educonnect_app/screens/quizzes_screen.dart'; // For quizzes

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _course;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isEnrolled = false; // To track if the user is enrolled

  @override
  void initState() {
    super.initState();
    _fetchCourseDetails();
  }

  Future<void> _fetchCourseDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final courseData = await _apiService.getCourseById(widget.courseId);
      final enrollments = await _apiService.getMyEnrollments();
      _isEnrolled = enrollments.any(
        (enrollment) => enrollment['course']['_id'] == widget.courseId,
      );

      setState(() {
        _course = courseData;
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

  Future<void> _enrollInCourse() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _apiService.enrollInCourse(widget.courseId);
      setState(() {
        _isEnrolled = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully enrolled in course!')),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_course?['title'] ?? 'Course Details')),
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
              : _course == null
              ? const Center(child: Text('Course not found.'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _course!['title'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Instructor: ${_course!['instructor']['username']}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _course!['description'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    if (!_isEnrolled)
                      ElevatedButton(
                        onPressed: _enrollInCourse,
                        child: const Text('Enroll in Course'),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lessons:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_course!['lessons'] != null &&
                              _course!['lessons'].isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _course!['lessons'].length,
                              itemBuilder: (context, index) {
                                final lesson = _course!['lessons'][index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  child: ExpansionTile(
                                    title: Text(lesson['title']),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(lesson['content']),
                                            if (lesson['videoUrl'] != null &&
                                                lesson['videoUrl'].isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 10,
                                                ),
                                                child: Text(
                                                  'Video URL: ${lesson['videoUrl']}',
                                                  style: const TextStyle(
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          if (_course!['lessons'] == null ||
                              _course!['lessons'].isEmpty)
                            const Text('No lessons available for this course.'),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => SubmitAssignmentScreen(
                                        courseId: widget.courseId,
                                      ),
                                ),
                              );
                            },
                            child: const Text('Submit Assignment'),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => QuizzesScreen(
                                        courseId: widget.courseId,
                                        courseTitle: _course!['title'],
                                      ),
                                ),
                              );
                            },
                            child: const Text('View Quizzes'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
    );
  }
}
