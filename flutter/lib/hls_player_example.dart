import 'package:flutter/material.dart';
import 'hls_player.dart';
import 'hls_api.dart';

const bool abrEnabled = true; // Adaptive bitrate enabled by default
const int playlistRefreshThreshold = 15; // Refresh when < 15s remaining

class HLSPlayerExample extends StatelessWidget {
  final String streamUrl;

  const HLSPlayerExample({
    super.key,
    required this.streamUrl,
  });

  @override
  Widget build(BuildContext context) {
    final tokenRefreshFunction = createTokenRefreshFunction();

    return HLSPlayer(
      streamUrl: streamUrl,
      tokenRefreshMethod: tokenRefreshFunction.refreshToken,
      abrEnabled: abrEnabled,
      playlistRefreshThreshold: playlistRefreshThreshold,
    );
  }
}
