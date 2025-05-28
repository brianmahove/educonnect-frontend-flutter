import 'package:flutter/material.dart';
import 'package:educonnect_app/api/api_service.dart';

class MyEnrollmentsScreen extends StatefulWidget {
  const MyEnrollmentsScreen({super.key});

  @override
  State<MyEnrollmentsScreen> createState() => _MyEnrollmentsScreenState();
}

class _MyEnrollmentsScreenState extends State<MyEnrollmentsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _enrollments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMyEnrollments();
  }

  Future<void> _fetchMyEnrollments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final enrollments = await _apiService.getMyEnrollments();
      setState(() {
        _enrollments = enrollments;
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
      appBar: AppBar(title: const Text('My Enrollments')),
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
              : _enrollments.isEmpty
              ? const Center(
                child: Text('You are not enrolled in any courses yet.'),
              )
              : ListView.builder(
                itemCount: _enrollments.length,
                itemBuilder: (context, index) {
                  final enrollment = _enrollments[index];
                  final course = enrollment['course'];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(course['title']),
                      subtitle: Text(
                        'Enrolled on: ${DateTime.parse(enrollment['enrollmentDate']).toLocal().toShortString()}',
                      ),
                      // You can add more details or navigation here
                    ),
                  );
                },
              ),
    );
  }
}

// Extension to format DateTime for display
extension DateTimeExtension on DateTime {
  String toShortString() {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/${year.toString()}';
  }
}
