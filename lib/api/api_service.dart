import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'http://192.168.100.224:5000/api';

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (includeAuth) {
      String? token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // --- Auth Endpoints ---
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    String role,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: await _getHeaders(includeAuth: false),
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: await _getHeaders(includeAuth: false),
      body: json.encode({'email': email, 'password': password}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/auth/me'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  // --- Course Endpoints ---
  Future<List<dynamic>> getCourses() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/courses'),
      headers: await _getHeaders(includeAuth: false), // Courses can be public
    );
    return _handleListResponse(response);
  }

  Future<Map<String, dynamic>> getCourseById(String id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/courses/$id'),
      headers: await _getHeaders(includeAuth: false),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> createCourse(
    Map<String, dynamic> courseData,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/courses'),
      headers: await _getHeaders(),
      body: json.encode(courseData),
    );
    return _handleResponse(response);
  }

  // --- Enrollment Endpoints ---
  Future<Map<String, dynamic>> enrollInCourse(String courseId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/enrollments'),
      headers: await _getHeaders(),
      body: json.encode({'courseId': courseId}),
    );
    return _handleResponse(response);
  }

  Future<List<dynamic>> getMyEnrollments() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/enrollments/my-courses'),
      headers: await _getHeaders(),
    );
    return _handleListResponse(response);
  }

  // --- Assignment Endpoints ---
  Future<Map<String, dynamic>> submitAssignment(
    String courseId,
    String title,
    String description,
    String submissionText,
    String? submissionFileUrl,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/assignments'),
      headers: await _getHeaders(),
      body: json.encode({
        'courseId': courseId,
        'title': title,
        'description': description,
        'submissionText': submissionText,
        'submissionFileUrl': submissionFileUrl,
      }),
    );
    return _handleResponse(response);
  }

  Future<List<dynamic>> getMySubmittedAssignments() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/assignments/my-submissions'),
      headers: await _getHeaders(),
    );
    return _handleListResponse(response);
  }

  // --- Quiz Endpoints ---
  Future<Map<String, dynamic>> createQuiz(Map<String, dynamic> quizData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/quizzes'),
      headers: await _getHeaders(),
      body: json.encode(quizData),
    );
    return _handleResponse(response);
  }

  Future<List<dynamic>> getQuizzesByCourse(String courseId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/quizzes/course/$courseId'),
      headers: await _getHeaders(),
    );
    return _handleListResponse(response);
  }

  Future<Map<String, dynamic>> getQuizById(String quizId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/quizzes/$quizId'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> submitQuiz(
    String quizId,
    List<Map<String, String>> answers,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/quizzes/$quizId/submit'),
      headers: await _getHeaders(),
      body: json.encode({'answers': answers}),
    );
    return _handleResponse(response);
  }

  Future<List<dynamic>> getMyQuizResults() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/quiz-results/my-results'),
      headers: await _getHeaders(),
    );
    return _handleListResponse(response);
  }

  // Helper to handle responses
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      print('API Error: ${response.statusCode} - ${response.body}');
      throw Exception(
        'Failed to load data: ${json.decode(response.body)['msg'] ?? 'Unknown error'}',
      );
    }
  }

  List<dynamic> _handleListResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      print('API Error: ${response.statusCode} - ${response.body}');
      throw Exception(
        'Failed to load data: ${json.decode(response.body)['msg'] ?? 'Unknown error'}',
      );
    }
  }
}
