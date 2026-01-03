import { useMemo } from 'react';
import PropTypes from 'prop-types';
import HLSPlayer from './HLSPlayer';
import { createTokenRefreshFunction } from './hlsApi';

const ABR_ENABLED = true; // Adaptive bitrate enabled by default
const PLAYLIST_REFRESH_THRESHOLD = 15;   // Refresh when < 15s remaining

export default function HLSPlayerExample({ streamUrl }) {
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
