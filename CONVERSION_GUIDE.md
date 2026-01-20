# React to Flutter Conversion Guide

This guide explains how to convert the React HLS player to Flutter and highlights key differences.

## Quick Start

1. **Navigate to Flutter project**:
   ```bash
   cd flutter
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Update backend URL** in `flutter/lib/hls_api.dart`:
   ```dart
   const String backendUrl = 'https://your-backend-url.com/api';
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

## Architecture Comparison

### React Structure
```
react/
├── hlsApi.js              → Token refresh logic
├── HLSPlayer.jsx          → Main player component
└── HLSPlayerExample.jsx   → Example wrapper
```

### Flutter Structure
```
flutter/lib/
├── hls_api.dart           → Token refresh logic (Dart)
├── hls_player.dart        → Main player widget
├── hls_player_example.dart → Example wrapper widget
└── main.dart              → App entry point
```

## Key Differences

### 1. HLS Library

| Feature | React (hls.js) | Flutter (video_player) |
|---------|---------------|------------------------|
| **Library** | hls.js v1.6.15 | video_player v2.8.2 |
| **Platform** | Browser-based | Native (AVPlayer/ExoPlayer) |
| **Request Interception** | ✅ Full control via `xhrSetup` | ❌ Limited (URL-based only) |
| **Quality Selection** | ✅ Full API access | ⚠️ Platform-dependent |
| **Low Latency Config** | ✅ Configurable | ⚠️ Limited control |
| **Manifest Parsing** | ✅ Full access | ❌ Not exposed |

### 2. Token Management

**React (hls.js)**:
```javascript
xhrSetup: async function (xhr, url) {
  await refreshTokensIfNeeded();
  const { playlistToken, playlistExpiry } = tokenRef.current;
  // Inject token into every request
  xhr.open('GET', `${url}?token=${playlistToken}&exp=${playlistExpiry}`, true);
}
```

**Flutter (video_player)**:
```dart
// Tokens must be added to initial URL
String url = widget.streamUrl;
if (_playlistToken != null) {
  final uri = Uri.parse(url).replace(
    queryParameters: {
      'token': _playlistToken!,
      'exp': _playlistExpiry.toString(),
    },
  );
  url = uri.toString();
}
_controller = VideoPlayerController.networkUrl(Uri.parse(url));
```

**Limitation**: Flutter's `video_player` doesn't support dynamic URL updates. To refresh tokens, you may need to recreate the controller.

### 3. State Management

**React**:
```javascript
const [levels, setLevels] = useState([]);
const [currentLevel, setCurrentLevel] = useState(-1);

useEffect(() => {
  // Setup logic
  return () => {
    // Cleanup
  };
}, [dependencies]);
```

**Flutter**:
```dart
class _HLSPlayerState extends State<HLSPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }
  
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
```

### 4. Component Lifecycle

| React | Flutter |
|-------|---------|
| `useEffect(() => {}, [])` | `initState()` |
| `useEffect(() => { return cleanup })` | `dispose()` |
| `useEffect(() => {}, [dep])` | `didUpdateWidget()` or `setState()` |

### 5. Styling

**React**:
```javascript
const containerStyle = {
  position: 'relative',
  width: '100%',
  backgroundColor: '#000',
  borderRadius: '8px',
};
<div style={containerStyle}>...</div>
```

**Flutter**:
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.black,
    borderRadius: BorderRadius.circular(8),
  ),
  child: ...
)
```

### 6. HTTP Requests

**React**:
```javascript
const response = await fetch(PLAYLIST_ACCESS_URL, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(PLAYLIST_PARAMS),
});
const data = await response.json();
```

**Flutter**:
```dart
import 'package:http/http.dart' as http;

final response = await http.post(
  Uri.parse(playlistAccessUrl),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode(playlistParams),
);
final data = jsonDecode(response.body);
```

## Feature Parity

### ✅ Implemented
- ✅ HLS video playback
- ✅ Token-based authentication
- ✅ Automatic token refresh
- ✅ Basic video controls (play/pause)
- ✅ Error handling structure
- ✅ Custom UI styling

### ⚠️ Partially Implemented
- ⚠️ Quality selection: Limited by platform capabilities
- ⚠️ Low latency: Depends on native player settings
- ⚠️ Dynamic token injection: Requires controller recreation

### ❌ Not Available
- ❌ Programmatic quality level access (like `hls.levels`)
- ❌ Request interception for individual segments
- ❌ Advanced HLS configuration (backBufferLength, etc.)

## Alternative Solutions

### Option 1: Use `better_player`
More features than `video_player`:
```yaml
dependencies:
  better_player: ^0.0.83
```

**Pros**:
- Better HLS support
- More configuration options
- Quality selection UI

**Cons**:
- Still limited compared to hls.js
- Larger package size

### Option 2: Use `flutter_vlc_player`
Uses VLC engine:
```yaml
dependencies:
  flutter_vlc_player: ^8.0.0
```

**Pros**:
- Advanced streaming features
- Better HLS control
- More similar to hls.js capabilities

**Cons**:
- Larger app size
- More complex setup

### Option 3: Custom HLS Parser
Build a custom solution using Dart packages:
- `m3u` package for manifest parsing
- Custom HTTP client for request interception
- More control but more work

## Migration Checklist

- [x] Convert `hlsApi.js` → `hls_api.dart`
- [x] Convert `HLSPlayer.jsx` → `hls_player.dart`
- [x] Convert `HLSPlayerExample.jsx` → `hls_player_example.dart`
- [x] Create `pubspec.yaml` with dependencies
- [x] Create `main.dart` entry point
- [ ] Test token refresh functionality
- [ ] Test on iOS device/simulator
- [ ] Test on Android device/emulator
- [ ] Implement quality selector (if needed)
- [ ] Add error recovery mechanisms
- [ ] Update backend URL configuration

## Testing

### Test Token Refresh
1. Set a short token expiry time
2. Play video and wait for token refresh
3. Verify video continues playing

### Test Error Handling
1. Disconnect network during playback
2. Verify error handling and recovery

### Test Quality Selection
1. If implemented, test quality switching
2. Verify video quality changes

## Troubleshooting

### Issue: Video doesn't play
- Check network permissions in `AndroidManifest.xml` and `Info.plist`
- Verify stream URL is accessible
- Check token is valid

### Issue: Token refresh doesn't work
- Verify backend URL is correct
- Check network requests in debug console
- Ensure token refresh method is called

### Issue: Quality selection not available
- This is a limitation of `video_player`
- Consider using `better_player` or `flutter_vlc_player`

## Next Steps

1. **Test the Flutter app** with your actual stream URL
2. **Update backend URL** in `hls_api.dart`
3. **Customize UI** to match your design requirements
4. **Add features** as needed (quality selector, subtitles, etc.)
5. **Consider alternatives** if you need advanced HLS features

## Resources

- [Flutter video_player documentation](https://pub.dev/packages/video_player)
- [better_player package](https://pub.dev/packages/better_player)
- [flutter_vlc_player package](https://pub.dev/packages/flutter_vlc_player)
- [HLS.js documentation](https://github.com/video-dev/hls.js/)
