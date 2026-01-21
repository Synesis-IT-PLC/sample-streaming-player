import { useEffect, useRef, useState } from 'react';
import PropTypes from 'prop-types';
import Hls from 'hls.js';

const containerStyle = {
  position: 'relative',
  width: '100%',
  maxWidth: '100%',
  backgroundColor: '#000',
  borderRadius: '8px',
  overflow: 'hidden',
};

const videoStyle = {
  width: '100%',
  height: 'auto',
  display: 'block',
  minHeight: '400px',
};

const qualitySelectorStyle = {
  position: 'absolute',
  top: '10px',
  right: '10px',
  zIndex: 20,
  display: 'flex',
  alignItems: 'center',
  gap: '8px',
  backgroundColor: 'rgba(0, 0, 0, 0.7)',
  padding: '8px 12px',
  borderRadius: '6px',
  backdropFilter: 'blur(4px)',
};

const labelStyle = {
  color: '#fff',
  fontSize: '14px',
  fontWeight: 500,
  whiteSpace: 'nowrap',
};

const selectStyle = {
  backgroundColor: 'rgba(255, 255, 255, 0.1)',
  color: '#fff',
  border: '1px solid rgba(255, 255, 255, 0.2)',
  borderRadius: '4px',
  padding: '6px 10px',
  fontSize: '14px',
  cursor: 'pointer',
  outline: 'none',
  transition: 'all 0.2s ease',
  minWidth: '120px',
};

/**
 * HLS video player component with token-based authentication support
 * 
 * The player supports client-provided authentication through the
 * `tokenRefreshMethod` parameter. Clients should implement their own
 * secure API communication logic rather than relying on the SDK's
 * default implementation.
 * 
 * @param {string} streamUrl - URL of the HLS stream playlist (.m3u8)
 * @param {TokenRefreshCallback} [tokenRefreshMethod] - Token refresh callback
 *   that returns { playlistToken, playlistExpiry }. Recommended: Implement
 *   your own callback with secure API communication. See hlsApi.js for
 *   interface details. If not provided, the player will load the stream
 *   without authentication.
 * @param {boolean} [abrEnabled=true] - Enable/disable adaptive bitrate streaming
 * @param {number} [playlistRefreshThreshold=15] - Seconds before token expiry
 *   to trigger a refresh
 */
export default function HLSPlayer({ streamUrl, tokenRefreshMethod, abrEnabled = true, playlistRefreshThreshold = 15 }) {
  const videoRef = useRef(null);
  const hlsRef = useRef(null);
  const tokenRef = useRef({
    playlistToken: null,
    playlistExpiry: 0,
  });
  
  const [levels, setLevels] = useState([]);
  const [currentLevel, setCurrentLevel] = useState(-1);

  useEffect(() => {
    if (!streamUrl) return;

    const video = videoRef.current;
    if (!video) return;

    const needsRefresh = (expiry, threshold) => {
      const now = Math.floor(Date.now() / 1000);
      const timeRemaining = expiry - now;
      return timeRemaining < threshold;
    };

    const refreshTokensIfNeeded = async () => {
      if (!tokenRefreshMethod) return;

      const tokens = tokenRef.current;

      if (!tokens.playlistToken || needsRefresh(tokens.playlistExpiry, playlistRefreshThreshold)) {
        try {
          const result = await tokenRefreshMethod();
          tokens.playlistToken = result.playlistToken;
          tokens.playlistExpiry = result.playlistExpiry;
        } catch (error) {
          // Token refresh failed
        }
      }
    };

    if (Hls.isSupported()) {
      const hls = new Hls({
        enableWorker: true,
        lowLatencyMode: true,
        backBufferLength: 90,
        xhrSetup: async function (xhr, url) {
          if (url.includes('.m3u8') || url.includes('.ts')) {
            await refreshTokensIfNeeded();
            
            const { playlistToken, playlistExpiry } = tokenRef.current;
            if (playlistToken && playlistExpiry) {
              try {
                const baseUrl = url.startsWith('http') ? undefined : streamUrl;
                const u = new URL(url, baseUrl);
                u.searchParams.set('token', playlistToken);
                u.searchParams.set('exp', playlistExpiry.toString());
                xhr.open('GET', u.toString(), true);
              } catch (error) {
                const separator = url.includes('?') ? '&' : '?';
                xhr.open('GET', `${url}${separator}token=${encodeURIComponent(playlistToken)}&exp=${playlistExpiry}`, true);
              }
            }
          }
        },
      });

      hlsRef.current = hls;
      hls.loadSource(streamUrl);
      hls.attachMedia(video);

      hls.on(Hls.Events.MANIFEST_PARSED, () => {
        const availableLevels = hls.levels;
        const bitrateOptions = availableLevels.map((level, index) => ({
          index,
          height: level.height,
          width: level.width,
          bitrate: level.bitrate,
          bitrateFormatted: level.bitrate ? `${(level.bitrate / 1000).toFixed(0)} kbps` : 'Unknown',
          codec: level.codecSet || 'Unknown',
          name: level.name || `${level.height}p${level.bitrate ? ` @ ${(level.bitrate / 1000).toFixed(0)}kbps` : ''}`,
          url: level.url || 'N/A',
        }));
        
        setLevels(bitrateOptions);
        
        if (abrEnabled) {
          setCurrentLevel(-1);
          hls.currentLevel = -1;
        } else {
          setCurrentLevel(0);
          hls.currentLevel = 0;
        }
        
        video.play().catch(() => {});
      });

      hls.on(Hls.Events.LEVEL_SWITCHED, (event, data) => {
        if (!abrEnabled && hls.currentLevel !== -1) {
          return;
        }
      });

      hls.on(Hls.Events.ERROR, (event, data) => {
        if (data.fatal) {
          switch (data.type) {
            case Hls.ErrorTypes.NETWORK_ERROR:
              hls.startLoad();
              break;
            case Hls.ErrorTypes.MEDIA_ERROR:
              hls.recoverMediaError();
              break;
            default:
              hls.destroy();
              break;
          }
        }
      });
    }

    return () => {
      if (hlsRef.current) {
        hlsRef.current.destroy();
        hlsRef.current = null;
      }
      setLevels([]);
      setCurrentLevel(-1);
    };
  }, [streamUrl, tokenRefreshMethod, abrEnabled]);

  const handleQualityChange = (e) => {
    const selectedLevel = parseInt(e.target.value);
    const hls = hlsRef.current;
    
    if (!hls) return;
    
    setCurrentLevel(selectedLevel);
    
    if (selectedLevel === -1) {
      hls.currentLevel = -1;
    } else {
      hls.currentLevel = selectedLevel;
    }
  };

  return (
    <div style={containerStyle}>
      {levels.length > 0 && (
        <div style={qualitySelectorStyle}>
          <label htmlFor="quality-select" style={labelStyle}>Quality:</label>
          <select
            id="quality-select"
            value={currentLevel}
            onChange={handleQualityChange}
            style={selectStyle}
            onMouseEnter={(e) => {
              e.target.style.backgroundColor = 'rgba(255, 255, 255, 0.15)';
              e.target.style.borderColor = 'rgba(255, 255, 255, 0.3)';
            }}
            onMouseLeave={(e) => {
              e.target.style.backgroundColor = 'rgba(255, 255, 255, 0.1)';
              e.target.style.borderColor = 'rgba(255, 255, 255, 0.2)';
            }}
          >
            {abrEnabled && <option value={-1}>Auto</option>}
            {levels.map((level) => (
              <option key={level.index} value={level.index}>
                {level.bitrateFormatted}
              </option>
            ))}
          </select>
        </div>
      )}
      <video
        ref={videoRef}
        style={videoStyle}
        controls
        autoPlay
        playsInline
        muted={false}
      >
        <track kind="captions" />
      </video>
    </div>
  );
}

HLSPlayer.propTypes = {
  streamUrl: PropTypes.string.isRequired,
  tokenRefreshMethod: PropTypes.func,
  abrEnabled: PropTypes.bool,
  playlistRefreshThreshold: PropTypes.number,
};
