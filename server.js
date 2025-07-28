const express = require('express');
const axios = require('axios');
const path = require('path');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'build')));

// API Configuration
const FERRY_API = process.env.REACT_APP_FERRY_API_URL || 'https://nodered.ferrylight.online/rbferry';
const WEATHER_API = process.env.REACT_APP_WEATHER_API_URL || 'https://nodered.ferrylight.online/rbweather';
const username = process.env.REACT_APP_API_USERNAME || 'demo';
const password = process.env.REACT_APP_API_PASSWORD || 'demo';
const credentials = Buffer.from(`${username}:${password}`).toString('base64');

// Create axios instance for API calls
const api = axios.create({
  timeout: 15000,
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Basic ${credentials}`
  }
});

// Retry configuration
const RETRY_CONFIG = {
  maxRetries: 3,
  retryDelay: 2000,
  backoffMultiplier: 2
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
      error.message.includes('ERR_NETWORK') ||
      error.message.includes('ERR_CONNECTION_REFUSED') ||
      error.message.includes('ERR_NAME_NOT_RESOLVED') ||
      (error.response && error.response.status >= 500);

    if (isRetryableError) {
      const delay = RETRY_CONFIG.retryDelay * Math.pow(RETRY_CONFIG.backoffMultiplier, retryCount);
      console.log(`🔄 Retrying request in ${delay}ms (attempt ${retryCount + 1}/${RETRY_CONFIG.maxRetries + 1})`);
      
      await new Promise(resolve => setTimeout(resolve, delay));
      return retryRequest(requestFn, retryCount + 1);
    }

    throw error;
  }
};

// Mock data functions
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

// API Routes
app.get('/api/ferry', async (req, res) => {
  console.log('🚢 Fetching ferry data...');
  
  try {
    const startTime = Date.now();
    
    const response = await retryRequest(async () => {
      return await api.get(FERRY_API);
    });
    
    const endTime = Date.now();
    
    console.log(`✅ Ferry data fetched successfully in ${endTime - startTime}ms`);
    
    res.json(response.data);
  } catch (error) {
    console.log('❌ Ferry data fetch failed, using mock data:', {
      error: error.message,
      status: error.response?.status,
      url: FERRY_API
    });
    
    res.json(getMockFerryData());
  }
});

app.get('/api/weather', async (req, res) => {
  console.log('☁️ Fetching weather data...');
  
  try {
    const startTime = Date.now();
    
    const response = await retryRequest(async () => {
      return await api.get(WEATHER_API);
    });
    
    const endTime = Date.now();
    
    console.log(`✅ Weather data fetched successfully in ${endTime - startTime}ms`);
    
    res.json(response.data);
  } catch (error) {
    console.log('❌ Weather data fetch failed, using mock data:', {
      error: error.message,
      status: error.response?.status,
      url: WEATHER_API
    });
    
    res.json(getMockWeatherData());
  }
});

app.get('/api/all', async (req, res) => {
  console.log('🔄 Fetching all data...');
  
  try {
    const startTime = Date.now();
    
    console.log('📡 Making parallel API calls...');
    const [ferryResponse, weatherResponse] = await Promise.all([
      retryRequest(async () => api.get(FERRY_API)),
      retryRequest(async () => api.get(WEATHER_API))
    ]);
    
    const endTime = Date.now();
    
    const result = {
      ferry: ferryResponse.data,
      weather: weatherResponse.data,
      timestamp: new Date().toISOString()
    };
    
    console.log(`✅ All data fetched successfully in ${endTime - startTime}ms`);
    
    res.json(result);
  } catch (error) {
    console.log('❌ All data fetch failed, using mock data:', {
      error: error.message,
      status: error.response?.status
    });
    
    res.json({
      ferry: getMockFerryData(),
      weather: getMockWeatherData(),
      timestamp: new Date().toISOString()
    });
  }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// Serve React app for all other routes
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'build', 'index.html'));
});

// Error handling middleware
app.use((error, req, res, next) => {
  console.error('❌ Server error:', error);
  res.status(500).json({ 
    error: 'Internal server error',
    message: error.message 
  });
});

app.listen(PORT, () => {
  console.log(`🚀 FerryLight server running on port ${PORT}`);
  console.log(`📡 API endpoints:`);
  console.log(`   - GET /api/ferry - Ferry data`);
  console.log(`   - GET /api/weather - Weather data`);
  console.log(`   - GET /api/all - Combined data`);
  console.log(`   - GET /api/health - Health check`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
}); 