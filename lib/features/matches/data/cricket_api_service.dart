import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Service for fetching live cricket data from Cricbuzz RapidAPI.
///
/// API key is loaded from `.env` via flutter_dotenv — never hardcoded.
/// Implements 10-second timeout and proper error handling.
class CricketApiService {
  CricketApiService();

  static const String _baseUrl = 'cricbuzz-cricket.p.rapidapi.com';
  static const String _host = 'cricbuzz-cricket.p.rapidapi.com';
  static const Duration _timeout = Duration(seconds: 10);

  /// RapidAPI key loaded from environment.
  String get _apiKey {
    final key = dotenv.env['RAPID_API_KEY'];
    if (key == null || key.isEmpty) {
      throw CricketApiException(
        'RAPID_API_KEY not found in .env file',
        isConfigError: true,
      );
    }
    return key;
  }

  /// Common headers for all API requests.
  Map<String, String> get _headers => {
        'x-rapidapi-host': _host,
        'x-rapidapi-key': _apiKey,
      };

  // ─── Generic GET helper ──────────────────────────────────

  Future<Map<String, dynamic>> _get(String path) async {
    final uri = Uri.https(_baseUrl, path);

    dev.log(
      'CricketAPI ▶ GET $uri',
      name: 'CricketApiService',
    );

    try {
      final response = await http
          .get(uri, headers: _headers)
          .timeout(_timeout);

      dev.log(
        'CricketAPI ◀ ${response.statusCode} (${response.body.length} bytes)',
        name: 'CricketApiService',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      } else if (response.statusCode == 429) {
        throw CricketApiException(
          'Rate limit exceeded. Please try again later.',
          statusCode: 429,
        );
      } else if (response.statusCode == 403) {
        throw CricketApiException(
          'Invalid API key or subscription expired.',
          statusCode: 403,
          isConfigError: true,
        );
      } else {
        throw CricketApiException(
          'API returned status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      dev.log(
        'CricketAPI ✕ Request timed out after ${_timeout.inSeconds}s',
        name: 'CricketApiService',
      );
      throw CricketApiException(
        'Request timed out. Check your internet connection.',
        isTimeout: true,
      );
    } on FormatException catch (e) {
      dev.log(
        'CricketAPI ✕ JSON parse error: $e',
        name: 'CricketApiService',
      );
      throw CricketApiException(
        'Failed to parse server response.',
      );
    } on CricketApiException {
      rethrow;
    } catch (e) {
      dev.log(
        'CricketAPI ✕ Unexpected error: $e',
        name: 'CricketApiService',
      );
      throw CricketApiException(
        'Network error. Please check your connection.',
      );
    }
  }

  // ─── Match List Endpoints ────────────────────────────────

  /// Fetch all currently live matches.
  /// GET /matches/v1/live
  Future<Map<String, dynamic>> fetchLiveMatches() => _get('/matches/v1/live');

  /// Fetch recently completed matches.
  /// GET /matches/v1/recent
  Future<Map<String, dynamic>> fetchRecentMatches() =>
      _get('/matches/v1/recent');

  /// Fetch upcoming scheduled matches.
  /// GET /matches/v1/upcoming
  Future<Map<String, dynamic>> fetchUpcomingMatches() =>
      _get('/matches/v1/upcoming');

  // ─── Scorecard Endpoint ──────────────────────────────────

  /// Fetch the high-score card for a given [matchId].
  /// GET /mcenter/v1/{matchId}/hscard
  Future<Map<String, dynamic>> fetchScorecard(String matchId) =>
      _get('/mcenter/v1/$matchId/hscard');
}

/// Custom exception for cricket API errors.
class CricketApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool isTimeout;
  final bool isConfigError;

  const CricketApiException(
    this.message, {
    this.statusCode,
    this.isTimeout = false,
    this.isConfigError = false,
  });

  @override
  String toString() => 'CricketApiException: $message';
}
