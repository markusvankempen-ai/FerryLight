import React, { useState } from 'react';
import styled from 'styled-components';
import { motion } from 'framer-motion';
import { FiSettings, FiRefreshCw, FiWifi, FiDatabase } from 'react-icons/fi';
import { fetchFerryData, fetchWeatherData, testApiConnectivity } from '../services/api';
import { testNetworkConnectivity, getBrowserInfo } from '../utils/debug';

const DebugPanelContainer = styled(motion.div)`
  position: fixed;
  bottom: 20px;
  right: 20px;
  background: #2c3e50;
  color: white;
  border-radius: 10px;
  padding: 1rem;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
  z-index: 1000;
  max-width: 400px;
  font-size: 0.9rem;
`;

const DebugHeader = styled.div`
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid #34495e;
`;

const DebugTitle = styled.h3`
  margin: 0;
  font-size: 1rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
`;

const DebugButton = styled.button`
  background: #3498db;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 5px;
  cursor: pointer;
  font-size: 0.8rem;
  margin: 0.25rem;
  transition: all 0.2s ease;

  &:hover {
    background: #2980b9;
    transform: translateY(-1px);
  }

  &:disabled {
    background: #95a5a6;
    cursor: not-allowed;
    transform: none;
  }
`;

const DebugSection = styled.div`
  margin-bottom: 1rem;
  padding: 0.5rem;
  background: #34495e;
  border-radius: 5px;
`;

const DebugSectionTitle = styled.h4`
  margin: 0 0 0.5rem 0;
  font-size: 0.9rem;
  color: #ecf0f1;
`;

const DebugResult = styled.div`
  background: #2c3e50;
  padding: 0.5rem;
  border-radius: 3px;
  margin: 0.25rem 0;
  font-family: monospace;
  font-size: 0.8rem;
  max-height: 100px;
  overflow-y: auto;
  white-space: pre-wrap;
`;

const StatusIndicator = styled.div`
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  margin-right: 0.5rem;
  background: ${props => props.status === 'success' ? '#27ae60' : props.status === 'error' ? '#e74c3c' : '#f39c12'};
`;

const ToggleButton = styled.button`
  position: fixed;
  bottom: 20px;
  right: 20px;
  background: #2c3e50;
  color: white;
  border: none;
  width: 50px;
  height: 50px;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
  z-index: 1001;
  transition: all 0.2s ease;

  &:hover {
    background: #34495e;
    transform: scale(1.1);
  }
`;

const DebugPanel = () => {
  const [isVisible, setIsVisible] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [results, setResults] = useState({});

  const runTest = async (testName, testFunction) => {
    setIsLoading(true);
    try {
      const result = await testFunction();
      setResults(prev => ({
        ...prev,
        [testName]: {
          status: 'success',
          data: result,
          timestamp: new Date().toISOString()
        }
      }));
    } catch (error) {
      setResults(prev => ({
        ...prev,
        [testName]: {
          status: 'error',
          error: error.message,
          timestamp: new Date().toISOString()
        }
      }));
    } finally {
      setIsLoading(false);
    }
  };

  const testFerryAPI = () => runTest('ferryAPI', fetchFerryData);
  const testWeatherAPI = () => runTest('weatherAPI', fetchWeatherData);
  const testAllAPIs = () => runTest('allAPIs', testApiConnectivity);
  const testNetwork = () => runTest('network', testNetworkConnectivity);
  const testBrowser = () => {
    const browserInfo = getBrowserInfo();
    setResults(prev => ({
      ...prev,
      browser: {
        status: 'success',
        data: browserInfo,
        timestamp: new Date().toISOString()
      }
    }));
  };

  const clearResults = () => {
    setResults({});
  };

  if (!isVisible) {
    return (
      <ToggleButton onClick={() => setIsVisible(true)}>
        <FiSettings />
      </ToggleButton>
    );
  }

  return (
    <>
      <DebugPanelContainer
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        exit={{ opacity: 0, y: 20 }}
      >
        <DebugHeader>
          <DebugTitle>
            <FiSettings />
            Debug Panel
          </DebugTitle>
          <DebugButton onClick={() => setIsVisible(false)}>✕</DebugButton>
        </DebugHeader>

        <DebugSection>
          <DebugSectionTitle>
            <FiDatabase />
            API Tests
          </DebugSectionTitle>
          <DebugButton onClick={testFerryAPI} disabled={isLoading}>
            Test Ferry API
          </DebugButton>
          <DebugButton onClick={testWeatherAPI} disabled={isLoading}>
            Test Weather API
          </DebugButton>
          <DebugButton onClick={testAllAPIs} disabled={isLoading}>
            Test All APIs
          </DebugButton>
        </DebugSection>

        <DebugSection>
          <DebugSectionTitle>
            <FiWifi />
            Network Tests
          </DebugSectionTitle>
          <DebugButton onClick={testNetwork} disabled={isLoading}>
            Test Network
          </DebugButton>
          <DebugButton onClick={testBrowser} disabled={isLoading}>
            Browser Info
          </DebugButton>
        </DebugSection>

        <DebugSection>
          <DebugSectionTitle>
            <FiRefreshCw />
            Results
          </DebugSectionTitle>
          <DebugButton onClick={clearResults} disabled={isLoading}>
            Clear Results
          </DebugButton>
          
          {Object.entries(results).map(([testName, result]) => (
            <div key={testName} style={{ marginBottom: '0.5rem' }}>
              <div style={{ display: 'flex', alignItems: 'center', marginBottom: '0.25rem' }}>
                <StatusIndicator status={result.status} />
                <strong>{testName}</strong>
                <span style={{ marginLeft: 'auto', fontSize: '0.7rem', opacity: 0.7 }}>
                  {new Date(result.timestamp).toLocaleTimeString()}
                </span>
              </div>
              <DebugResult>
                {result.status === 'success' 
                  ? JSON.stringify(result.data, null, 2)
                  : `Error: ${result.error}`
                }
              </DebugResult>
            </div>
          ))}
        </DebugSection>

        {isLoading && (
          <div style={{ textAlign: 'center', color: '#f39c12' }}>
            <FiRefreshCw style={{ animation: 'spin 1s linear infinite' }} />
            Running tests...
          </div>
        )}
      </DebugPanelContainer>

      <style>
        {`
          @keyframes spin {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
          }
        `}
      </style>
    </>
  );
};

export default DebugPanel; 