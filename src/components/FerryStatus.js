import React from 'react';
import styled from 'styled-components';
import { motion } from 'framer-motion';
import { FiMapPin, FiClock, FiTruck, FiAnchor, FiAlertTriangle, FiArrowRightCircle, FiArrowLeftCircle } from 'react-icons/fi';

const FerryContainer = styled.div`
  max-width: 1200px;
  margin: 0 auto;
  padding: 1rem;
  flex: 1;
  display: flex;
  flex-direction: column;
`;

const StatusHeader = styled.div`
  background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
  color: white;
  padding: 1.5rem;
  text-align: center;
  border-radius: 0.8rem;
  margin-bottom: 1.5rem;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
`;

const Title = styled.h1`
  font-size: 2rem;
  margin-bottom: 0.3rem;
  font-weight: 700;
`;

const Subtitle = styled.p`
  font-size: 1rem;
  opacity: 0.9;
  margin: 0;
`;

const StatusBar = styled.div`
  background: #ecf0f1;
  padding: 1rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-radius: 0.5rem;
  margin-bottom: 1.5rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);

  @media (max-width: 768px) {
    flex-direction: column;
    gap: 0.8rem;
    align-items: flex-start;
  }
`;

const FerryStatus = styled.div`
  display: flex;
  align-items: center;
  gap: 0.5rem;
`;

const StatusIndicator = styled.div`
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: ${props => {
    if (props.isOffline) return '#e74c3c';
    if (props.isOnline) return '#27ae60';
    return '#f39c12';
  }};
  animation: ${props => props.isOnline ? 'pulse 2s infinite' : 'none'};

  @keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.5; }
  }
`;

const LastUpdated = styled.div`
  font-size: 0.85rem;
  color: #7f8c8d;
  display: flex;
  align-items: center;
  gap: 0.5rem;
`;

const ApiStatusBanner = styled.div`
  background: ${props => props.isOffline ? '#e74c3c' : '#f39c12'};
  color: white;
  padding: 0.8rem;
  text-align: center;
  border-radius: 0.4rem;
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  font-weight: 500;
  font-size: 0.9rem;
`;

const DirectionsGrid = styled.div`
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.5rem;
  flex: 1;

  @media (max-width: 768px) {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
`;

const DirectionCard = styled(motion.div)`
  background: white;
  padding: 1.5rem;
  border-radius: 0.8rem;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
  gap: 1rem;
`;

const DirectionTitle = styled.h2`
  font-size: 1.3rem;
  font-weight: 600;
  color: #2c3e50;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 0.5rem;
`;

const WaitTime = styled.div`
  font-size: 2.5rem;
  font-weight: bold;
  margin: 0.8rem 0;
  color: ${props => {
    if (props.isOffline) return '#e74c3c';
    if (props.noWait) return '#27ae60'; // Green for no wait
    const time = parseInt(props.time);
    if (time <= 15) return '#27ae60';
    if (time <= 30) return '#f39c12';
    return '#e74c3c';
  }};
  text-align: center;
`;

const Details = styled.div`
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  flex: 1;
`;

const DetailItem = styled.div`
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.6rem;
  font-size: 1.1rem;
  color: #2c3e50;
  font-weight: 500;

  &:last-child {
    margin-bottom: 0;
  }

  @media (max-width: 768px) {
    font-size: 1rem;
    margin-bottom: 0.5rem;
  }

  @media (min-width: 1200px) {
    font-size: 1.2rem;
    margin-bottom: 0.7rem;
  }
`;

const DetailItemLabel = styled.span`
  font-weight: 600;
  color: #7f8c8d;
  min-width: 120px;

  @media (max-width: 768px) {
    min-width: 100px;
  }

  @media (min-width: 1200px) {
    min-width: 140px;
  }
`;

const DetailItemValue = styled.span`
  font-weight: 700;
  color: #2c3e50;
  font-size: 1.1rem;

  @media (max-width: 768px) {
    font-size: 1rem;
  }

  @media (min-width: 1200px) {
    font-size: 1.2rem;
  }
`;

const GoogleMapsLink = styled(motion.a)`
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.4rem;
  color: white;
  text-decoration: none;
  font-size: 1rem;
  font-weight: 500;
  padding: 0.8rem 1.2rem;
  border-radius: 0.4rem;
  background: #3498db;
  transition: all 0.2s ease;
  width: 100%;
  margin-top: 1rem;

  &:hover {
    background: #2980b9;
    transform: translateY(-1px);
    box-shadow: 0 2px 8px rgba(52, 152, 219, 0.3);
  }

  &:disabled {
    color: #95a5a6;
    background: #ecf0f1;
    cursor: not-allowed;
    transform: none;
    box-shadow: none;
  }

  @media (max-width: 768px) {
    font-size: 0.9rem;
    padding: 0.7rem 1rem;
  }

  @media (min-width: 1200px) {
    font-size: 1.1rem;
    padding: 0.9rem 1.4rem;
  }
`;

const LoadingSpinner = styled.div`
  display: flex;
  justify-content: center;
  align-items: center;
  height: 150px;
  font-size: 1.1rem;
  color: #7f8c8d;
`;

const ErrorMessage = styled.div`
  background: #e74c3c;
  color: white;
  padding: 1rem;
  border-radius: 0.4rem;
  text-align: center;
  margin: 1rem 0;
`;

// Debug logging function for FerryStatus component
const logFerryDebug = (message, data = null) => {
  const timestamp = new Date().toISOString();
  const logMessage = `[FerryStatus] ${timestamp}: ${message}`;
  
  // Browser console
  if (typeof window !== 'undefined') {
    console.log(logMessage, data || '');
  }
  
  // Server console (Node.js)
  if (typeof process !== 'undefined') {
    console.log(logMessage, data || '');
  }
};

// Helper function to format API timestamp
const formatApiTimestamp = (timestamp) => {
  if (!timestamp) return 'Unknown';
  
  // If it's already a formatted string like "July 27, 2025 at 09:45:04 PM"
  if (typeof timestamp === 'string' && timestamp.includes('at')) {
    return timestamp;
  }
  
  // If it's an ISO string, format it
  try {
    const date = new Date(timestamp);
    if (isNaN(date.getTime())) return timestamp; // Return original if invalid
    
    return date.toLocaleString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: 'numeric',
      minute: 'numeric',
      second: 'numeric',
      hour12: true
    });
  } catch (error) {
    return timestamp; // Return original if formatting fails
  }
};

// Helper function to format wait time display
const formatWaitTime = (waitTime) => {
  if (!waitTime) return 'N/A';
  const time = parseInt(waitTime) || 0;
  return time <= 18 ? 'No Wait Time' : `${time} min`;
};

// Helper function to check if there's no wait
const hasNoWait = (waitTime) => {
  if (!waitTime) return false;
  const time = parseInt(waitTime) || 0;
  return time <= 18;
};

// Helper function to check if Google Maps link should be enabled
const isGoogleMapsEnabled = (directionData) => {
  // Enable if we have valid direction data and it's not offline
  return directionData && 
         directionData.status && 
         directionData.status !== 'Offline' && 
         directionData.status !== 'Unavailable' &&
         directionData.googleMapsLink;
};

const FerryStatusComponent = ({ data, isLoading, error }) => {
  // Log component render
  logFerryDebug('🎬 FerryStatus component render:', {
    hasData: !!data,
    isLoading,
    hasError: !!error,
    dataType: typeof data,
    dataKeys: data ? Object.keys(data) : []
  });

  if (isLoading) {
    logFerryDebug('⏳ Showing loading state');
    return (
      <FerryContainer>
        <LoadingSpinner>Loading ferry data...</LoadingSpinner>
      </FerryContainer>
    );
  }

  if (error) {
    logFerryDebug('❌ Showing error state:', { error });
    return (
      <FerryContainer>
        <ErrorMessage>
          Error loading ferry data: {error}
        </ErrorMessage>
      </FerryContainer>
    );
  }

  if (!data) {
    logFerryDebug('⚠️ No data available');
    return (
      <FerryContainer>
        <ErrorMessage>No ferry data available</ErrorMessage>
      </FerryContainer>
    );
  }

  const ferryData = data.payload || data; // Adjusted to handle direct data or payload
  const isUsingMockData = ferryData.ferryStatus?.status === 'Service Temporarily Unavailable';
  const isOffline = isUsingMockData || !ferryData.ferryStatus?.status || ferryData.ferryStatus?.status.toLowerCase().includes('offline') || !ferryData.ferryStatus?.status.toLowerCase().includes('service');
  const isOnline = !isOffline && ferryData.ferryStatus?.status.toLowerCase().includes('service');

  // Get the API timestamp - check multiple possible locations
  const apiTimestamp = ferryData.timestamp ||
                       ferryData.ferryDataLastUpdated ||
                       ferryData.lastUpdated ||
                       data.timestamp ||
                       'Unknown';

  const jerseyToEnglishtown = ferryData.directions?.jerseyToEnglishtown;
  const englishtownToJersey = ferryData.directions?.englishtownToJersey;

  // Use API-provided Google Maps links
  const jerseyToEnglishtownMapsLink = jerseyToEnglishtown?.googleMapsLink || '#';
  const englishtownToJerseyMapsLink = englishtownToJersey?.googleMapsLink || '#';
  
  // Check if maps should be enabled
  const jerseyMapsEnabled = isGoogleMapsEnabled(jerseyToEnglishtown);
  const englishtownMapsEnabled = isGoogleMapsEnabled(englishtownToJersey);

  logFerryDebug('🚢 FerryStatusComponent rendered with data:', {
    data,
    isLoading,
    error,
    isUsingMockData,
    isOffline,
    isOnline,
    apiTimestamp,
    includesService: ferryData.ferryStatus?.status?.toLowerCase().includes('service'),
    jerseyMapsEnabled,
    englishtownMapsEnabled,
    jerseyMapsLink: jerseyToEnglishtownMapsLink,
    englishtownMapsLink: englishtownToJerseyMapsLink
  });

  logFerryDebug('🚢 Jersey → Englishtown data:', {
    waitTime: jerseyToEnglishtown?.waitTime?.waitTime,
    formattedWaitTime: formatWaitTime(jerseyToEnglishtown?.waitTime?.waitTime),
    hasNoWait: hasNoWait(jerseyToEnglishtown?.waitTime?.waitTime),
    travelTime: jerseyToEnglishtown?.travelTimeMinutes,
    queueTime: jerseyToEnglishtown?.waitTime?.queueTime,
    estimatedVehicles: jerseyToEnglishtown?.waitTime?.estimatedVehicles,
    ferryTripsNeeded: jerseyToEnglishtown?.waitTime?.ferryTripsNeeded,
    status: jerseyToEnglishtown?.status,
    mapsLink: jerseyToEnglishtownMapsLink,
    mapsEnabled: jerseyMapsEnabled
  });

  logFerryDebug('🚢 Englishtown → Jersey data:', {
    waitTime: englishtownToJersey?.waitTime?.waitTime,
    formattedWaitTime: formatWaitTime(englishtownToJersey?.waitTime?.waitTime),
    hasNoWait: hasNoWait(englishtownToJersey?.waitTime?.waitTime),
    travelTime: englishtownToJersey?.travelTimeMinutes,
    queueTime: englishtownToJersey?.waitTime?.queueTime,
    estimatedVehicles: englishtownToJersey?.waitTime?.estimatedVehicles,
    ferryTripsNeeded: englishtownToJersey?.waitTime?.ferryTripsNeeded,
    status: englishtownToJersey?.status,
    mapsLink: englishtownToJerseyMapsLink,
    mapsEnabled: englishtownMapsEnabled
  });

  return (
    <FerryContainer
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
    >
      <StatusHeader>
        <Title>🚢 Ferry Traffic Status</Title>
        <Subtitle>Real-time wait times and travel information</Subtitle>
      </StatusHeader>

      {error && <ApiStatusBanner isOffline={true}>
          <FiAlertTriangle />
          Error loading ferry data: {error}
        </ApiStatusBanner>}
      {isUsingMockData && <ApiStatusBanner isOffline={true}>
          <FiAlertTriangle />
          API Server Unavailable - Showing cached/offline data
        </ApiStatusBanner>}

      <StatusBar>
        <FerryStatus>
          <StatusIndicator isOffline={isOffline} isOnline={isOnline} />
          <span>
            {isOffline ? 'Service Offline' : 'Service Online'}
          </span>
        </FerryStatus>
        <LastUpdated>
          <FiClock />
          Last updated: {formatApiTimestamp(apiTimestamp)}
        </LastUpdated>
      </StatusBar>

      <DirectionsGrid>
        <DirectionCard
          whileHover={{ scale: 1.01 }}
          transition={{ duration: 0.2 }}
        >
          <DirectionTitle>
            <FiArrowRightCircle />
            Jersey Cove → Englishtown
          </DirectionTitle>
          <WaitTime
            time={ferryData.directions?.jerseyToEnglishtown?.waitTime?.waitTime}
            isOffline={isOffline}
            noWait={hasNoWait(ferryData.directions?.jerseyToEnglishtown?.waitTime?.waitTime)}
          >
            {formatWaitTime(ferryData.directions?.jerseyToEnglishtown?.waitTime?.waitTime)}
          </WaitTime>
          <Details>
            <DetailItem>
              <FiTruck />
              <DetailItemLabel>Travel Time:</DetailItemLabel>
              <DetailItemValue>{ferryData.directions?.jerseyToEnglishtown?.travelTimeMinutes || 'N/A'} min</DetailItemValue>
            </DetailItem>
            <DetailItem>
              <FiClock />
              <DetailItemLabel>Queue Time:</DetailItemLabel>
              <DetailItemValue>{ferryData.directions?.jerseyToEnglishtown?.waitTime?.queueTime || 'N/A'} min</DetailItemValue>
            </DetailItem>
            <DetailItem>
              <FiAnchor />
              <DetailItemLabel>Vehicles:</DetailItemLabel>
              <DetailItemValue>{ferryData.directions?.jerseyToEnglishtown?.waitTime?.estimatedVehicles || 'N/A'}</DetailItemValue>
            </DetailItem>
            <DetailItem>
              <FiAlertTriangle />
              <DetailItemLabel>Trips Needed:</DetailItemLabel>
              <DetailItemValue>{ferryData.directions?.jerseyToEnglishtown?.waitTime?.ferryTripsNeeded || 'N/A'}</DetailItemValue>
            </DetailItem>
          </Details>
          {jerseyMapsEnabled ? (
            <GoogleMapsLink
              href={jerseyToEnglishtownMapsLink}
              target="_blank"
              rel="noopener noreferrer"
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
            >
              <FiMapPin />
              Get Directions
            </GoogleMapsLink>
          ) : (
            <GoogleMapsLink
              href="#"
              disabled
              style={{ cursor: 'not-allowed' }}
            >
              <FiMapPin />
              Directions Unavailable
            </GoogleMapsLink>
          )}
        </DirectionCard>

        <DirectionCard
          whileHover={{ scale: 1.01 }}
          transition={{ duration: 0.2 }}
        >
          <DirectionTitle>
            <FiArrowLeftCircle />
            Englishtown → Jersey Cove
          </DirectionTitle>
          <WaitTime
            time={ferryData.directions?.englishtownToJersey?.waitTime?.waitTime}
            isOffline={isOffline}
            noWait={hasNoWait(ferryData.directions?.englishtownToJersey?.waitTime?.waitTime)}
          >
            {formatWaitTime(ferryData.directions?.englishtownToJersey?.waitTime?.waitTime)}
          </WaitTime>
          <Details>
            <DetailItem>
              <FiTruck />
              <DetailItemLabel>Travel Time:</DetailItemLabel>
              <DetailItemValue>{ferryData.directions?.englishtownToJersey?.travelTimeMinutes || 'N/A'} min</DetailItemValue>
            </DetailItem>
            <DetailItem>
              <FiClock />
              <DetailItemLabel>Queue Time:</DetailItemLabel>
              <DetailItemValue>{ferryData.directions?.englishtownToJersey?.waitTime?.queueTime || 'N/A'} min</DetailItemValue>
            </DetailItem>
            <DetailItem>
              <FiAnchor />
              <DetailItemLabel>Vehicles:</DetailItemLabel>
              <DetailItemValue>{ferryData.directions?.englishtownToJersey?.waitTime?.estimatedVehicles || 'N/A'}</DetailItemValue>
            </DetailItem>
            <DetailItem>
              <FiAlertTriangle />
              <DetailItemLabel>Trips Needed:</DetailItemLabel>
              <DetailItemValue>{ferryData.directions?.englishtownToJersey?.waitTime?.ferryTripsNeeded || 'N/A'}</DetailItemValue>
            </DetailItem>
          </Details>
          {englishtownMapsEnabled ? (
            <GoogleMapsLink
              href={englishtownToJerseyMapsLink}
              target="_blank"
              rel="noopener noreferrer"
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
            >
              <FiMapPin />
              Get Directions
            </GoogleMapsLink>
          ) : (
            <GoogleMapsLink
              href="#"
              disabled
              style={{ cursor: 'not-allowed' }}
            >
              <FiMapPin />
              Directions Unavailable
            </GoogleMapsLink>
          )}
        </DirectionCard>
      </DirectionsGrid>
    </FerryContainer>
  );
};

export default FerryStatusComponent; 