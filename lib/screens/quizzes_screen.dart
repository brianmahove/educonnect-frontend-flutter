import 'package:flutter/material.dart';
import 'package:educonnect_app/api/api_service.dart';
import 'package:educonnect_app/screens/take_quiz_screen.dart'; // To take a quiz
import 'package:educonnect_app/screens/my_quiz_results_screen.dart'; // To view user's quiz results
import 'package:educonnect_app/screens/create_quiz_screen.dart'; // For instructors

class QuizzesScreen extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const QuizzesScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _quizzes = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _fetchQuizzesAndUserRole();
  }

  Future<void> _fetchQuizzesAndUserRole() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final user = await _apiService.getMe();
      _userRole = user['role'];
      final quizzes = await _apiService.getQuizzesByCourse(widget.courseId);
      setState(() {
        _quizzes = quizzes;
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
      appBar: AppBar(
        title: Text('${widget.courseTitle} Quizzes'),
        actions: [
          if (_userRole == 'instructor' || _userRole == 'admin')
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            CreateQuizScreen(courseId: widget.courseId),
                  ),
                );
                if (result == true) {
                  _fetchQuizzesAndUserRole(); // Refresh quizzes after creation
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.show_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyQuizResultsScreen(),
                ),
              );
            },
            tooltip: 'My Quiz Results',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchQuizzesAndUserRole,
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
              : _quizzes.isEmpty
              ? const Center(
                child: Text('No quizzes available for this course yet.'),
              )
              : ListView.builder(
                itemCount: _quizzes.length,
                itemBuilder: (context, index) {
                  final quiz = _quizzes[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(quiz['title']),
                      subtitle: Text('Questions: ${quiz['questions'].length}'),
                      trailing:
                          _userRole == 'student'
                              ? ElevatedButton(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => TakeQuizScreen(
                                            quizId: quiz['_id'],
                                          ),
                                    ),
                                  );
                                  if (result == true) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Quiz submitted! Check My Results.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Take Quiz'),
                              )
                              : null, // No button for instructor/admin here, they manage quizzes
                    ),
                  );
                },
              ),
    );
  }
}
