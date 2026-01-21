import 'dart:convert';
import 'package:http/http.dart' as http;

/// Token refresh callback interface for client authentication
/// 
/// Clients should implement this function to provide their own secure API communication.
/// The function should handle:
/// - Authentication headers/tokens (OAuth, JWT, API keys, etc.)
/// - Request signing
/// - Error handling
/// - Rate limiting
/// - Certificate pinning
/// - Any other security requirements specific to the client's backend
/// 
/// The function must return a Future<Map<String, dynamic>> with the following structure:
/// ```dart
/// {
///   'playlistToken': String,  // The access token for the playlist
///   'playlistExpiry': int,    // Unix timestamp (seconds) when the token expires
/// }
/// ```
/// 
/// Example client implementation:
/// ```dart
/// Future<Map<String, dynamic>> mySecureTokenRefresh() async {
///   final response = await http.post(
///     Uri.parse('https://client-backend.com/api/secure/token'),
///     headers: {
///       'Authorization': 'Bearer ${clientAuthToken}',
///       'X-API-Key': clientApiKey,
///       'Content-Type': 'application/json',
///     },
///     body: jsonEncode({'stream_id': streamId}),
///   );
///   
///   if (response.statusCode == 200) {
///     final data = jsonDecode(response.body);
///     return {
///       'playlistToken': data['token'],
///       'playlistExpiry': data['expiration'],
///     };
///   } else {
///     throw Exception('Token refresh failed');
///   }
/// }
/// ```
typedef TokenRefreshCallback = Future<Map<String, dynamic>> Function();

// Configuration - Used by legacy TokenRefreshFunction only
const String backendUrl = 'https://your-backend-url.com/api';
const String playlistAccessUrl = '$backendUrl/test/access';
const Map<String, String> playlistParams = {
  'stream_id': 'stream_id',
};

/// Token refresh function that handles playlist access tokens
/// 
/// **DEPRECATED**: This class makes direct HTTP calls with hardcoded configuration.
/// For production use, clients should implement their own `TokenRefreshCallback`
/// function with secure API communication logic.
/// 
/// This class is kept for backward compatibility and simple testing only.
/// 
/// @deprecated Use a custom `TokenRefreshCallback` instead
@Deprecated('Use a custom TokenRefreshCallback for secure API communication')
class TokenRefreshFunction {
  static const int playlistRefreshThreshold = 15; // Refresh when < 15s remaining

  String? playlistToken;
  int playlistExpiry = 0;

  bool _needsRefresh(int expiry, int threshold) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final timeRemaining = expiry - now;
    return timeRemaining < threshold;
  }

  Future<Map<String, dynamic>> _getPlaylistAccess() async {
    final response = await http.post(
      Uri.parse(playlistAccessUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(playlistParams),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get playlist access: ${response.statusCode}');
    }
  }

  /// Refreshes token if needed and returns current token and expiry
  Future<Map<String, dynamic>> refreshToken() async {
    // Check and refresh playlist token if needed
    if (playlistToken == null || 
        _needsRefresh(playlistExpiry, playlistRefreshThreshold)) {
      try {
        final res = await _getPlaylistAccess();
        playlistToken = res['data']['token'] as String;
        playlistExpiry = res['data']['expiration'] as int;
      } catch (error) {
        rethrow;
      }
    }

    return {
      'playlistToken': playlistToken,
      'playlistExpiry': playlistExpiry,
    };
  }
}

/// Creates a token refresh function instance
/// 
/// **DEPRECATED**: This factory function creates a TokenRefreshFunction with
/// hardcoded backend configuration. For production use, clients should implement
/// their own `TokenRefreshCallback` function.
/// 
/// This function is kept for backward compatibility and simple testing only.
/// 
/// @deprecated Implement a custom `TokenRefreshCallback` instead
@Deprecated('Implement a custom TokenRefreshCallback for secure API communication')
TokenRefreshFunction createTokenRefreshFunction() {
  return TokenRefreshFunction();
}
