// Debug utilities for FerryLight React App

// Global debug flag - set to true to enable detailed logging
export const DEBUG_MODE = process.env.NODE_ENV === 'development' || true;

// Debug logging function
export const logDebug = (component, message, data = null) => {
  if (!DEBUG_MODE) return;
  
  const timestamp = new Date().toISOString();
  const logMessage = `[${component}] ${timestamp}: ${message}`;
  
  // Browser console
  if (typeof window !== 'undefined') {
    console.log(logMessage, data || '');
  }
  
  // Server console (Node.js)
  if (typeof process !== 'undefined') {
    console.log(logMessage, data || '');
  }
};

// API test function
export const testApiEndpoints = async (api) => {
  logDebug('DEBUG', '🧪 Testing API endpoints...');
  
  const endpoints = [
    { name: 'Ferry API', url: 'https://nodered.ferrylight.online/rbferry' },
    { name: 'Weather API', url: 'https://nodered.ferrylight.online/rbweather' }
  ];
  
  const results = [];
  
  for (const endpoint of endpoints) {
    try {
      logDebug('DEBUG', `🔍 Testing ${endpoint.name}...`);
      
      const startTime = Date.now();
      const response = await api.get(endpoint.url);
      const endTime = Date.now();
      
      const result = {
        name: endpoint.name,
        url: endpoint.url,
        status: response.status,
        responseTime: endTime - startTime,
        hasData: !!response.data,
        dataKeys: response.data ? Object.keys(response.data) : [],
        success: true
      };
      
      logDebug('DEBUG', `✅ ${endpoint.name} test successful:`, result);
      results.push(result);
      
    } catch (error) {
      const result = {
        name: endpoint.name,
        url: endpoint.url,
        error: error.message,
        status: error.response?.status,
        success: false
      };
      
      logDebug('DEBUG', `❌ ${endpoint.name} test failed:`, result);
      results.push(result);
    }
  }
  
  logDebug('DEBUG', '📊 API test summary:', results);
  return results;
};

// Data validation function
export const validateDataStructure = (data, expectedKeys) => {
  logDebug('DEBUG', '🔍 Validating data structure...');
  
  const validation = {
    hasData: !!data,
    dataType: typeof data,
    keys: data ? Object.keys(data) : [],
    missingKeys: [],
    extraKeys: [],
    isValid: true
  };
  
  if (!data) {
    validation.isValid = false;
    validation.error = 'No data provided';
    logDebug('DEBUG', '❌ Data validation failed: No data', validation);
    return validation;
  }
  
  // Check for expected keys
  for (const key of expectedKeys) {
    if (!(key in data)) {
      validation.missingKeys.push(key);
      validation.isValid = false;
    }
  }
  
  // Check for extra keys
  for (const key of Object.keys(data)) {
    if (!expectedKeys.includes(key)) {
      validation.extraKeys.push(key);
    }
  }
  
  logDebug('DEBUG', '📊 Data validation result:', validation);
  return validation;
};

// Performance monitoring
export const measurePerformance = (name, fn) => {
  return async (...args) => {
    const startTime = performance.now();
    logDebug('DEBUG', `⏱️ Starting ${name}...`);
    
    try {
      const result = await fn(...args);
      const endTime = performance.now();
      const duration = endTime - startTime;
      
      logDebug('DEBUG', `✅ ${name} completed in ${duration.toFixed(2)}ms`);
      return result;
    } catch (error) {
      const endTime = performance.now();
      const duration = endTime - startTime;
      
      logDebug('DEBUG', `❌ ${name} failed after ${duration.toFixed(2)}ms:`, error);
      throw error;
    }
  };
};

// Network connectivity test
export const testNetworkConnectivity = async () => {
  logDebug('DEBUG', '🌐 Testing network connectivity...');
  
  const tests = [
    { name: 'Google DNS', url: 'https://8.8.8.8' },
    { name: 'Cloudflare DNS', url: 'https://1.1.1.1' },
    { name: 'Ferry API Domain', url: 'https://nodered.ferrylight.online' }
  ];
  
  const results = [];
  
  for (const test of tests) {
    try {
      const startTime = Date.now();
      await fetch(test.url, { 
        method: 'HEAD',
        mode: 'no-cors'
      });
      const endTime = Date.now();
      
      results.push({
        name: test.name,
        url: test.url,
        responseTime: endTime - startTime,
        success: true
      });
      
      logDebug('DEBUG', `✅ ${test.name} connectivity test passed`);
    } catch (error) {
      results.push({
        name: test.name,
        url: test.url,
        error: error.message,
        success: false
      });
      
      logDebug('DEBUG', `❌ ${test.name} connectivity test failed:`, error.message);
    }
  }
  
  logDebug('DEBUG', '📊 Network connectivity summary:', results);
  return results;
};

// Browser information
export const getBrowserInfo = () => {
  if (typeof window === 'undefined') return null;
  
  const info = {
    userAgent: navigator.userAgent,
    language: navigator.language,
    platform: navigator.platform,
    cookieEnabled: navigator.cookieEnabled,
    onLine: navigator.onLine,
    screenSize: {
      width: window.screen?.width || 0,
      height: window.screen?.height || 0
    },
    viewportSize: {
      width: window.innerWidth,
      height: window.innerHeight
    },
    timezone: Intl.DateTimeFormat().resolvedOptions().timeZone
  };
  
  logDebug('DEBUG', '🌐 Browser information:', info);
  return info;
};

// Export debug utilities for global access
if (typeof window !== 'undefined') {
  window.FerryLightDebug = {
    logDebug,
    testApiEndpoints,
    validateDataStructure,
    measurePerformance,
    testNetworkConnectivity,
    getBrowserInfo,
    DEBUG_MODE
  };
  
  logDebug('DEBUG', '🔧 Debug utilities loaded into window.FerryLightDebug');
} 