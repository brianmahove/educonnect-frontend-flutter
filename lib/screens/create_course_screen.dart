import 'package:flutter/material.dart';
import 'package:educonnect_app/api/api_service.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<Map<String, String>> _lessons = [];

  bool _isLoading = false;
  String? _errorMessage;

  void _addLesson() {
    setState(() {
      _lessons.add({'title': '', 'content': '', 'videoUrl': ''});
    });
  }

  void _removeLesson(int index) {
    setState(() {
      _lessons.removeAt(index);
    });
  }

  Future<void> _createCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Basic validation for lessons
    for (var lesson in _lessons) {
      if (lesson['title']!.isEmpty || lesson['content']!.isEmpty) {
        setState(() {
          _errorMessage = 'All lesson fields (title, content) must be filled.';
        });
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final courseData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'lessons':
            _lessons
                .map(
                  (lesson) => {
                    'title': lesson['title'],
                    'content': lesson['content'],
                    'videoUrl':
                        lesson['videoUrl']!.isNotEmpty
                            ? lesson['videoUrl']
                            : null,
                  },
                )
                .toList(),
      };

      await _apiService.createCourse(courseData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course created successfully!')),
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
      appBar: AppBar(title: const Text('Create New Course')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Course Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a course title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Course Description',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a course description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lessons:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addLesson,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Lesson'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _lessons.length,
                itemBuilder: (context, index) {
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
                                'Lesson ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeLesson(index),
                              ),
                            ],
                          ),
                          TextFormField(
                            initialValue: _lessons[index]['title'],
                            decoration: const InputDecoration(
                              labelText: 'Lesson Title',
                            ),
                            onChanged:
                                (value) => _lessons[index]['title'] = value,
                          ),
                          TextFormField(
                            initialValue: _lessons[index]['content'],
                            decoration: const InputDecoration(
                              labelText: 'Lesson Content',
                            ),
                            maxLines: 3,
                            onChanged:
                                (value) => _lessons[index]['content'] = value,
                          ),
                          TextFormField(
                            initialValue: _lessons[index]['videoUrl'],
                            decoration: const InputDecoration(
                              labelText: 'Video URL (Optional)',
                            ),
                            onChanged:
                                (value) => _lessons[index]['videoUrl'] = value,
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
                    onPressed: _createCourse,
                    child: const Text('Create Course'),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
