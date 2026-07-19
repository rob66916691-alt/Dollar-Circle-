import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/app_config.dart';
import '../models/assistance_request.dart';
import 'auth_service.dart';

class ApiService {
  final AuthService authService;
  ApiService(this.authService);

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _get('/users/me');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<AssistanceRequest>> getApprovedRequests() async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/requests/approved'),
      headers: {'Content-Type': 'application/json'},
    );
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => AssistanceRequest.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<AssistanceRequest>> getMyRequests() async {
    final response = await _get('/requests/mine');
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => AssistanceRequest.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createRequest({
    required String title,
    required String description,
    required double amountRequested,
  }) async {
    final response = await _post('/requests', {
      'title': title,
      'description': description,
      'amountRequested': amountRequested,
    });
    _ensureSuccess(response);
  }

  Future<void> contribute({
    required String requestId,
    required double amount,
  }) async {
    final response = await _post('/contributions', {
      'requestId': requestId,
      'amount': amount,
    });
    _ensureSuccess(response);
  }

  Future<http.Response> _get(String path) async {
    final token = await authService.getToken();
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    _ensureSuccess(response);
    return response;
  }

  Future<http.Response> _post(String path, Map<String, dynamic> body) async {
    final token = await authService.getToken();
    return http.post(
      Uri.parse('${AppConfig.apiBaseUrl}$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Request failed (${response.statusCode})';
      try {
        final data = jsonDecode(response.body);
        message = data['message']?.toString() ?? message;
      } catch (_) {}
      throw Exception(message);
    }
  }
}
