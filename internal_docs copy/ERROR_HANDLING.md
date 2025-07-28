# 🛡️ FerryLight Error Handling & Resilience

This document explains the comprehensive error handling and resilience features implemented in the FerryLight React website to handle API failures gracefully.

## 🚨 **Error Types Handled**

### **Network Errors**
- ✅ **ERR_INSUFFICIENT_RESOURCES** - Server overloaded or down
- ✅ **ERR_NETWORK** - Network connectivity issues
- ✅ **ERR_CONNECTION_REFUSED** - Server not responding
- ✅ **ERR_NAME_NOT_RESOLVED** - DNS resolution failures
- ✅ **ECONNABORTED** - Request timeout

### **HTTP Status Errors**
- ✅ **401 Unauthorized** - Authentication failures
- ✅ **404 Not Found** - API endpoint issues
- ✅ **500+ Server Errors** - Backend service problems

### **Browser/Client Errors**
- ✅ **CORS Issues** - Cross-origin request problems
- ✅ **Timeout Errors** - Request timeouts
- ✅ **Memory Issues** - Client-side resource problems

## 🔄 **Retry Logic**

### **Exponential Backoff**
```javascript
const RETRY_CONFIG = {
  maxRetries: 3,
  retryDelay: 2000, // 2 seconds
  backoffMultiplier: 2,
};
```

### **Retryable Error Detection**
```javascript
const isRetryableError = 
  error.code === 'ECONNABORTED' ||
  error.message.includes('ERR_INSUFFICIENT_RESOURCES') ||
  error.message.includes('ERR_NETWORK') ||
  error.message.includes('ERR_CONNECTION_REFUSED') ||
  error.message.includes('ERR_NAME_NOT_RESOLVED') ||
  (error.response && error.response.status >= 500);
```

### **Retry Sequence**
1. **First Attempt** - Immediate request
2. **Second Attempt** - After 2 seconds
3. **Third Attempt** - After 4 seconds
4. **Final Fallback** - Mock data

## 📊 **Mock Data System**

### **Ferry Mock Data**
```javascript
const getMockFerryData = () => ({
  payload: {
    ferryStatus: {
      status: 'Service Temporarily Unavailable',
      message: 'API server is currently unavailable'
    },
    directions: {
      jerseyToEnglishtown: {
        waitTime: { waitTime: 0, queueTime: 0, estimatedVehicles: 0, ferryTripsNeeded: 0 },
        travelTimeMinutes: 0,
        googleMapsLink: '#'
      },
      englishtownToJersey: {
        waitTime: { waitTime: 0, queueTime: 0, estimatedVehicles: 0, ferryTripsNeeded: 0 },
        travelTimeMinutes: 0,
        googleMapsLink: '#'
      }
    },
    matrixText: 'FerryLight - API Unavailable',
    ferryDataLastUpdated: new Date().toISOString()
  }
});
```

### **Weather Mock Data**
```javascript
const getMockWeatherData = () => ({
  payload: {
    weather: {
      temperature: 'N/A',
      conditions: 'Data Unavailable',
      location: 'Englishtown ↔ Jersey Cove',
      humidity: 'N/A',
      pm25: 'N/A',
      windSpeed: 'N/A',
      windDirection: 'N/A',
      lastUpdated: new Date().toISOString()
    }
  }
});
```

## 🎨 **UI Error States**

### **API Status Banner**
- **Red Banner** - API server unavailable
- **Warning Icon** - Alert triangle indicator
- **Clear Message** - "API Server Unavailable - Showing cached/offline data"

### **Status Indicators**
- **Green** - API online, data available
- **Red** - API offline, showing mock data
- **Yellow** - Unknown status

### **Data Display**
- **N/A Values** - When using mock data
- **Disabled Links** - Google Maps unavailable
- **Color Coding** - Red text for unavailable data

## 🔧 **Implementation Details**

### **API Service (`src/services/api.js`)**
```javascript
// Retry function with exponential backoff
const retryRequest = async (requestFn, retryCount = 0) => {
  try {
    return await requestFn();
  } catch (error) {
    if (retryCount >= RETRY_CONFIG.maxRetries) {
      throw error;
    }

    if (isRetryableError) {
      const delay = RETRY_CONFIG.retryDelay * Math.pow(RETRY_CONFIG.backoffMultiplier, retryCount);
      await new Promise(resolve => setTimeout(resolve, delay));
      return retryRequest(requestFn, retryCount + 1);
    }

    throw error;
  }
};
```

### **Component Error Handling**
```javascript
// Check if using mock data
const isUsingMockData = ferryData.ferryStatus?.status === 'Service Temporarily Unavailable';

// Conditional rendering
{isOffline && (
  <ApiStatusBanner isOffline={true}>
    <FiAlertTriangle />
    API Server Unavailable - Showing cached/offline data
  </ApiStatusBanner>
)}
```

## 📱 **User Experience**

### **Graceful Degradation**
1. **API Online** - Full functionality with real data
2. **API Offline** - Mock data with clear indicators
3. **Network Issues** - Retry with exponential backoff
4. **Complete Failure** - Fallback to mock data

### **Visual Feedback**
- ✅ **Loading States** - Spinner during requests
- ✅ **Error Banners** - Clear status messages
- ✅ **Color Coding** - Red for errors, green for success
- ✅ **Disabled Elements** - Non-functional features clearly marked

### **Debug Information**
- ✅ **Console Logging** - Detailed error information
- ✅ **Debug Panel** - Manual API testing
- ✅ **Network Monitoring** - Connectivity testing
- ✅ **Performance Metrics** - Response time tracking

## 🚀 **Performance Optimizations**

### **Request Optimization**
- **Increased Timeout** - 15 seconds (from 10)
- **Parallel Requests** - Both APIs called simultaneously
- **Caching** - Mock data for offline scenarios
- **Retry Limits** - Prevent infinite retry loops

### **Memory Management**
- **Error Cleanup** - Proper error object handling
- **Request Cancellation** - Abort previous requests
- **Resource Monitoring** - Track memory usage
- **Garbage Collection** - Clean up unused objects

## 🔍 **Debugging Features**

### **Console Logging**
```javascript
logDebug('❌ Ferry data fetch failed, using mock data:', {
  error: error.message,
  status: error.response?.status,
  url: FERRY_API
});
```

### **Debug Panel**
- **Manual API Testing** - Test individual endpoints
- **Network Testing** - Check connectivity
- **Error Simulation** - Test error scenarios
- **Performance Monitoring** - Track response times

### **Error Classification**
```javascript
if (error.message.includes('ERR_INSUFFICIENT_RESOURCES')) {
  logDebug('💾 Server resources exhausted - API may be overloaded');
} else if (error.message.includes('ERR_NETWORK')) {
  logDebug('🌐 Network error - check internet connection');
} else if (error.message.includes('ERR_CONNECTION_REFUSED')) {
  logDebug('🚫 Connection refused - API server may be down');
}
```

## 🛠️ **Configuration Options**

### **Retry Configuration**
```javascript
const RETRY_CONFIG = {
  maxRetries: 3,           // Number of retry attempts
  retryDelay: 2000,        // Initial delay in milliseconds
  backoffMultiplier: 2,    // Exponential backoff multiplier
};
```

### **Timeout Configuration**
```javascript
const api = axios.create({
  timeout: 15000,          // 15 second timeout
  headers: {
    'Content-Type': 'application/json',
  },
});
```

### **Error Thresholds**
```javascript
const isRetryableError = 
  error.code === 'ECONNABORTED' ||
  error.message.includes('ERR_INSUFFICIENT_RESOURCES') ||
  error.message.includes('ERR_NETWORK') ||
  error.message.includes('ERR_CONNECTION_REFUSED') ||
  error.message.includes('ERR_NAME_NOT_RESOLVED') ||
  (error.response && error.response.status >= 500);
```

## 📊 **Monitoring & Analytics**

### **Error Tracking**
- **Error Types** - Categorize different error types
- **Frequency** - Track how often errors occur
- **Impact** - Measure user experience impact
- **Resolution** - Monitor error resolution times

### **Performance Metrics**
- **Response Times** - Track API response times
- **Success Rates** - Monitor API success rates
- **Retry Counts** - Track retry attempts
- **Fallback Usage** - Monitor mock data usage

## 🎯 **Benefits**

### **User Experience**
- ✅ **Always Available** - App works even when APIs are down
- ✅ **Clear Feedback** - Users know when data is unavailable
- ✅ **Graceful Degradation** - Features degrade gracefully
- ✅ **Fast Recovery** - Automatic retry when APIs come back

### **Developer Experience**
- ✅ **Comprehensive Logging** - Detailed error information
- ✅ **Easy Debugging** - Debug panel for testing
- ✅ **Configurable** - Easy to adjust retry settings
- ✅ **Maintainable** - Clean, organized error handling

### **System Reliability**
- ✅ **Fault Tolerant** - Handles various failure modes
- ✅ **Self Healing** - Automatic recovery from errors
- ✅ **Resource Efficient** - Prevents infinite retry loops
- ✅ **Scalable** - Works with different API configurations

## 🔮 **Future Enhancements**

### **Planned Features**
- **Offline Caching** - Store real data for offline use
- **Progressive Loading** - Load critical data first
- **Smart Retry** - Adaptive retry based on error patterns
- **Health Checks** - Proactive API health monitoring

### **Advanced Error Handling**
- **Circuit Breaker** - Prevent cascading failures
- **Rate Limiting** - Respect API rate limits
- **Fallback APIs** - Multiple API endpoints
- **Data Validation** - Validate API responses

---

**🛡️ Your FerryLight website now has robust error handling that ensures it works reliably even when the API server is unavailable!** 