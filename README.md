# Sample Streaming Player

HLS (HTTP Live Streaming) video players with token-based authentication and quality selection features. Available in both **React** and **Flutter** implementations.

## Implementations

- **React**: Browser-based HLS player using hls.js
- **Flutter**: Native mobile HLS player using video_player package

See [CONVERSION_GUIDE.md](./CONVERSION_GUIDE.md) for details on converting between React and Flutter.

---

## React Implementation

## Features

- **HLS Streaming**: Plays HLS video streams using hls.js
- **Token Authentication**: Automatic token refresh for secure playlist access
- **Quality Selection**: Manual quality/bitrate selection with adaptive bitrate support
- **Low Latency**: Configured for low-latency streaming
- **Error Recovery**: Automatic error handling and recovery for network and media errors

## Components

- `HLSPlayer.jsx`: Main video player component with quality selector
- `HLSPlayerExample.jsx`: Example wrapper component demonstrating usage
- `hlsApi.js`: Token refresh API configuration and utilities

## Usage

```jsx
import HLSPlayerExample from './react/HLSPlayerExample';

function App() {
  return (
    <HLSPlayerExample streamUrl="https://example.com/stream.m3u8" />
  );
}
```

## Props

### HLSPlayer
- `streamUrl` (required): URL of the HLS stream playlist (.m3u8)
- `tokenRefreshMethod` (optional): Function that returns `{ playlistToken, playlistExpiry }`
- `abrEnabled` (optional): Enable/disable adaptive bitrate (default: `true`)
- `playlistRefreshThreshold` (optional): Seconds before expiry to refresh token (default: `15`)

### HLSPlayerExample
- `streamUrl` (required): URL of the HLS stream playlist (.m3u8)

## Dependencies

```
"dependencies": {
  "hls.js": "^1.6.15",
  "prop-types": "^15.8.1",
  "react": "^19.2.3",
  "react-dom": "^19.2.3",
  "react-scripts": "5.0.1"
}
```

## Configuration

Update the backend URL and API endpoints in `react/hlsApi.js`:

```javascript
const BACKEND_URL = 'https://your-backend-url.com/api';
const PLAYLIST_ACCESS_URL = `${BACKEND_URL}/test/access`;
```

---

## Flutter Implementation

See the [flutter/README.md](./flutter/README.md) for Flutter-specific documentation.

### Quick Start

```bash
cd flutter
flutter pub get
flutter run
```

### Configuration

Update the backend URL in `flutter/lib/hls_api.dart`:

```dart
const String backendUrl = 'https://your-backend-url.com/api';
const String playlistAccessUrl = '$backendUrl/test/access';
```

