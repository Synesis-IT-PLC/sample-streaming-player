import { useMemo } from 'react';
import PropTypes from 'prop-types';
import HLSPlayer from './HLSPlayer';
import { createTokenRefreshFunction } from './hlsApi';

const ABR_ENABLED = true; // Adaptive bitrate enabled by default
const PLAYLIST_REFRESH_THRESHOLD = 15;   // Refresh when < 15s remaining

/**
 * Example HLS player component demonstrating usage patterns
 * 
 * This example shows the legacy pattern using createTokenRefreshFunction.
 * For production use, clients should implement their own TokenRefreshCallback
 * with secure API communication.
 * 
 * Example of custom implementation:
 * ```javascript
 * const mySecureTokenRefresh = async () => {
 *   const response = await fetch('https://client-backend.com/api/secure/token', {
 *     method: 'POST',
 *     headers: {
 *       'Authorization': `Bearer ${clientAuthToken}`,
 *       'X-API-Key': clientApiKey,
 *       'Content-Type': 'application/json',
 *     },
 *     body: JSON.stringify({ stream_id: streamId }),
 *   });
 *   
 *   const data = await response.json();
 *   return {
 *     playlistToken: data.token,
 *     playlistExpiry: data.expiration,
 *   };
 * };
 * 
 * // Usage:
 * <HLSPlayer 
 *   streamUrl={streamUrl}
 *   tokenRefreshMethod={mySecureTokenRefresh}
 * />
 * ```
 */
export default function HLSPlayerExample({ streamUrl }) {
  // Legacy pattern - using hardcoded backend configuration
  // DEPRECATED: For production, implement your own TokenRefreshCallback
  const tokenRefreshMethod = useMemo(() => {
    return createTokenRefreshFunction();
  }, []);

  return (
    <HLSPlayer 
      streamUrl={streamUrl} 
      tokenRefreshMethod={tokenRefreshMethod}
      abrEnabled={ABR_ENABLED}
      playlistRefreshThreshold={PLAYLIST_REFRESH_THRESHOLD}
    />
  );
}

HLSPlayerExample.propTypes = {
  streamUrl: PropTypes.string.isRequired,
};
