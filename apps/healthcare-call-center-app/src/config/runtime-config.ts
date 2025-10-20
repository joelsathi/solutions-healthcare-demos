// Runtime configuration utility
// This allows reading environment variables that are set at container runtime

interface RuntimeConfig {
  VITE_MPI_SERVICE_URL: string;
  VITE_DATA_AGGREGATOR_URL: string;
  VITE_CALL_CENTER_AI_AGENT_URL: string;
  VITE_PATIENT_MATCH_COUNT: string;
  VITE_PATIENT_MATCH_ONLY_SINGLE_MATCH: string;
  VITE_PATIENT_MATCH_ONLY_CERTAIN_MATCH: string;
  VITE_REACT_APP_ASGARDEO_CLIENT_ID: string;
  VITE_REACT_APP_ASGARDEO_CLIENT_SECRET: string;
  VITE_REACT_APP_ASGARDEO_BASE_URL: string;
  VITE_REACT_APP_REDIRECT_URL: string;
}

declare global {
  interface Window {
    __ENV__?: RuntimeConfig;
  }
}

/**
 * Get runtime configuration value
 * Falls back to build-time environment variables if runtime config is not available
 */
export function getRuntimeConfig(key: keyof RuntimeConfig): string {
  // Try to get from runtime configuration first
  if (window.__ENV__ && window.__ENV__[key]) {
    return window.__ENV__[key];
  }
  
  // Fallback to build-time environment variables
  return import.meta.env[key] || '';
}

/**
 * Get all runtime configuration
 */
export function getAllRuntimeConfig(): RuntimeConfig {
  const buildTimeEnv = {
    VITE_MPI_SERVICE_URL: import.meta.env.VITE_MPI_SERVICE_URL || 'http://localhost:8081',
    VITE_DATA_AGGREGATOR_URL: import.meta.env.VITE_DATA_AGGREGATOR_URL || 'http://localhost:8000',
    VITE_CALL_CENTER_AI_AGENT_URL: import.meta.env.VITE_CALL_CENTER_AI_AGENT_URL || 'http://localhost:9090',
    VITE_PATIENT_MATCH_COUNT: import.meta.env.VITE_PATIENT_MATCH_COUNT || '1',
    VITE_PATIENT_MATCH_ONLY_SINGLE_MATCH: import.meta.env.VITE_PATIENT_MATCH_ONLY_SINGLE_MATCH || 'true',
    VITE_PATIENT_MATCH_ONLY_CERTAIN_MATCH: import.meta.env.VITE_PATIENT_MATCH_ONLY_CERTAIN_MATCH || 'true',
    VITE_REACT_APP_ASGARDEO_CLIENT_ID: import.meta.env.VITE_REACT_APP_ASGARDEO_CLIENT_ID || '',
    VITE_REACT_APP_ASGARDEO_CLIENT_SECRET: import.meta.env.VITE_REACT_APP_ASGARDEO_CLIENT_SECRET || '',
    VITE_REACT_APP_ASGARDEO_BASE_URL: import.meta.env.VITE_REACT_APP_ASGARDEO_BASE_URL || '',
    VITE_REACT_APP_REDIRECT_URL: import.meta.env.VITE_REACT_APP_REDIRECT_URL || 'http://localhost:8080'
  };

  // Merge runtime config with build-time config, preferring runtime values
  return {
    ...buildTimeEnv,
    ...window.__ENV__
  };
}

/**
 * Helper functions for specific config values
 */
export const config = {
  get mpiServiceUrl() {
    return getRuntimeConfig('VITE_MPI_SERVICE_URL');
  },
  
  get dataAggregatorUrl() {
    return getRuntimeConfig('VITE_DATA_AGGREGATOR_URL');
  },
  
  get callCenterAiAgentUrl() {
    return getRuntimeConfig('VITE_CALL_CENTER_AI_AGENT_URL');
  },
  
  get patientMatchCount() {
    return parseInt(getRuntimeConfig('VITE_PATIENT_MATCH_COUNT'), 10);
  },
  
  get patientMatchOnlySingleMatch() {
    return getRuntimeConfig('VITE_PATIENT_MATCH_ONLY_SINGLE_MATCH') === 'true';
  },
  
  get patientMatchOnlyCertainMatch() {
    return getRuntimeConfig('VITE_PATIENT_MATCH_ONLY_CERTAIN_MATCH') === 'true';
  },
  
  get asgardeo() {
    return {
      clientId: getRuntimeConfig('VITE_REACT_APP_ASGARDEO_CLIENT_ID'),
      clientSecret: getRuntimeConfig('VITE_REACT_APP_ASGARDEO_CLIENT_SECRET'),
      baseUrl: getRuntimeConfig('VITE_REACT_APP_ASGARDEO_BASE_URL'),
      redirectUrl: getRuntimeConfig('VITE_REACT_APP_REDIRECT_URL')
    };
  }
};