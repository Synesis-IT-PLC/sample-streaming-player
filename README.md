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
- `HLSPlayerExample.jsx`: Example wrapper component demonstrating usage (legacy pattern)
- `hlsApi.js`: Token refresh callback interface and legacy utilities

## Usage

### Basic Usage (Legacy Pattern)

For simple testing, you can use the legacy `createTokenRefreshFunction()`:

```jsx
import HLSPlayerExample from './react/HLSPlayerExample';

function App() {
  return (
    <HLSPlayerExample streamUrl="https://example.com/stream.m3u8" />
  );
}
```

**Note**: The legacy pattern uses hardcoded backend configuration and is deprecated for production use.

### Recommended: Custom Client Auth Implementation

For production use, implement your own `TokenRefreshCallback` with secure API communication:

```jsx
import HLSPlayer from './react/HLSPlayer';

// Implement your own secure token refresh function
const mySecureTokenRefresh = async () => {
  const response = await fetch('https://your-backend.com/api/secure/token', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${clientAuthToken}`,
      'X-API-Key': clientApiKey,
      'Content-Type': 'application/json',
      // Add any custom headers, signing, etc.
    },
    body: JSON.stringify({
      stream_id: streamId,
      // Add any client-specific parameters
    }),
  });
  
  // Handle response validation, error cases, etc.
  const data = await response.json();
  return {
    playlistToken: data.token,
    playlistExpiry: data.expiration,
  };
};

// Use your custom implementation
function App() {
  return (
    <HLSPlayer 
      streamUrl="https://example.com/stream.m3u8"
      tokenRefreshMethod={mySecureTokenRefresh}
    />
  );
}
```

### Client Auth Interface

The `TokenRefreshCallback` interface is defined in `hlsApi.js`. The callback must return a Promise that resolves to:
- `playlistToken` (string): The access token for the playlist
- `playlistExpiry` (number): Unix timestamp in seconds when the token expires

This approach allows clients to:
- Add authentication headers (OAuth, JWT, API keys)
- Implement request signing
- Handle custom error cases
- Add certificate pinning
- Control rate limiting
- Implement any other security requirements

## Props

### HLSPlayer
- `streamUrl` (required): URL of the HLS stream playlist (.m3u8)
- `tokenRefreshMethod` (optional): `TokenRefreshCallback` function that returns `{ playlistToken, playlistExpiry }`. Recommended: Implement your own secure callback. See `hlsApi.js` for interface details.
- `abrEnabled` (optional): Enable/disable adaptive bitrate (default: `true`)
- `playlistRefreshThreshold` (optional): Seconds before expiry to refresh token (default: `15`)

### HLSPlayerExample
- `streamUrl` (required): URL of the HLS stream playlist (.m3u8)

**Note**: `HLSPlayerExample` uses the legacy `createTokenRefreshFunction()` pattern which is deprecated for production use.

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

---

## Flutter Implementation

See the [flutter/README.md](./flutter/README.md) for Flutter-specific documentation.

### Quick Start

```bash
cd flutter
flutter pub get
flutter run
```

### Client Auth Implementation

For production use, implement your own `TokenRefreshCallback`. See [flutter/README.md](./flutter/README.md) for detailed examples and interface documentation.
