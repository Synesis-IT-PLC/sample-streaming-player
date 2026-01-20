# Flutter HLS Streaming Player

A Flutter-based HLS (HTTP Live Streaming) video player with token-based authentication, converted from the React version.

## Features

- **HLS Streaming**: Plays HLS video streams using Flutter's `video_player` package
- **Token Authentication**: Automatic token refresh for secure playlist access
- **Quality Selection**: Manual quality/bitrate selection (Note: Limited support compared to hls.js)
- **Error Recovery**: Basic error handling for network and media errors
- **Custom Controls**: Built-in video player controls with play/pause functionality

## Project Structure

```
flutter/
├── lib/
│   ├── main.dart                 # Main app entry point
│   ├── hls_api.dart              # Token refresh API configuration and utilities
│   ├── hls_player.dart           # Main video player widget
│   └── hls_player_example.dart   # Example wrapper widget demonstrating usage
├── pubspec.yaml                  # Flutter dependencies
└── README.md                     # This file
```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  video_player: ^2.8.2
  http: ^1.2.0
  cupertino_icons: ^1.0.6
```

## Setup

1. **Install Flutter**: Make sure you have Flutter installed (SDK >=3.0.0)

2. **Install dependencies**:
   ```bash
   cd flutter
   flutter pub get
   ```

3. **Update backend configuration** in `lib/hls_api.dart`:
   ```dart
   const String backendUrl = 'https://your-backend-url.com/api';
   const String playlistAccessUrl = '$backendUrl/test/access';
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

## Usage

```dart
import 'package:sample_streaming_player/hls_player_example.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HLSPlayerExample(
      streamUrl: 'https://example.com/stream.m3u8',
    );
  }
}
```

## Key Differences from React Version

### 1. **HLS Library**
- **React**: Uses `hls.js` which provides extensive HLS features including:
  - Full manifest parsing
  - Quality/bitrate level selection
  - Request interception for token injection
  - Advanced error recovery
  
- **Flutter**: Uses `video_player` package which:
  - Relies on platform-native players (AVPlayer on iOS, ExoPlayer on Android)
  - Limited programmatic control over quality selection
  - Token injection requires URL manipulation (less flexible than request interception)

### 2. **Token Refresh**
- **React**: Uses `xhrSetup` callback to intercept all requests and inject tokens dynamically
- **Flutter**: Tokens are added to the initial URL. For dynamic token refresh, you may need to recreate the controller (limitation of `video_player`)

### 3. **Quality Selection**
- **React**: Full access to all quality levels via `hls.levels` API
- **Flutter**: Platform-dependent. iOS/Android native players handle quality selection, but programmatic control is limited

### 4. **Low Latency**
- **React**: Can configure `lowLatencyMode` and `backBufferLength` in hls.js
- **Flutter**: Depends on platform player settings, less configurable

## Alternative Flutter Packages

For more advanced HLS features, consider these alternatives:

1. **better_player**: More features than `video_player`, including better HLS support
   ```yaml
   better_player: ^0.0.83
   ```

2. **chewie**: A video player widget built on top of `video_player` with more controls
   ```yaml
   chewie: ^1.7.4
   ```

3. **flutter_vlc_player**: Uses VLC for more advanced streaming features
   ```yaml
   flutter_vlc_player: ^8.0.0
   ```

## Migration Notes

### Converting from React to Flutter

1. **State Management**: React hooks (`useState`, `useEffect`) → Flutter `StatefulWidget` with `setState()`

2. **Refs**: React `useRef` → Flutter `StatefulWidget` instance variables

3. **Lifecycle**: React `useEffect` with cleanup → Flutter `initState()` and `dispose()`

4. **Styling**: React inline styles → Flutter `Container`, `BoxDecoration`, etc.

5. **HTTP Requests**: `fetch` → `http` package

6. **Video Player**: `hls.js` + `<video>` → `VideoPlayerController` + `VideoPlayer` widget

## Limitations

- **Dynamic Token Injection**: Unlike hls.js which can intercept requests, Flutter's `video_player` requires URL manipulation. For dynamic token refresh, you may need to recreate the controller.

- **Quality Selection**: Programmatic quality selection is limited compared to hls.js. The native players handle this, but you have less control.

- **Request Interception**: Cannot intercept individual segment requests like hls.js can. Tokens must be added to the playlist URL upfront.

## Future Improvements

1. Consider using `better_player` or `flutter_vlc_player` for more advanced features
2. Implement a custom HLS parser if you need fine-grained control
3. Add quality selector UI that works with platform capabilities
4. Implement more robust error recovery mechanisms
