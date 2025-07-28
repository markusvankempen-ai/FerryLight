import React from 'react';
import styled from 'styled-components';
import { motion } from 'framer-motion';
import { FiThermometer, FiDroplet, FiWind, FiClock, FiCloud, FiAlertTriangle, FiCloudRain } from 'react-icons/fi';

const WeatherContainer = styled.div`
  max-width: 1200px;
  margin: 0 auto;
  padding: 0.8rem;
  flex: 1;
  display: flex;
  flex-direction: column;
`;

const WeatherHeader = styled.div`
  background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
  color: white;
  padding: 1.2rem;
  text-align: center;
  border-radius: 0.8rem;
  margin-bottom: 1rem;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
`;

const Title = styled.h1`
  font-size: 1.8rem;
  margin-bottom: 0.2rem;
  font-weight: 700;
`;

const Subtitle = styled.p`
  font-size: 0.9rem;
  opacity: 0.9;
  margin: 0;
`;

const WeatherCard = styled(motion.div)`
  background: #f8f9fa;
  border-radius: 0.8rem;
  padding: 1.2rem;
  box-shadow: 0 3px 12px rgba(0, 0, 0, 0.05);
  margin-bottom: 1rem;
  flex: 1;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1);
  }
`;

const ApiStatusBanner = styled.div`
  background: ${props => props.isOffline ? '#e74c3c' : '#f39c12'};
  color: white;
  padding: 0.6rem;
  text-align: center;
  border-radius: 0.4rem;
  margin-bottom: 0.8rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.4rem;
  font-weight: 500;
  font-size: 0.85rem;
`;

const WeatherGrid = styled.div`
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.8rem;
  margin-top: 1rem;

  @media (max-width: 768px) {
    grid-template-columns: 1fr;
  }
`;

const WeatherItem = styled.div`
  background: white;
  padding: 1.2rem;
  border-radius: 0.6rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  border-left: 3px solid #3498db;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;

  @media (max-width: 768px) {
    padding: 1rem;
  }

  @media (min-width: 1200px) {
    padding: 1.4rem;
  }
`;

const WeatherItemTitle = styled.h3`
  color: #2c3e50;
  margin: 0;
  font-size: 1.1rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 0.4rem;

  @media (max-width: 768px) {
    font-size: 1rem;
  }

  @media (min-width: 1200px) {
    font-size: 1.2rem;
  }
`;

const WeatherValue = styled.div`
  font-size: 1.3rem;
  font-weight: 700;
  color: ${props => props.isOffline ? '#95a5a6' : '#2c3e50'};
  display: flex;
  align-items: center;
  gap: 0.5rem;

  @media (max-width: 768px) {
    font-size: 1.2rem;
  }

  @media (min-width: 1200px) {
    font-size: 1.4rem;
  }
`;

const WeatherDescription = styled.p`
  color: #7f8c8d;
  font-size: 0.9rem;
  margin: 0;
  line-height: 1.4;

  @media (max-width: 768px) {
    font-size: 0.8rem;
  }

  @media (min-width: 1200px) {
    font-size: 1rem;
  }
`;

const TemperatureDisplay = styled.div`
  text-align: center;
  margin: 1rem 0;
`;

const TemperatureValue = styled.span`
  font-size: 3rem;
  font-weight: 700;
  color: ${props => props.isOffline ? '#95a5a6' : '#2c3e50'};

  @media (max-width: 768px) {
    font-size: 2.5rem;
  }

  @media (min-width: 1200px) {
    font-size: 3.5rem;
  }
`;

const TemperatureUnit = styled.span`
  font-size: 1.5rem;
  font-weight: 500;
  color: #7f8c8d;
  margin-left: 0.2rem;

  @media (max-width: 768px) {
    font-size: 1.2rem;
  }

  @media (min-width: 1200px) {
    font-size: 1.8rem;
  }
`;

const ConditionsDisplay = styled.div`
  text-align: center;
  margin: 0.6rem 0;
`;

const ConditionsText = styled.div`
  font-size: 1.4rem;
  font-weight: 600;
  color: ${props => props.isOffline ? '#95a5a6' : '#2c3e50'};
  margin-bottom: 0.5rem;

  @media (max-width: 768px) {
    font-size: 1.2rem;
  }

  @media (min-width: 1200px) {
    font-size: 1.6rem;
  }
`;

const LastUpdated = styled.div`
  font-size: 0.9rem;
  color: #7f8c8d;
  display: flex;
  align-items: center;
  gap: 0.3rem;

  @media (max-width: 768px) {
    font-size: 0.8rem;
  }

  @media (min-width: 1200px) {
    font-size: 1rem;
  }
`;

const LoadingSpinner = styled.div`
  display: flex;
  justify-content: center;
  align-items: center;
  height: 120px;
  font-size: 1rem;
  color: #7f8c8d;
`;

const ErrorMessage = styled.div`
  background: #e74c3c;
  color: white;
  padding: 0.8rem;
  border-radius: 0.4rem;
  text-align: center;
  margin: 0.8rem 0;
`;

const UvIndicator = styled.span`
  background: ${props => {
    if (props.isOffline) return '#95a5a6';
    const uv = parseInt(props.uv) || 0;
    if (uv <= 2) return '#27ae60';
    if (uv <= 5) return '#f39c12';
    if (uv <= 7) return '#e67e22';
    return '#e74c3c';
  }};
  color: white;
  padding: 0.2rem 0.5rem;
  border-radius: 0.3rem;
  font-size: 0.7rem;
  font-weight: 600;
  margin-left: 0.5rem;

  @media (max-width: 768px) {
    font-size: 0.6rem;
    padding: 0.15rem 0.4rem;
  }

  @media (min-width: 1200px) {
    font-size: 0.8rem;
    padding: 0.25rem 0.6rem;
  }
`;

// Debug logging function for WeatherInfo component
const logWeatherDebug = (message, data = null) => {
  const timestamp = new Date().toISOString();
  const logMessage = `[WeatherInfo] ${timestamp}: ${message}`;
  
  // Browser console
  if (typeof window !== 'undefined') {
    console.log(logMessage, data || '');
  }
  
  // Server console (Node.js)
  if (typeof process !== 'undefined') {
    console.log(logMessage, data || '');
  }
};

// Helper function to convert Fahrenheit to Celsius
const fahrenheitToCelsius = (fahrenheit) => {
  return Math.round((fahrenheit - 32) * 5 / 9 * 10) / 10;
};

// Helper function to get wind direction
const getWindDirection = (degrees) => {
  const directions = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', 'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'];
  const index = Math.round(degrees / 22.5) % 16;
  return directions[index];
};

// Helper function to format timestamp
const formatWeatherTimestamp = (timestamp) => {
  if (!timestamp) return 'Unknown';
  
  try {
    // Convert "2025-07-28 01:01:08" format to readable format
    const date = new Date(timestamp + ' UTC');
    if (isNaN(date.getTime())) return timestamp;
    
    return date.toLocaleString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: 'numeric',
      minute: 'numeric',
      second: 'numeric',
      hour12: true,
      timeZone: 'America/Halifax' // Atlantic time
    });
  } catch (error) {
    return timestamp;
  }
};

// Helper function to get weather conditions
const getWeatherConditions = (weatherData) => {
  if (!weatherData) return 'Unknown';
  
  const uv = weatherData.uv || 0;
  const rain = weatherData.hrain_piezomm || 0;
  const windSpeed = weatherData.windspeedkmh || 0;
  const solarRadiation = weatherData.solarradiation || 0;
  
  // Check for rain first
  if (rain > 0) return 'Rainy';
  
  // Check UV and solar radiation for day/night determination
  if (uv === 0 && solarRadiation === 0) {
    // It's likely night time
    return 'Clear Night';
  }
  
  // Day time conditions
  if (uv > 7) return 'Very Sunny';
  if (uv > 3) return 'Sunny';
  if (windSpeed > 20) return 'Windy';
  if (solarRadiation > 0) return 'Clear';
  
  return 'Clear';
};

const WeatherInfoComponent = ({ data, isLoading, error }) => {
  // Log component render
  logWeatherDebug('🎬 WeatherInfo component render:', {
    hasData: !!data,
    isLoading,
    hasError: !!error,
    dataType: typeof data,
    dataKeys: data ? Object.keys(data) : []
  });

  if (isLoading) {
    logWeatherDebug('⏳ Showing loading state');
    return (
      <WeatherContainer>
        <LoadingSpinner>Loading weather data...</LoadingSpinner>
      </WeatherContainer>
    );
  }

  if (error) {
    logWeatherDebug('❌ Showing error state:', { error });
    return (
      <WeatherContainer>
        <ErrorMessage>
          Error loading weather data: {error}
        </ErrorMessage>
      </WeatherContainer>
    );
  }

  if (!data) {
    logWeatherDebug('⚠️ No data available');
    return (
      <WeatherContainer>
        <ErrorMessage>No weather data available</ErrorMessage>
      </WeatherContainer>
    );
  }

  // The weather API returns direct weather station data, not nested in payload
  const weatherData = data;
  
  // Check if we're using mock data (API unavailable)
  const isUsingMockData = weatherData.conditions === 'Data Unavailable';
  
  // Extract weather information from the raw data
  const temperature = isUsingMockData ? 'N/A' : fahrenheitToCelsius(weatherData.tempf || 0);
  const humidity = isUsingMockData ? 'N/A' : (weatherData.humidity || 0);
  const windSpeed = isUsingMockData ? 'N/A' : Math.round((weatherData.windspeedkmh || 0) * 10) / 10;
  const windDirection = isUsingMockData ? 'N/A' : getWindDirection(weatherData.winddir || 0);
  const conditions = getWeatherConditions(weatherData);
  const uvIndex = weatherData.uv || 0;
  const rainToday = Math.round((weatherData.drain_piezomm || 0) * 10) / 10;
  const rainThisMonth = Math.round((weatherData.mrain_piezomm || 0) * 10) / 10;
  const pressure = Math.round((weatherData.baromrelhpa || 0) * 10) / 10;
  const lastUpdated = formatWeatherTimestamp(weatherData.dateutc);
  
  // Log data processing
  logWeatherDebug('📊 Processing weather data:', {
    temperature,
    humidity,
    windSpeed,
    windDirection,
    conditions,
    uvIndex,
    rainToday,
    rainThisMonth,
    pressure,
    lastUpdated,
    isUsingMockData
  });

  return (
    <WeatherContainer>
      <WeatherHeader>
        <Title>☁️ Weather Information</Title>
        <Subtitle>Current conditions for Englishtown ↔ Jersey Cove</Subtitle>
      </WeatherHeader>

      {isUsingMockData && (
        <ApiStatusBanner isOffline={true}>
          <FiAlertTriangle />
          API Server Unavailable - Showing cached/offline data
        </ApiStatusBanner>
      )}

      <WeatherCard
        whileHover={{ scale: 1.01 }}
        transition={{ duration: 0.2 }}
      >
        <TemperatureDisplay>
          <TemperatureValue isOffline={isUsingMockData}>
            {isUsingMockData ? 'N/A' : temperature}
            {!isUsingMockData && <TemperatureUnit>°C</TemperatureUnit>}
          </TemperatureValue>
        </TemperatureDisplay>

        <ConditionsDisplay>
          <ConditionsText isOffline={isUsingMockData}>
            {conditions}
          </ConditionsText>
        </ConditionsDisplay>

        <WeatherGrid>
          <WeatherItem>
            <WeatherItemTitle>
              <FiThermometer />
              Temperature
            </WeatherItemTitle>
            <WeatherValue isOffline={isUsingMockData}>
              {isUsingMockData ? 'N/A' : `${temperature}°C`}
            </WeatherValue>
            <WeatherDescription>Current temperature</WeatherDescription>
          </WeatherItem>

          <WeatherItem>
            <WeatherItemTitle>
              <FiDroplet />
              Humidity
            </WeatherItemTitle>
            <WeatherValue isOffline={isUsingMockData}>
              {isUsingMockData ? 'N/A' : `${humidity}%`}
            </WeatherValue>
            <WeatherDescription>Relative humidity</WeatherDescription>
          </WeatherItem>

          <WeatherItem>
            <WeatherItemTitle>
              <FiWind />
              Wind
            </WeatherItemTitle>
            <WeatherValue isOffline={isUsingMockData}>
              {isUsingMockData ? 'N/A' : `${windSpeed} km/h`}
            </WeatherValue>
            <WeatherDescription>
              {isUsingMockData ? 'Wind data unavailable' : `From ${windDirection} (${weatherData.winddir || 0}°)`}
            </WeatherDescription>
          </WeatherItem>

          <WeatherItem>
            <WeatherItemTitle>
              <FiCloud />
              UV Index
            </WeatherItemTitle>
            <WeatherValue isOffline={isUsingMockData}>
              {isUsingMockData ? 'N/A' : uvIndex}
              {!isUsingMockData && (
                <UvIndicator uv={uvIndex} isOffline={isUsingMockData}>
                  {uvIndex <= 2 ? 'Low' : uvIndex <= 5 ? 'Moderate' : uvIndex <= 7 ? 'High' : 'Very High'}
                </UvIndicator>
              )}
            </WeatherValue>
            <WeatherDescription>UV radiation level</WeatherDescription>
          </WeatherItem>

          <WeatherItem>
            <WeatherItemTitle>
              <FiCloudRain />
              Rain Today
            </WeatherItemTitle>
            <WeatherValue isOffline={isUsingMockData}>
              {isUsingMockData ? 'N/A' : `${rainToday} mm`}
            </WeatherValue>
            <WeatherDescription>Precipitation today</WeatherDescription>
          </WeatherItem>

          <WeatherItem>
            <WeatherItemTitle>
              <FiCloud />
              Pressure
            </WeatherItemTitle>
            <WeatherValue isOffline={isUsingMockData}>
              {isUsingMockData ? 'N/A' : `${pressure} hPa`}
            </WeatherValue>
            <WeatherDescription>Atmospheric pressure</WeatherDescription>
          </WeatherItem>
        </WeatherGrid>

        <LastUpdated>
          <FiClock />
          Weather data updated: {lastUpdated}
        </LastUpdated>
      </WeatherCard>
    </WeatherContainer>
  );
};

export default WeatherInfoComponent; 