import 'dart:convert';
import 'package:http/http.dart' as http;

// Configuration
const String backendUrl = 'https://your-backend-url.com/api';
const String playlistAccessUrl = '$backendUrl/test/access';
const Map<String, String> playlistParams = {
  'stream_id': 'stream_id',
};

/// Token refresh function that handles playlist access tokens
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
TokenRefreshFunction createTokenRefreshFunction() {
  return TokenRefreshFunction();
}
