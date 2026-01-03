# Sample Streaming Player

A React-based HLS (HTTP Live Streaming) video player with token-based authentication and quality selection features.

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

