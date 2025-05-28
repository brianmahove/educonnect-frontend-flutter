import 'package:educonnect_app/screens/my_enrollments_screen.dart';
import 'package:flutter/material.dart';
import 'package:educonnect_app/api/api_service.dart';

class MyAssignmentsScreen extends StatefulWidget {
  const MyAssignmentsScreen({super.key});

  @override
  State<MyAssignmentsScreen> createState() => _MyAssignmentsScreenState();
}

class _MyAssignmentsScreenState extends State<MyAssignmentsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _assignments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMyAssignments();
  }

  Future<void> _fetchMyAssignments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final assignments = await _apiService.getMySubmittedAssignments();
      setState(() {
        _assignments = assignments;
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
      appBar: AppBar(title: const Text('My Submitted Assignments')),
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
              : _assignments.isEmpty
              ? const Center(
                child: Text('You have not submitted any assignments yet.'),
              )
              : ListView.builder(
                itemCount: _assignments.length,
                itemBuilder: (context, index) {
                  final assignment = _assignments[index];
                  final courseTitle =
                      assignment['course'] != null
                          ? assignment['course']['title']
                          : 'N/A';
                  final submittedAt =
                      DateTime.parse(assignment['submittedAt']).toLocal();
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ExpansionTile(
                      title: Text(assignment['title']),
                      subtitle: Text(
                        'Course: $courseTitle - Submitted: ${submittedAt.toShortString()}',
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Description: ${assignment['description']}'),
                              const SizedBox(height: 5),
                              Text(
                                'Your Submission: ${assignment['submissionText']}',
                              ),
                              if (assignment['submissionFileUrl'] != null &&
                                  assignment['submissionFileUrl'].isNotEmpty)
                                Text(
                                  'File: ${assignment['submissionFileUrl']}',
                                ),
                              const SizedBox(height: 10),
                              Text(
                                'Grade: ${assignment['grade'] ?? 'Pending'}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      assignment['grade'] != null
                                          ? Colors.green
                                          : Colors.orange,
                                ),
                              ),
                              if (assignment['feedback'] != null &&
                                  assignment['feedback'].isNotEmpty)
                                Text('Feedback: ${assignment['feedback']}'),
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
