import 'package:educonnect_app/screens/my_enrollments_screen.dart';
import 'package:flutter/material.dart';
import 'package:educonnect_app/api/api_service.dart';

class MyQuizResultsScreen extends StatefulWidget {
  const MyQuizResultsScreen({super.key});

  @override
  State<MyQuizResultsScreen> createState() => _MyQuizResultsScreenState();
}

class _MyQuizResultsScreenState extends State<MyQuizResultsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _quizResults = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMyQuizResults();
  }

  Future<void> _fetchMyQuizResults() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final results = await _apiService.getMyQuizResults();
      setState(() {
        _quizResults = results;
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
      appBar: AppBar(title: const Text('My Quiz Results')),
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
              : _quizResults.isEmpty
              ? const Center(
                child: Text('You have not submitted any quiz results yet.'),
              )
              : ListView.builder(
                itemCount: _quizResults.length,
                itemBuilder: (context, index) {
                  final result = _quizResults[index];
                  final quizTitle =
                      result['quiz'] != null ? result['quiz']['title'] : 'N/A';
                  final submittedAt =
                      DateTime.parse(result['submittedAt']).toLocal();

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ExpansionTile(
                      title: Text(quizTitle),
                      subtitle: Text(
                        'Score: ${result['score']}/${result['totalQuestions']} - Submitted: ${submittedAt.toShortString()}',
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Your Answers:'),
                              const SizedBox(height: 5),
                              ...result['answers'].map<Widget>((answer) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2.0,
                                  ),
                                  child: Text(
                                    'Question: ${answer['questionId']} - Submitted: ${answer['submittedAnswer']} - ${answer['isCorrect'] ? 'Correct' : 'Incorrect'}',
                                    style: TextStyle(
                                      color:
                                          answer['isCorrect']
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
