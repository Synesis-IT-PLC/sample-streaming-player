/**
 * Token refresh callback interface
 * 
 * @typedef {Function} TokenRefreshCallback
 * @returns {Promise<{playlistToken: string, playlistExpiry: number}>}
 * 
 * Clients should implement this function to provide their own secure API communication.
 * The function should handle:
 * - Authentication headers/tokens (OAuth, JWT, API keys, etc.)
 * - Request signing
 * - Error handling
 * - Rate limiting
 * - Certificate pinning
 * - Any other security requirements specific to the client's backend
 * 
 * The function must return a Promise that resolves to an object with:
 * - `playlistToken` (string): The access token for the playlist
 * - `playlistExpiry` (number): Unix timestamp (seconds) when the token expires
 * 
 * @example
 * // Client implementation example:
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
 */

// Configuration - Used by legacy createTokenRefreshFunction only
const BACKEND_URL = 'https://your-backend-url.com/api';
const PLAYLIST_ACCESS_URL = `${BACKEND_URL}/test/access`;
const PLAYLIST_PARAMS = {
  stream_id: 'stream_id',
};

/**
 * Creates a token refresh function that handles playlist access tokens
 * 
 * **DEPRECATED**: This factory function makes direct HTTP calls with hardcoded
 * backend configuration. For production use, clients should implement their own
 * `TokenRefreshCallback` function with secure API communication logic.
 * 
 * This function is kept for backward compatibility and simple testing only.
 * 
 * @deprecated Implement a custom TokenRefreshCallback for secure API communication
 * @returns {TokenRefreshCallback} Token refresh function that returns { playlistToken, playlistExpiry }
 */
export const createTokenRefreshFunction = () => {
  const PLAYLIST_REFRESH_THRESHOLD = 15;   // Refresh when < 15s remaining

  let playlistToken = null;
  let playlistExpiry = 0;

  const needsRefresh = (expiry, threshold) => {
    const now = Math.floor(Date.now() / 1000);
    const timeRemaining = expiry - now;
    return timeRemaining < threshold;
  };

  const getPlaylistAccess = async () => {
    const response = await fetch(PLAYLIST_ACCESS_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(PLAYLIST_PARAMS),
    });
    return response.json();
  };

  return async () => {
    // Check and refresh playlist token if needed
    if (!playlistToken || needsRefresh(playlistExpiry, PLAYLIST_REFRESH_THRESHOLD)) {
      try {
        const res = await getPlaylistAccess();
        playlistToken = res.data.token;
        playlistExpiry = res.data.expiration;
      } catch (error) {
        throw error;
      }
    }

    return {
      playlistToken,
      playlistExpiry,
    };
  };
};

