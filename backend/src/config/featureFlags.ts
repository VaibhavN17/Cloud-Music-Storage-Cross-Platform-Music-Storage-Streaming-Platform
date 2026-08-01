export const featureFlags = {
  ENABLE_PUBLIC_TRACKS: process.env.ENABLE_PUBLIC_TRACKS !== 'false',
  ENABLE_LYRICS: process.env.ENABLE_LYRICS !== 'false',
  ENABLE_ANALYTICS: process.env.ENABLE_ANALYTICS !== 'false',
  ENABLE_OAUTH: process.env.ENABLE_OAUTH !== 'false',
  ENABLE_2FA: process.env.ENABLE_2FA === 'true',
};
