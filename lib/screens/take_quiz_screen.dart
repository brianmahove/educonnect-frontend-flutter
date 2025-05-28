import 'package:flutter/material.dart';
import 'package:educonnect_app/api/api_service.dart';

class TakeQuizScreen extends StatefulWidget {
  final String quizId;

  const TakeQuizScreen({super.key, required this.quizId});

  @override
  State<TakeQuizScreen> createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends State<TakeQuizScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _quiz;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentQuestionIndex = 0;
  final Map<String, String> _selectedAnswers =
      {}; // {questionId: selectedOption}

  @override
  void initState() {
    super.initState();
    _fetchQuizDetails();
  }

  Future<void> _fetchQuizDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final quizData = await _apiService.getQuizById(widget.quizId);
      setState(() {
        _quiz = quizData;
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

  void _nextQuestion() {
    if (_currentQuestionIndex < _quiz!['questions'].length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _submitQuiz();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  Future<void> _submitQuiz() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final List<Map<String, String>> answersToSend = [];
    _quiz!['questions'].forEach((q) {
      final questionId = q['_id'];
      answersToSend.add({
        'questionId': questionId,
        'submittedAnswer':
            _selectedAnswers[questionId] ??
            '', // Send empty string if not answered
      });
    });

    try {
      await _apiService.submitQuiz(widget.quizId, answersToSend);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz submitted successfully!')),
      );
      Navigator.pop(
        context,
        true,
      ); // Go back to quizzes screen, indicate success
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading Quiz...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text(
            'Error: $_errorMessage',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (_quiz == null || _quiz!['questions'].isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Not Found')),
        body: const Center(child: Text('Quiz not found or has no questions.')),
      );
    }

    final currentQuestion = _quiz!['questions'][_currentQuestionIndex];
    final questionId = currentQuestion['_id'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_quiz!['title']} (${_currentQuestionIndex + 1}/${_quiz!['questions'].length})',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question: ${currentQuestion['questionText']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion['options'].length,
                itemBuilder: (context, optionIndex) {
                  final option = currentQuestion['options'][optionIndex];
                  return RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: _selectedAnswers[questionId],
                    onChanged: (value) {
                      setState(() {
                        _selectedAnswers[questionId] = value!;
                      });
                    },
                  );
                },
              ),
            ),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: _previousQuestion,
                    child: const Text('Previous'),
                  ),
                ElevatedButton(
                  onPressed: _nextQuestion,
                  child: Text(
                    _currentQuestionIndex == _quiz!['questions'].length - 1
                        ? 'Submit Quiz'
                        : 'Next',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
