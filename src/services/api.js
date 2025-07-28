import axios from 'axios';
import { logDebug } from '../utils/debug';

// Create axios instance with base configuration
const api = axios.create({
  timeout: 15000, // Increased timeout
  headers: {
    'Content-Type': 'application/json',
  },
});

// Use environment variables for API credentials
const username = process.env.REACT_APP_API_USERNAME || 'demo';
const password = process.env.REACT_APP_API_PASSWORD || 'demo';
const credentials = btoa(`${username}:${password}`);

// API endpoints
const FERRY_API = process.env.REACT_APP_FERRY_API_URL || 'https://nodered.ferrylight.online/rbferry';
const WEATHER_API = process.env.REACT_APP_WEATHER_API_URL || 'https://nodered.ferrylight.online/rbweather';

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

// Add auth header to requests
api.interceptors.request.use(
  (config) => {
    // Add basic auth header
    config.headers.Authorization = `Basic ${credentials}`;
    
    logDebug('📤 API Request:', {
      method: config.method?.toUpperCase(),
      url: config.url,
      headers: {
        'Content-Type': config.headers['Content-Type'],
        'Authorization': 'Basic [REDACTED]'
      }
    });
    
    return config;
  },
  (error) => {
    logDebug('❌ Request Error:', error.message);
    return Promise.reject(error);
  }
);

// Error handling interceptor
api.interceptors.response.use(
  (response) => {
    logDebug(`✅ API Response: ${response.status} ${response.statusText}`, {
      url: response.config.url,
      method: response.config.method,
      dataSize: JSON.stringify(response.data).length,
      timestamp: new Date().toISOString()
    });
    
    // Log response data structure (first level only)
    if (response.data) {
      const dataKeys = Object.keys(response.data);
      logDebug('📊 Response Data Keys:', dataKeys);
      
      // Log specific data for ferry API
      if (response.config.url.includes('rbferry')) {
        const ferryData = response.data;
        logDebug('🚢 Ferry Data Summary:', {
          hasTimestamp: !!ferryData.timestamp,
          hasFerryStatus: !!ferryData.ferryStatus,
          hasDirections: !!ferryData.directions,
          ferryStatus: ferryData.ferryStatus?.status || 'Unknown',
          lastUpdated: ferryData.timestamp || 'Unknown'
        });
      }
      
      // Log specific data for weather API
      if (response.config.url.includes('rbweather')) {
        const weatherData = response.data;
        logDebug('☁️ Weather Data Summary:', {
          hasTemp: !!weatherData.tempf,
          hasHumidity: !!weatherData.humidity,
          hasWind: !!weatherData.windspeedkmh,
          temperature: weatherData.tempf || 'Unknown',
          humidity: weatherData.humidity || 'Unknown',
          lastUpdated: weatherData.dateutc || 'Unknown'
        });
      }
    }
    
    return response;
  },
  (error) => {
    const errorInfo = {
      message: error.message,
      status: error.response?.status,
      statusText: error.response?.statusText,
      url: error.config?.url,
      method: error.config?.method,
      timestamp: new Date().toISOString(),
      code: error.code,
      isRetryable: false
    };
    
    // Determine if error is retryable
    errorInfo.isRetryable = 
      error.code === 'ECONNABORTED' ||
      error.message.includes('ERR_INSUFFICIENT_RESOURCES') ||
      error.message.includes('ERR_NETWORK') ||
      error.message.includes('ERR_CONNECTION_REFUSED') ||
      error.message.includes('ERR_NAME_NOT_RESOLVED') ||
      (error.response && error.response.status >= 500);
    
    logDebug(`❌ API Error: ${error.message}`, errorInfo);
    
    if (error.response?.status === 401) {
      logDebug('🔒 Authentication failed - check credentials');
    } else if (error.response?.status === 404) {
      logDebug('🔍 API endpoint not found - check URL');
    } else if (error.response?.status >= 500) {
      logDebug('🛠️ Server error - API may be down');
    } else if (error.code === 'ECONNABORTED') {
      logDebug('⏰ Request timeout - check network connection');
    } else if (error.message.includes('ERR_INSUFFICIENT_RESOURCES')) {
      logDebug('💾 Server resources exhausted - API may be overloaded');
    } else if (error.message.includes('ERR_NETWORK')) {
      logDebug('🌐 Network error - check internet connection');
    } else if (error.message.includes('ERR_CONNECTION_REFUSED')) {
      logDebug('🚫 Connection refused - API server may be down');
    }
    
    return Promise.reject(error);
  }
);

// Mock data for fallback when API is unavailable - updated to match real API structure
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
  conditions: 'Data Unavailable', // This marks it as mock data
  stationtype: 'Offline',
  model: 'Mock Data'
});

export const fetchFerryData = async () => {
  logDebug('🚢 Starting ferry data fetch...');
  
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
    
    // Return mock data when API is unavailable
    return getMockFerryData();
  }
};

export const fetchWeatherData = async () => {
  logDebug('☁️ Starting weather data fetch...');
  
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
    
    // Return mock data when API is unavailable
    return getMockWeatherData();
  }
};

export const fetchAllData = async () => {
  logDebug('🔄 Starting combined data fetch...');
  
  try {
    const startTime = Date.now();
    
    logDebug('📡 Making parallel API calls...');
    const [ferryData, weatherData] = await Promise.all([
      fetchFerryData(),
      fetchWeatherData(),
    ]);
    
    const endTime = Date.now();
    
    const result = {
      ferry: ferryData,
      weather: weatherData,
      timestamp: new Date().toISOString(),
    };
    
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
    logDebug('❌ Combined data fetch failed:', {
      error: error.message,
      timestamp: new Date().toISOString()
    });
    
    // Return mock data when all APIs fail
    return {
      ferry: getMockFerryData(),
      weather: getMockWeatherData(),
      timestamp: new Date().toISOString(),
    };
  }
};

// Debug function to test API connectivity
export const testApiConnectivity = async () => {
  logDebug('🧪 Testing API connectivity...');
  
  try {
    // Test ferry API
    logDebug('🔍 Testing ferry API...');
    const ferryResponse = await api.get(FERRY_API);
    logDebug('✅ Ferry API test successful:', {
      status: ferryResponse.status,
      hasData: !!ferryResponse.data
    });
    
    // Test weather API
    logDebug('🔍 Testing weather API...');
    const weatherResponse = await api.get(WEATHER_API);
    logDebug('✅ Weather API test successful:', {
      status: weatherResponse.status,
      hasData: !!weatherResponse.data
    });
    
    logDebug('🎉 All API tests passed!');
    return true;
  } catch (error) {
    logDebug('❌ API connectivity test failed:', {
      error: error.message,
      status: error.response?.status
    });
    return false;
  }
};

export default api; 