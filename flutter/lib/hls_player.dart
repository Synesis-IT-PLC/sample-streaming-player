import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'hls_api.dart';

/// HLS video player widget with token-based authentication support
/// 
/// The player supports client-provided authentication through the
/// `tokenRefreshCallback` parameter. Clients should implement their own
/// secure API communication logic rather than relying on the SDK's
/// default implementation.
class HLSPlayer extends StatefulWidget {
  final String streamUrl;
  
  /// Token refresh callback that returns playlist token and expiry
  /// 
  /// **Recommended**: Implement your own callback with secure API communication.
  /// This allows you to:
  /// - Add authentication headers (OAuth, JWT, API keys)
  /// - Implement request signing
  /// - Handle custom error cases
  /// - Add certificate pinning
  /// - Control rate limiting
  /// 
  /// The callback should return:
  /// ```dart
  /// {
  ///   'playlistToken': String,  // The access token
  ///   'playlistExpiry': int,    // Unix timestamp (seconds)
  /// }
  /// ```
  /// 
  /// See `TokenRefreshCallback` typedef in `hls_api.dart` for interface details.
  /// 
  /// If not provided, the player will load the stream without authentication.
  final TokenRefreshCallback? tokenRefreshCallback;
  
  /// Enable/disable adaptive bitrate streaming
  final bool abrEnabled;
  
  /// Seconds before token expiry to trigger a refresh
  final int playlistRefreshThreshold;

  const HLSPlayer({
    super.key,
    required this.streamUrl,
    this.tokenRefreshCallback,
    this.abrEnabled = true,
    this.playlistRefreshThreshold = 15,
  });

  /// Legacy property name - maps to tokenRefreshCallback
  /// @deprecated Use tokenRefreshCallback instead
  @Deprecated('Use tokenRefreshCallback instead')
  TokenRefreshCallback? get tokenRefreshMethod => tokenRefreshCallback;

  @override
  State<HLSPlayer> createState() => _HLSPlayerState();
}

class _HLSPlayerState extends State<HLSPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  String? _playlistToken;
  int _playlistExpiry = 0;
  Timer? _tokenRefreshTimer;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _startTokenRefreshTimer();
  }

  @override
  void dispose() {
    _tokenRefreshTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  bool _needsRefresh(int expiry, int threshold) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final timeRemaining = expiry - now;
    return timeRemaining < threshold;
  }

  Future<void> _refreshTokensIfNeeded() async {
    final callback = widget.tokenRefreshCallback;
    if (callback == null) return;

    if (_playlistToken == null || 
        _needsRefresh(_playlistExpiry, widget.playlistRefreshThreshold)) {
      try {
        final result = await callback();
        setState(() {
          _playlistToken = result['playlistToken'] as String?;
          _playlistExpiry = result['playlistExpiry'] as int? ?? 0;
        });
      } catch (error) {
        // Token refresh failed - handle error if needed
        debugPrint('Token refresh failed: $error');
      }
    }
  }

  Future<void> _initializePlayer() async {
    String url = widget.streamUrl;

    // Add token to URL if available
    if (widget.tokenRefreshCallback != null) {
      await _refreshTokensIfNeeded();
      if (_playlistToken != null && _playlistExpiry > 0) {
        final uri = Uri.parse(url);
        final updatedUri = uri.replace(
          queryParameters: {
            ...uri.queryParameters,
            'token': _playlistToken!,
            'exp': _playlistExpiry.toString(),
          },
        );
        url = updatedUri.toString();
      }
    }

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
      videoPlayerOptions: VideoPlayerOptions(
        allowBackgroundPlayback: false,
      ),
    );

    _controller!.addListener(() {
      if (_controller!.value.isInitialized && !_isInitialized) {
        setState(() {
          _isInitialized = true;
        });
        _controller!.play();
      }
    });

    try {
      await _controller!.initialize();
    } catch (error) {
      debugPrint('Error initializing video player: $error');
    }
  }

  void _startTokenRefreshTimer() {
    if (widget.tokenRefreshCallback == null) return;

    _tokenRefreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) async {
        await _refreshTokensIfNeeded();
        
        // Update URL with new token if needed
        if (_playlistToken != null && _playlistExpiry > 0) {
          final uri = Uri.parse(widget.streamUrl);
          final updatedUri = uri.replace(
            queryParameters: {
              ...uri.queryParameters,
              'token': _playlistToken!,
              'exp': _playlistExpiry.toString(),
            },
          );
          
          // Note: video_player doesn't support dynamic URL updates
          // You may need to recreate the controller for token updates
          // This is a limitation compared to hls.js which can intercept requests
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            if (_controller != null && _isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            if (_controller != null && _isInitialized)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VideoProgressIndicator(
                  _controller!,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Colors.blue,
                    bufferedColor: Colors.grey,
                    backgroundColor: Colors.white24,
                  ),
                ),
              ),
            if (_controller != null && _isInitialized)
              Positioned.fill(
                child: VideoPlayerControls(controller: _controller!),
              ),
          ],
        ),
      ),
    );
  }
}

class VideoPlayerControls extends StatefulWidget {
  final VideoPlayerController controller;

  const VideoPlayerControls({super.key, required this.controller});

  @override
  State<VideoPlayerControls> createState() => _VideoPlayerControlsState();
}

class _VideoPlayerControlsState extends State<VideoPlayerControls> {
  bool _isPlaying = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_videoListener);
    _isPlaying = widget.controller.value.isPlaying;
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    widget.controller.removeListener(_videoListener);
    super.dispose();
  }

  void _videoListener() {
    if (widget.controller.value.isPlaying != _isPlaying) {
      setState(() {
        _isPlaying = widget.controller.value.isPlaying;
      });
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (widget.controller.value.isPlaying) {
        widget.controller.pause();
        _isPlaying = false;
      } else {
        widget.controller.play();
        _isPlaying = true;
      }
    });
    _resetHideControlsTimer();
  }

  void _resetHideControlsTimer() {
    _hideControlsTimer?.cancel();
    setState(() {
      _showControls = true;
    });
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _resetHideControlsTimer,
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: Center(
            child: IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 64,
              ),
              onPressed: _togglePlayPause,
            ),
          ),
        ),
      ),
    );
  }
}
