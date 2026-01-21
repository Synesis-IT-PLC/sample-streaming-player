import 'package:flutter/material.dart';
import 'hls_player.dart';
import 'hls_api.dart';

const bool abrEnabled = true; // Adaptive bitrate enabled by default
const int playlistRefreshThreshold = 15; // Refresh when < 15s remaining

/// Example HLS player widget demonstrating usage patterns
/// 
/// This example shows the legacy pattern using createTokenRefreshFunction.
/// For production use, clients should implement their own TokenRefreshCallback
/// with secure API communication.
/// 
/// Example of custom implementation:
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
/// 
/// // Usage:
/// HLSPlayer(
///   streamUrl: streamUrl,
///   tokenRefreshCallback: mySecureTokenRefresh,
/// )
/// ```
class HLSPlayerExample extends StatelessWidget {
  final String streamUrl;

  const HLSPlayerExample({
    super.key,
    required this.streamUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Legacy pattern - using hardcoded backend configuration
    // DEPRECATED: For production, implement your own TokenRefreshCallback
    final tokenRefreshFunction = createTokenRefreshFunction();

    return HLSPlayer(
      streamUrl: streamUrl,
      tokenRefreshCallback: tokenRefreshFunction.refreshToken,
      abrEnabled: abrEnabled,
      playlistRefreshThreshold: playlistRefreshThreshold,
    );
  }
}
