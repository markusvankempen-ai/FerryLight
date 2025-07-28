import axios from 'axios';
import { logDebug } from '../utils/debug';

// Create axios instance for client-side API calls
const api = axios.create({
  timeout: 15000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Server-side API endpoints (no credentials needed on client)
const FERRY_API = '/api/ferry';
const WEATHER_API = '/api/weather';
const ALL_DATA_API = '/api/all';
const HEALTH_API = '/api/health';

// Retry configuration
const RETRY_CONFIG = {
  maxRetries: 3,
  retryDelay: 2000, // Start with 2 seconds
  backoffMultiplier: 2, // Double the delay each retry
};

// Retry function with exponential backoff
const retryRequest = async (requestFn, retryCount = 0) => {
  try {
    return await requestFn();
  } catch (error) {
    if (retryCount >= RETRY_CONFIG.maxRetries) {
      throw error;
    }

    const isRetryableError = 
      error.code === 'ECONNABORTED' ||
      error.message.includes('ERR_INSUFFICIENT_RESOURCES') ||
      error.message.includes('ERR_NETWORK') ||
      error.message.includes('ERR_CONNECTION_REFUSED') ||
      error.message.includes('ERR_NAME_NOT_RESOLVED') ||
      (error.response && error.response.status >= 500);

    if (isRetryableError) {
      const delay = RETRY_CONFIG.retryDelay * Math.pow(RETRY_CONFIG.backoffMultiplier, retryCount);
      logDebug(`🔄 Retrying request in ${delay}ms (attempt ${retryCount + 1}/${RETRY_CONFIG.maxRetries + 1})`);
      
      await new Promise(resolve => setTimeout(resolve, delay));
      return retryRequest(requestFn, retryCount + 1);
    }

    throw error;
  }
};

// Add request logging interceptor
api.interceptors.request.use(
  (config) => {
    logDebug('📤 Client API Request:', {
      method: config.method?.toUpperCase(),
      url: config.url,
      headers: {
        'Content-Type': config.headers['Content-Type']
      }
    });
    
    return config;
  },
  (error) => {
    logDebug('❌ Client Request Error:', error.message);
    return Promise.reject(error);
  }
);

// Add response logging interceptor
api.interceptors.response.use(
  (response) => {
    logDebug(`✅ Client API Response: ${response.status} ${response.statusText}`, {
      url: response.config.url,
      method: response.config.method,
      dataSize: JSON.stringify(response.data).length,
      timestamp: new Date().toISOString()
    });
    
    return response;
  },
  (error) => {
    logDebug('❌ Client API Error:', {
      message: error.message,
      status: error.response?.status,
      url: error.config?.url,
      timestamp: new Date().toISOString()
    });
    
    return Promise.reject(error);
  }
);

// Mock data functions (fallback for when server is unavailable)
const getMockFerryData = () => ({
  timestamp: new Date().toLocaleString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: 'numeric',
    minute: 'numeric',
    second: 'numeric',
    hour12: true
  }),
  ferryStatus: {
    status: 'Service Temporarily Unavailable',
    lastUpdated: new Date().toLocaleDateString(),
    region: 'Cape Breton',
    terminalName: 'Englishtown'
  },
  directions: {
    jerseyToEnglishtown: {
      direction: 'Jersey Cove → Englishtown',
      travelTimeMinutes: '0',
      googleMapsLink: 'https://www.google.com/maps/dir/46.30780553485239,-60.54585387501085/46.2874294969484,-60.54020656840666',
      waitTime: {
        queueTime: '0',
        estimatedVehicles: 0,
        ferryTripsNeeded: 0,
        waitTime: 0,
        status: 'Unavailable'
      },
      status: 'Offline'
    },
    englishtownToJersey: {
      direction: 'Englishtown → Jersey Cove',
      travelTimeMinutes: '0',
      googleMapsLink: 'https://www.google.com/maps/dir/46.28089387880864,-60.544588227215534/46.29023591938331,-60.54164852618175',
      waitTime: {
        queueTime: '0',
        estimatedVehicles: 0,
        ferryTripsNeeded: 0,
        waitTime: 0,
        status: 'Unavailable'
      },
      status: 'Offline'
    }
  }
});

const getMockWeatherData = () => ({
  dateutc: new Date().toISOString().replace('T', ' ').split('.')[0],
  tempf: 68.0,
  tempc: 20.0,
  humidity: 65,
  winddir: 180,
  windspeedmph: 5.0,
  windspeedkmh: 8.0,
  windgustmph: 8.0,
  windgustkmh: 12.9,
  baromrelin: 29.95,
  baromrelhpa: 1014.0,
  uv: 0,
  solarradiation: 0,
  drain_piezomm: 0,
  mrain_piezomm: 0,
  yrain_piezomm: 0,
  conditions: 'Data Unavailable',
  stationtype: 'Offline',
  model: 'Mock Data'
});

// Single ferry data fetch (now calls server-side endpoint)
export const fetchFerryData = async () => {
  logDebug('🚢 Starting ferry data fetch from server...');
  
  try {
    const startTime = Date.now();
    
    const response = await retryRequest(async () => {
      return await api.get(FERRY_API);
    });
    
    const endTime = Date.now();
    
    logDebug(`✅ Ferry data fetched successfully in ${endTime - startTime}ms`);
    logDebug('📊 Ferry data structure:', {
      hasData: !!response.data,
      dataType: typeof response.data,
      keys: Object.keys(response.data || {}),
      hasTimestamp: !!response.data.timestamp,
      hasFerryStatus: !!response.data.ferryStatus,
      hasDirections: !!response.data.directions
    });
    
    return response.data;
  } catch (error) {
    logDebug('❌ Ferry data fetch failed, using mock data:', {
      error: error.message,
      status: error.response?.status,
      url: FERRY_API
    });
    
    // Return mock data when server is unavailable
    return getMockFerryData();
  }
};

// Single weather data fetch (now calls server-side endpoint)
export const fetchWeatherData = async () => {
  logDebug('☁️ Starting weather data fetch from server...');
  
  try {
    const startTime = Date.now();
    
    const response = await retryRequest(async () => {
      return await api.get(WEATHER_API);
    });
    
    const endTime = Date.now();
    
    logDebug(`✅ Weather data fetched successfully in ${endTime - startTime}ms`);
    logDebug('📊 Weather data structure:', {
      hasData: !!response.data,
      dataType: typeof response.data,
      keys: Object.keys(response.data || {}),
      hasTemp: !!response.data.tempf,
      hasHumidity: !!response.data.humidity,
      hasWind: !!response.data.windspeedkmh
    });
    
    return response.data;
  } catch (error) {
    logDebug('❌ Weather data fetch failed, using mock data:', {
      error: error.message,
      status: error.response?.status,
      url: WEATHER_API
    });
    
    // Return mock data when server is unavailable
    return getMockWeatherData();
  }
};

// Combined data fetch (now calls server-side endpoint)
export const fetchAllData = async () => {
  logDebug('🔄 Starting combined data fetch from server...');
  
  try {
    const startTime = Date.now();
    
    logDebug('📡 Calling server-side /api/all endpoint...');
    const response = await retryRequest(async () => {
      return await api.get(ALL_DATA_API);
    });
    
    const endTime = Date.now();
    
    const result = response.data;
    
    logDebug(`✅ Combined data fetch completed in ${endTime - startTime}ms`);
    logDebug('📊 Combined data summary:', {
      hasFerryData: !!result.ferry,
      hasWeatherData: !!result.weather,
      ferryKeys: Object.keys(result.ferry || {}),
      weatherKeys: Object.keys(result.weather || {}),
      timestamp: result.timestamp
    });
    
    return result;
  } catch (error) {
    logDebug('❌ Combined data fetch failed, using mock data:', {
      error: error.message,
      status: error.response?.status,
      url: ALL_DATA_API
    });
    
    // Return mock data when server is unavailable
    return {
      ferry: getMockFerryData(),
      weather: getMockWeatherData(),
      timestamp: new Date().toISOString()
    };
  }
};

// Server health check
export const testApiConnectivity = async () => {
  logDebug('🏥 Testing server connectivity...');
  
  try {
    const response = await api.get(HEALTH_API);
    logDebug('✅ Server health check passed:', response.data);
    return true;
  } catch (error) {
    logDebug('❌ Server health check failed:', {
      error: error.message,
      status: error.response?.status
    });
    return false;
  }
};

export default api; 