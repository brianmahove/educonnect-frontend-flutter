import 'package:flutter/material.dart';
import 'package:educonnect_app/api/api_service.dart';

class CreateQuizScreen extends StatefulWidget {
  final String courseId;

  const CreateQuizScreen({super.key, required this.courseId});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quizTitleController = TextEditingController();

  final List<Map<String, dynamic>> _questions =
      []; // {questionText, options[], correctAnswer}

  bool _isLoading = false;
  String? _errorMessage;

  void _addQuestion() {
    setState(() {
      _questions.add({
        'questionText': '',
        'options': ['', '', '', ''],
        'correctAnswer': '',
      });
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  Future<void> _createQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Basic validation for questions and options
    for (var q in _questions) {
      if (q['questionText'].isEmpty) {
        setState(() {
          _errorMessage = 'All question texts must be filled.';
        });
        return;
      }
      if (q['options'].any((opt) => opt.isEmpty)) {
        setState(() {
          _errorMessage = 'All options for each question must be filled.';
        });
        return;
      }
      if (q['correctAnswer'].isEmpty) {
        setState(() {
          _errorMessage = 'Please select a correct answer for each question.';
        });
        return;
      }
      if (!q['options'].contains(q['correctAnswer'])) {
        setState(() {
          _errorMessage = 'Correct answer must be one of the provided options.';
        });
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final quizData = {
        'courseId': widget.courseId,
        'title': _quizTitleController.text,
        'questions': _questions,
      };

      await _apiService.createQuiz(quizData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz created successfully!')),
      );
      Navigator.pop(context, true); // Go back and indicate success
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
      appBar: AppBar(title: const Text('Create New Quiz')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _quizTitleController,
                decoration: const InputDecoration(labelText: 'Quiz Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quiz title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Questions:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addQuestion,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Question'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _questions.length,
                itemBuilder: (context, qIndex) {
                  final question = _questions[qIndex];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Question ${qIndex + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeQuestion(qIndex),
                              ),
                            ],
                          ),
                          TextFormField(
                            initialValue: question['questionText'],
                            decoration: const InputDecoration(
                              labelText: 'Question Text',
                            ),
                            onChanged:
                                (value) => question['questionText'] = value,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Required';
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Options:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...List.generate(4, (oIndex) {
                            return TextFormField(
                              initialValue: question['options'][oIndex],
                              decoration: InputDecoration(
                                labelText: 'Option ${oIndex + 1}',
                              ),
                              onChanged:
                                  (value) =>
                                      question['options'][oIndex] = value,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Required';
                                return null;
                              },
                            );
                          }),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value:
                                question['correctAnswer'].isNotEmpty
                                    ? question['correctAnswer']
                                    : null,
                            decoration: const InputDecoration(
                              labelText: 'Correct Answer',
                            ),
                            items:
                                question['options']
                                    .where((opt) => opt.isNotEmpty)
                                    .map<DropdownMenuItem<String>>((
                                      String value,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    })
                                    .toList(),
                            onChanged: (value) {
                              setState(() {
                                question['correctAnswer'] = value!;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Please select a correct answer';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _createQuiz,
                    child: const Text('Create Quiz'),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _quizTitleController.dispose();
    super.dispose();
  }
}
