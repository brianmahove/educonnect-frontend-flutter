import 'package:flutter/material.dart';
import 'package:educonnect_app/api/api_service.dart';

class SubmitAssignmentScreen extends StatefulWidget {
  final String courseId;

  const SubmitAssignmentScreen({super.key, required this.courseId});

  @override
  State<SubmitAssignmentScreen> createState() => _SubmitAssignmentScreenState();
}

class _SubmitAssignmentScreenState extends State<SubmitAssignmentScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _submissionTextController =
      TextEditingController();
  final TextEditingController _submissionFileUrlController =
      TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submitAssignment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _apiService.submitAssignment(
        widget.courseId,
        _titleController.text,
        _descriptionController.text,
        _submissionTextController.text,
        _submissionFileUrlController.text.isEmpty
            ? null
            : _submissionFileUrlController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment submitted successfully!')),
      );
      Navigator.pop(context); // Go back to course detail
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
      appBar: AppBar(title: const Text('Submit Assignment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Assignment Title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title for your assignment';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Assignment Description',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description for your assignment';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _submissionTextController,
                decoration: const InputDecoration(
                  labelText: 'Your Submission (Text)',
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your submission text';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _submissionFileUrlController,
                decoration: const InputDecoration(
                  labelText: 'Submission File URL (Optional)',
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _submitAssignment,
                    child: const Text('Submit Assignment'),
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
    _submissionTextController.dispose();
    _submissionFileUrlController.dispose();
    super.dispose();
  }
}
