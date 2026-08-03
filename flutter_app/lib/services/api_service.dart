import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/prediction_request.dart';
import '../models/prediction_result.dart';

/// Custom exception for network connectivity issues.
class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Custom exception for server-side errors.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException(this.message, {this.statusCode});

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Service layer for communicating with the FastAPI backend.
///
/// All network calls go through this class. Handles timeouts,
/// connectivity errors, and non-200 HTTP responses.
class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Checks whether the backend is reachable.
  ///
  /// Returns `true` if the `/health` endpoint responds with status 'running'.
  Future<bool> checkHealth() async {
    try {
      final response = await _client
          .get(Uri.parse('${AppConfig.baseUrl}/health'))
          .timeout(AppConfig.requestTimeout);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Sends a prediction request to the backend and returns the result.
  ///
  /// Throws:
  /// - [NetworkException] if the device cannot reach the server.
  /// - [ServerException] if the server returns a non-200 response.
  Future<PredictionResult> getPrediction(PredictionRequest request) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${AppConfig.baseUrl}/predict'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(AppConfig.requestTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw const NetworkException(
        'Request timed out. Please check your connection and try again.',
      );
    } on SocketException {
      throw const NetworkException(
        'Cannot connect to the server. Make sure the backend is running.',
      );
    } on HandshakeException {
      throw const NetworkException(
        'Secure connection failed. Please check your network settings.',
      );
    }
  }

  /// Parses an HTTP response and returns a [PredictionResult] or throws.
  PredictionResult _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return PredictionResult.fromJson(json);

      case 422:
        // Pydantic validation error
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final detail = json['detail']?.toString() ?? 'Invalid input provided.';
        throw ServerException('Validation error: $detail', statusCode: 422);

      case 503:
        throw const ServerException(
          'The ML model is not ready. Please train the model first.',
          statusCode: 503,
        );

      default:
        throw ServerException(
          'Server returned an unexpected error (${response.statusCode}).',
          statusCode: response.statusCode,
        );
    }
  }
}
