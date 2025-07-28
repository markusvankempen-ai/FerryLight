import React, { useState, useEffect, useCallback } from 'react';
import styled from 'styled-components';
import { motion, AnimatePresence } from 'framer-motion';
import Header from './components/Header';
import FerryStatusComponent from './components/FerryStatus';
import WeatherInfoComponent from './components/WeatherInfo';
import FerryLightComponent from './components/FerryLight';
import ContactInfoComponent from './components/ContactInfo';
import Login from './components/Login';
import Admin from './components/Admin';
import DebugPanel from './components/DebugPanel';
import { fetchAllData, testApiConnectivity } from './services/api';
import { logDebug, getBrowserInfo } from './utils/debug';

const AppContainer = styled.div`
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 0.5rem;
`;

const MainContent = styled.main`
  max-width: 1200px;
  margin: 0 auto;
  background: white;
  border-radius: 0.8rem;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
  overflow: hidden;
  min-height: calc(100vh - 1rem);
  display: flex;
  flex-direction: column;
`;

const PageContainer = styled(motion.div)`
  flex: 1;
  display: flex;
  flex-direction: column;
`;

const LoadingOverlay = styled.div`
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  color: white;
  font-size: 1.2rem;
`;

const ErrorBanner = styled.div`
  background: #e74c3c;
  color: white;
  padding: 0.8rem;
  text-align: center;
  margin: 0.5rem;
  border-radius: 0.4rem;
  font-weight: 500;
  font-size: 0.9rem;
`;

// Debug logging function for App component
const logAppDebug = (message, data = null) => {
  logDebug('App', message, data);
};

function App() {
  const [activePage, setActivePage] = useState('ferry');
  const [data, setData] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const [lastRefresh, setLastRefresh] = useState(null);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [showDebugPanel, setShowDebugPanel] = useState(false);

  // Check for existing admin session on component mount
  useEffect(() => {
    const admin = localStorage.getItem('ferrylight_admin');
    const adminTime = localStorage.getItem('ferrylight_admin_time');
    
    if (admin && adminTime) {
      const sessionAge = Date.now() - parseInt(adminTime);
      const sessionValid = sessionAge < 24 * 60 * 60 * 1000; // 24 hours
      
      if (sessionValid) {
        setIsLoggedIn(true);
        setShowDebugPanel(true);
      } else {
        localStorage.removeItem('ferrylight_admin');
        localStorage.removeItem('ferrylight_admin_time');
      }
    }
  }, []);

  // Create a stable fetchData function that doesn't change on every render
  // eslint-disable-next-line react-hooks/exhaustive-deps
  const fetchData = useCallback(async () => {
    logAppDebug(`🔄 Starting data fetch...`);
    
    try {
      setIsLoading(true);
      setError(null);
      
      logAppDebug('📡 Calling fetchAllData...');
      const result = await fetchAllData();
      
      logAppDebug('✅ Data fetch successful:', {
        hasFerryData: !!result.ferry,
        hasWeatherData: !!result.weather,
        ferryKeys: Object.keys(result.ferry || {}),
        weatherKeys: Object.keys(result.weather || {}),
        timestamp: result.timestamp
      });
      
      setData(result);
      setLastRefresh(new Date());
      
      logAppDebug('💾 Data stored in state successfully');
      
    } catch (err) {
      logAppDebug('❌ Data fetch failed:', {
        error: err.message,
        status: err.response?.status,
        timestamp: new Date().toISOString()
      });
      
      setError(err.message || 'Failed to fetch data');
    } finally {
      setIsLoading(false);
      logAppDebug('🏁 Data fetch completed');
    }
  }, []); // Empty dependency array - function won't change

  // Initial data fetch - only runs once
  useEffect(() => {
    logAppDebug('🚀 App initialized, starting initial data fetch...');
    fetchData();
  }, [fetchData]);

  // Auto-refresh every 5 minutes - stable interval
  useEffect(() => {
    logAppDebug('⏰ Setting up auto-refresh timer (5 minutes)...');
    
    const interval = setInterval(() => {
      logAppDebug('🔄 Auto-refresh triggered');
      fetchData();
    }, 5 * 60 * 1000); // 5 minutes

    return () => {
      logAppDebug('🧹 Cleaning up auto-refresh timer');
      clearInterval(interval);
    };
  }, [fetchData]);

  // Browser information on component mount - only runs once
  useEffect(() => {
    logAppDebug('🌐 Getting browser information...');
    const browserInfo = getBrowserInfo();
    if (browserInfo) {
      logAppDebug('📱 Browser information:', browserInfo);
    }
  }, []);

  // Debug logging for state changes - this should not trigger re-renders
  useEffect(() => {
    logAppDebug('🔄 State changed:', {
      activePage,
      hasData: !!data,
      isLoading,
      hasError: !!error,
      lastRefresh: lastRefresh?.toISOString(),
      isLoggedIn,
      showDebugPanel
    });
  }, [activePage, data, isLoading, error, lastRefresh, isLoggedIn, showDebugPanel]);

  const handlePageChange = (pageId) => {
    logAppDebug(`📄 Page change: ${activePage} → ${pageId}`);
    setActivePage(pageId);
  };

  const handleRefresh = useCallback(() => {
    logAppDebug('🔄 Manual refresh triggered by user');
    fetchData();
  }, [fetchData]);

  const handleLoginSuccess = () => {
    setIsLoggedIn(true);
    setShowDebugPanel(true);
    setActivePage('admin');
  };

  const handleLogout = () => {
    setIsLoggedIn(false);
    setShowDebugPanel(false);
    setActivePage('ferry');
  };

  const renderPage = () => {
    logAppDebug(`🎨 Rendering page: ${activePage}`);
    
    const pageComponents = {
      ferry: <FerryStatusComponent data={data?.ferry} isLoading={isLoading} error={error} />,
      weather: <WeatherInfoComponent data={data?.weather} isLoading={isLoading} error={error} />,
      ferrylight: <FerryLightComponent data={data?.ferry} isLoading={isLoading} error={error} />,
      contact: <ContactInfoComponent />,
      login: <Login onLoginSuccess={handleLoginSuccess} />,
      admin: <Admin onLogout={handleLogout} />
    };

    return pageComponents[activePage] || pageComponents.ferry;
  };

  // Log render cycle - but don't log every render to prevent spam
  const renderLogThrottle = React.useRef(0);
  const now = Date.now();
  if (now - renderLogThrottle.current > 1000) { // Only log once per second
    renderLogThrottle.current = now;
    logAppDebug('🎬 App render cycle:', {
      activePage,
      hasData: !!data,
      isLoading,
      hasError: !!error,
      isLoggedIn,
      showDebugPanel
    });
  }

  return (
    <AppContainer>
      <MainContent>
        {activePage !== 'login' && activePage !== 'admin' && (
          <Header
            activePage={activePage}
            onPageChange={handlePageChange}
            onRefresh={handleRefresh}
            isLoading={isLoading}
            isLoggedIn={isLoggedIn}
            onAdminClick={() => setActivePage('login')}
          />
        )}
        
        {error && (
          <ErrorBanner>
            Error: {error}
          </ErrorBanner>
        )}

        <AnimatePresence mode="wait">
          <PageContainer
            key={activePage}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            transition={{ duration: 0.2 }}
          >
            {renderPage()}
          </PageContainer>
        </AnimatePresence>
      </MainContent>

      {isLoading && (
        <LoadingOverlay>
          <div>Loading data...</div>
        </LoadingOverlay>
      )}

      {showDebugPanel && activePage !== 'admin' && <DebugPanel />}
    </AppContainer>
  );
}

export default App; 