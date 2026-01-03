// Configuration
const BACKEND_URL = 'https://your-backend-url.com/api';
const PLAYLIST_ACCESS_URL = `${BACKEND_URL}/test/access`;
const PLAYLIST_PARAMS = {
  stream_id: 'stream_id',
};

/**
 * Creates a token refresh function that handles playlist access tokens
 * Uses the default configuration from this file
 * @returns {Function} Token refresh function that returns { playlistToken, playlistExpiry }
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

